const admin = require("firebase-admin");
const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onCall, HttpsError } = require("firebase-functions/v2/https");

admin.initializeApp();
const db = admin.firestore();

const FALLBACK_CAR_IMAGE = "https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80";
const FALLBACK_INSPECTION_IMAGE = "https://images.unsplash.com/photo-1486006920555-c77dce18193b?w=800&q=80";
const FALLBACK_ESTIMATE_IMAGE = "https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800&q=80";
const FALLBACK_INVOICE_IMAGE = "https://images.unsplash.com/photo-1554224154-26032ffc0d07?w=800&q=80";

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
    let imageUrl = FALLBACK_CAR_IMAGE;
    const deepLink = `/customer/jobs/${jobId}`;

    if (newStatus === "readyForCollection") {
      title = "Vehicle Ready for Collection!";
      body = `All repair work is complete on your ${vehicleName}. You can now collect your vehicle.`;
      imageUrl = afterData.coverPhotoUrl || FALLBACK_CAR_IMAGE;
    } else if (newStatus === "inProgress") {
      title = "Repair Work Started";
      body = `Our technicians have begun service on your ${vehicleName}.`;
      imageUrl = FALLBACK_INSPECTION_IMAGE;
    } else if (newStatus === "inspectionCompleted") {
      title = "Digital Inspection Complete";
      body = `Initial vehicle inspection is complete for your ${vehicleName}. Review report and estimate.`;
      imageUrl = FALLBACK_INSPECTION_IMAGE;
    }

    await sendMultiplatformPushNotification({
      recipientUid: customerId,
      title,
      body,
      imageUrl,
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
        imageUrl: FALLBACK_ESTIMATE_IMAGE,
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
      imageUrl: FALLBACK_INVOICE_IMAGE,
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

  if (!recipientUid || !title || !body) {
    throw new HttpsError("invalid-argument", "Missing required fields.");
  }

  if (garageId) {
    const garageDoc = await db.collection("garages").doc(garageId).get();
    const garageData = garageDoc.data();
    const isOwner = garageData?.ownerUid === request.auth.uid;
    const isMember =
      Array.isArray(garageData?.memberUids) &&
      garageData.memberUids.includes(request.auth.uid);

    if (!isOwner && !isMember) {
      throw new HttpsError(
        "permission-denied",
        "Not authorized to send notifications for this garage."
      );
    }
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
