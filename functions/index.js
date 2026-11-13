const admin = require("firebase-admin");
const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onRequest, onCall, HttpsError } = require("firebase-functions/v2/https");
const { setGlobalOptions } = require("firebase-functions/v2");
const express = require("express");
const cors = require("cors");

if (!admin.apps.length) {
  admin.initializeApp();
}
const db = admin.firestore();

setGlobalOptions({ region: "asia-south1", maxInstances: 10 });

const app = express();

const ALLOWED_ORIGINS = [
  "https://app-wefix.web.app",
  "https://app-wefix.firebaseapp.com",
  "https://wefix.app",
  "http://localhost:5173",
  "http://localhost:3000",
  "http://localhost:8080",
  "http://localhost:5000",
];

app.use(
  cors({
    origin: (origin, callback) => {
      if (!origin || ALLOWED_ORIGINS.includes(origin) || origin.endsWith(".web.app") || origin.endsWith(".firebaseapp.com")) {
        callback(null, true);
      } else {
        callback(null, false);
      }
    },
    methods: ["GET", "POST", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization", "X-Requested-With"],
    credentials: true,
  })
);

app.use((req, res, next) => {
  res.setHeader("X-Content-Type-Options", "nosniff");
  res.setHeader("X-Frame-Options", "DENY");
  res.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");
  res.setHeader("Permissions-Policy", "camera=(), microphone=(), geolocation=(self)");
  next();
});

app.use(express.json({ limit: "2mb" }));

const ipRateLimit = new Map();
app.use((req, res, next) => {
  const ip = req.headers["x-forwarded-for"] || req.socket.remoteAddress || "global";
  const now = Date.now();
  const windowMs = 60 * 1000;
  const maxRequests = 120;

  const current = ipRateLimit.get(ip) || [];
  const recent = current.filter((timestamp) => now - timestamp < windowMs);
  recent.push(now);
  ipRateLimit.set(ip, recent);

  if (recent.length > maxRequests) {
    return res.status(429).json({ error: "Too Many Requests", message: "Rate limit exceeded. Please try again shortly." });
  }
  next();
});

async function requireAuth(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ error: "Unauthorized", message: "Missing or invalid authorization header." });
  }

  const token = authHeader.split("Bearer ")[1].trim();
  try {
    const decoded = await admin.auth().verifyIdToken(token);
    req.user = decoded;
    next();
  } catch (err) {
    return res.status(401).json({ error: "Unauthorized", message: "Invalid or expired Firebase ID token." });
  }
}

app.get(["/health", "/api/health"], (req, res) => {
  res.status(200).json({
    status: "ok",
    service: "wefix-backend-api",
    timestamp: new Date().toISOString(),
    region: "asia-south1",
  });
});

app.post(["/places/search", "/api/places/search"], requireAuth, async (req, res) => {
  try {
    const { query } = req.body;
    if (!query || typeof query !== "string" || query.trim().length === 0) {
      return res.status(400).json({ error: "Bad Request", message: "Query string is required." });
    }

    const snapshot = await db
      .collection("garages")
      .where("isPublicCatalog", "==", true)
      .limit(20)
      .get();

    const normalizedQuery = query.toLowerCase().trim();
    const matches = [];

    snapshot.forEach((doc) => {
      const data = doc.data();
      const name = (data.name || "").toLowerCase();
      const city = (data.city || "").toLowerCase();
      const address = (data.address || "").toLowerCase();

      if (name.includes(normalizedQuery) || city.includes(normalizedQuery) || address.includes(normalizedQuery)) {
        matches.push({
          id: doc.id,
          name: data.name,
          address: data.address,
          city: data.city,
          phone: data.phone,
          rating: data.rating || 4.8,
          coverPhotoUrl: data.coverPhotoUrl || null,
        });
      }
    });

    res.status(200).json({ results: matches });
  } catch (error) {
    res.status(500).json({ error: "Internal Server Error", message: error.message });
  }
});

app.post(["/gatepass/verify", "/api/gatepass/verify"], requireAuth, async (req, res) => {
  try {
    const { garageId, jobId, otp } = req.body;
    if (!garageId || !jobId || !otp) {
      return res.status(400).json({ error: "Bad Request", message: "garageId, jobId, and otp are required." });
    }

    const garageDoc = await db.collection("garages").doc(garageId).get();
    if (!garageDoc.exists) {
      return res.status(404).json({ error: "Not Found", message: "Garage not found." });
    }

    const garageData = garageDoc.data();
    const isOwner = garageData.ownerUid === req.user.uid;
    const isMember = Array.isArray(garageData.memberUids) && garageData.memberUids.includes(req.user.uid);

    if (!isOwner && !isMember) {
      return res.status(403).json({ error: "Forbidden", message: "Not authorized to verify gate passes for this garage." });
    }

    const jobRef = db.collection("garages").doc(garageId).collection("serviceJobs").doc(jobId);
    const jobDoc = await jobRef.get();
    if (!jobDoc.exists) {
      return res.status(404).json({ error: "Not Found", message: "Service job not found." });
    }

    const jobData = jobDoc.data();
    const expectedOtp = jobData.gatePassOtp || jobData.deliveryOtp;

    if (!expectedOtp || String(expectedOtp).trim() !== String(otp).trim()) {
      return res.status(400).json({ success: false, message: "Invalid Gate Pass OTP." });
    }

    const nowIso = new Date().toISOString();
    await jobRef.update({
      status: "completed",
      isDelivered: true,
      deliveredAt: nowIso,
      gatePassVerifiedByUid: req.user.uid,
      gatePassVerifiedAt: nowIso,
    });

    res.status(200).json({
      success: true,
      message: "Gate Pass verified successfully. Vehicle delivery authorized.",
      jobId,
      deliveredAt: nowIso,
    });
  } catch (error) {
    res.status(500).json({ error: "Internal Server Error", message: error.message });
  }
});

app.post(["/notifications/dispatch", "/api/notifications/dispatch"], requireAuth, async (req, res) => {
  try {
    const { recipientUid, title, body, imageUrl, deepLink, type, garageId, eventId } = req.body;

    if (!recipientUid || !title || !body || !garageId) {
      return res.status(400).json({ error: "Bad Request", message: "Missing required fields." });
    }

    const garageDoc = await db.collection("garages").doc(garageId).get();
    if (!garageDoc.exists) {
      return res.status(404).json({ error: "Not Found", message: "Garage not found." });
    }

    const garageData = garageDoc.data();
    const isOwner = garageData.ownerUid === req.user.uid;
    const isMember = Array.isArray(garageData.memberUids) && garageData.memberUids.includes(req.user.uid);
    const isSelfRecipient = req.user.uid === recipientUid;

    if (!isOwner && !isMember && !isSelfRecipient) {
      return res.status(403).json({ error: "Forbidden", message: "Not authorized to dispatch notifications for this garage." });
    }

    const resolvedEventId = eventId || `api_notif_${Date.now()}_${Math.random().toString(36).substring(7)}`;

    await sendMultiplatformPushNotification({
      recipientUid,
      title,
      body,
      imageUrl,
      deepLink,
      eventId: resolvedEventId,
      type: type || "general",
      garageId,
    });

    res.status(200).json({ success: true, eventId: resolvedEventId });
  } catch (error) {
    res.status(500).json({ error: "Internal Server Error", message: error.message });
  }
});

exports.api = onRequest(
  {
    memory: "512MiB",
    timeoutSeconds: 60,
    concurrency: 80,
    minInstances: 0,
    invoker: "public",
  },
  app
);

async function sendMultiplatformPushNotification({
  recipientUid,
  title,
  body,
  imageUrl,
  deepLink,
  eventId,
  type,
  garageId,
}) {
  if (!recipientUid || !eventId) return;

  const eventRef = db.collection("processedEvents").doc(eventId);
  const eventDoc = await eventRef.get();
  if (eventDoc.exists) return;

  await eventRef.set({
    processedAt: admin.firestore.FieldValue.serverTimestamp(),
    recipientUid,
    type,
  });

  const now = new Date().toISOString();
  await db
    .collection("users")
    .doc(recipientUid)
    .collection("notifications")
    .doc(eventId)
    .set(
      {
        recipientUid,
        title,
        body,
        type,
        imageUrl: imageUrl || null,
        deepLink: deepLink || "/",
        garageId: garageId || null,
        eventId,
        isRead: false,
        createdAt: now,
      },
      { merge: true }
    );

  const tokensSnapshot = await db
    .collection("users")
    .doc(recipientUid)
    .collection("fcmTokens")
    .where("isActive", "==", true)
    .get();

  if (tokensSnapshot.empty) return;

  const tokens = [];
  const tokenDocMap = new Map();

  tokensSnapshot.forEach((doc) => {
    const data = doc.data();
    if (data.token) {
      tokens.push(data.token);
      tokenDocMap.set(data.token, doc.ref);
    }
  });

  if (tokens.length === 0) return;

  const message = {
    notification: {
      title,
      body,
      ...(imageUrl ? { image: imageUrl } : {}),
    },
    android: {
      priority: "high",
      notification: {
        channelId: "garage_card_high_importance",
        clickAction: "FLUTTER_NOTIFICATION_CLICK",
        defaultSound: true,
        defaultVibrateTimings: true,
        ...(imageUrl ? { image: imageUrl } : {}),
      },
    },
    webpush: {
      headers: {
        Urgency: "high",
      },
      notification: {
        title,
        body,
        icon: "/icons/Icon-192.png",
        badge: "/favicon.png",
        ...(imageUrl ? { image: imageUrl } : {}),
      },
      fcmOptions: {
        link: deepLink || "/",
      },
    },
    data: {
      deepLink: deepLink || "/",
      eventId,
      type: type || "general",
      garageId: garageId || "",
      ...(imageUrl ? { imageUrl } : {}),
    },
    tokens,
  };

  const response = await admin.messaging().sendEachForMulticast(message);

  const tokensToDeactivate = [];
  response.responses.forEach((res, index) => {
    if (!res.success && res.error) {
      const code = res.error.code;
      if (
        code === "messaging/registration-token-not-registered" ||
        code === "messaging/invalid-registration-token" ||
        code === "messaging/invalid-argument"
      ) {
        tokensToDeactivate.push(tokens[index]);
      }
    }
  });

  if (tokensToDeactivate.length > 0) {
    const batch = db.batch();
    tokensToDeactivate.forEach((token) => {
      const ref = tokenDocMap.get(token);
      if (ref) {
        batch.delete(ref);
      }
    });
    await batch.commit();
  }
}

exports.onServiceJobStatusChanged = onDocumentUpdated(
  "garages/{garageId}/serviceJobs/{jobId}",
  async (event) => {
    const beforeData = event.data.before.data();
    const afterData = event.data.after.data();
    const garageId = event.params.garageId;
    const jobId = event.params.jobId;

    if (!beforeData || !afterData || beforeData.status === afterData.status) {
      return;
    }

    const newStatus = afterData.status;
    const customerId = afterData.customerId;
    const vehicleName = afterData.vehicleModel || "your vehicle";
    const eventId = `job_${jobId}_${newStatus}`;

    let title = "Vehicle Service Update";
    let body = `Your ${vehicleName} status has been updated to ${newStatus}.`;
    const deepLink = `/customer/jobs/${jobId}`;

    if (newStatus === "readyForCollection") {
      title = "Vehicle Ready for Collection!";
      body = `All repair work is complete on your ${vehicleName}. You can now collect your vehicle.`;
    } else if (newStatus === "inProgress") {
      title = "Repair Work Started";
      body = `Our technicians have begun service on your ${vehicleName}.`;
    } else if (newStatus === "inspectionCompleted") {
      title = "Digital Inspection Complete";
      body = `Initial vehicle inspection is complete for your ${vehicleName}. Review report and estimate.`;
    }

    await sendMultiplatformPushNotification({
      recipientUid: customerId,
      title,
      body,
      deepLink,
      eventId,
      type: "job_status",
      garageId,
    });
  }
);

exports.onEstimateUpdated = onDocumentUpdated(
  "garages/{garageId}/estimates/{estimateId}",
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();
    const garageId = event.params.garageId;
    const estimateId = event.params.estimateId;

    if (!before || !after || before.status === after.status) return;

    const newStatus = after.status;
    const estimateNumber = after.estimateNumber || estimateId;

    if (newStatus === "approved" || newStatus === "rejected") {
      const garageDoc = await db.collection("garages").doc(garageId).get();
      const ownerUid = garageDoc.data()?.ownerUid;
      if (!ownerUid) return;

      const title =
        newStatus === "approved"
          ? "Estimate Approved by Customer"
          : "Estimate Declined";
      const body =
        newStatus === "approved"
          ? `Customer approved estimate ${estimateNumber}. You can proceed with work.`
          : `Customer declined estimate ${estimateNumber}.`;

      await sendMultiplatformPushNotification({
        recipientUid: ownerUid,
        title,
        body,
        deepLink: "/merchant/estimates",
        eventId: `est_${estimateId}_${newStatus}`,
        type: "estimate_decision",
        garageId,
      });
    }
  }
);

exports.onInvoiceCreated = onDocumentCreated(
  "garages/{garageId}/invoices/{invoiceId}",
  async (event) => {
    const invoice = event.data.data();
    const garageId = event.params.garageId;
    const invoiceId = event.params.invoiceId;

    if (!invoice || !invoice.customerId) return;

    const title = "New Service Invoice Issued";
    const body = `Invoice ${invoice.invoiceNumber || invoiceId} has been issued for your recent service.`;

    await sendMultiplatformPushNotification({
      recipientUid: invoice.customerId,
      title,
      body,
      deepLink: "/customer/invoices",
      eventId: `inv_${invoiceId}_created`,
      type: "invoice_issued",
      garageId,
    });
  }
);

exports.sendAuthorizedNotification = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated.");
  }

  const { recipientUid, title, body, imageUrl, deepLink, type, garageId, eventId } =
    request.data;

  if (!recipientUid || !title || !body || !garageId) {
    throw new HttpsError("invalid-argument", "Missing required fields.");
  }

  const garageDoc = await db.collection("garages").doc(garageId).get();
  if (!garageDoc.exists) {
    throw new HttpsError("not-found", "Specified garage does not exist.");
  }
  const garageData = garageDoc.data();
  const isOwner = garageData?.ownerUid === request.auth.uid;
  const isMember =
    Array.isArray(garageData?.memberUids) &&
    garageData.memberUids.includes(request.auth.uid);
  const isCustomerInquiring = garageData?.ownerUid === recipientUid;

  if (!isOwner && !isMember && !isCustomerInquiring) {
    throw new HttpsError(
      "permission-denied",
      "Not authorized to send notifications for this garage."
    );
  }

  const resolvedEventId = eventId || `manual_${Date.now()}_${Math.random().toString(36).substring(7)}`;

  await sendMultiplatformPushNotification({
    recipientUid,
    title,
    body,
    imageUrl,
    deepLink,
    eventId: resolvedEventId,
    type: type || "manual",
    garageId,
  });

  return { success: true, eventId: resolvedEventId };
});

