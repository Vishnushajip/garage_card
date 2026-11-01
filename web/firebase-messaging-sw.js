importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyD1LMs5Rzha-BIrg2982MG_Hf88sRFLa-I",
  appId: "1:62265849009:web:de72a4084ed3b138621e90",
  messagingSenderId: "62265849009",
  projectId: "garage-b7ed1",
  authDomain: "garage-b7ed1.firebaseapp.com",
  storageBucket: "garage-b7ed1.firebasestorage.app"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  const notificationTitle = payload.notification?.title || payload.data?.title || 'WeFix Notification';
  const imageUrl = payload.notification?.image || payload.data?.image || payload.data?.imageUrl || null;
  const iconUrl = payload.notification?.icon || payload.data?.icon || '/icons/Icon-192.png';
  const bodyText = payload.notification?.body || payload.data?.body || '';
  const deepLink = payload.data?.deepLink || payload.fcmOptions?.link || '/';

  const notificationOptions = {
    body: bodyText,
    icon: iconUrl,
    image: imageUrl,
    badge: '/favicon.png',
    data: {
      deepLink: deepLink,
      eventId: payload.data?.eventId,
      type: payload.data?.type,
      garageId: payload.data?.garageId
    },
    requireInteraction: false,
    vibrate: [200, 100, 200]
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

self.addEventListener('notificationclick', function(event) {
  event.notification.close();
  const targetUrl = event.notification.data?.deepLink || '/';

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then(function(clientList) {
      for (let i = 0; i < clientList.length; i++) {
        const client = clientList[i];
        if (client.url && 'focus' in client) {
          if ('navigate' in client) {
            client.navigate(targetUrl);
          }
          return client.focus();
        }
      }
      if (clients.openWindow) {
        return clients.openWindow(targetUrl);
      }
    })
  );
});
