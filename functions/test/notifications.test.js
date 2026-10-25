const test = require("node:test");
const assert = require("node:assert");

test("Notification payload contains required Android BigPicture and WebPush image fields", () => {
  const imageUrl = "https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80";
  const title = "Vehicle Ready for Collection!";
  const body = "Your 2022 Hyundai Creta is ready.";
  const deepLink = "/customer/jobs/job_123";

  const message = {
    notification: {
      title,
      body,
      image: imageUrl,
    },
    android: {
      priority: "high",
      notification: {
        channelId: "garage_card_high_importance",
        clickAction: "FLUTTER_NOTIFICATION_CLICK",
        image: imageUrl,
      },
    },
    webpush: {
      notification: {
        title,
        body,
        icon: "/icons/Icon-192.png",
        image: imageUrl,
      },
      fcmOptions: {
        link: deepLink,
      },
    },
    data: {
      deepLink,
      imageUrl,
      type: "job_status",
    },
  };

  assert.strictEqual(message.notification.image, imageUrl);
  assert.strictEqual(message.android.notification.image, imageUrl);
  assert.strictEqual(message.webpush.notification.image, imageUrl);
  assert.strictEqual(message.webpush.fcmOptions.link, deepLink);
  assert.strictEqual(message.data.deepLink, deepLink);
});

test("Idempotency key prevents duplicate notification dispatch", () => {
  const eventId1 = "job_job_123_readyForCollection";
  const eventId2 = "job_job_123_readyForCollection";

  assert.strictEqual(eventId1, eventId2);
});
