// Please see this file for the latest firebase-js-sdk version:
// https://github.com/firebase/flutterfire/blob/master/packages/firebase_core/firebase_core_web/lib/src/firebase_sdk_version.dart
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

const firebaseConfig = {
    apiKey: "AIzaSyCAR4HzBOKFmMRnyP3YFSCkR2CcBPzmn1I",
    authDomain: "e-commerce-app-2e61e.firebaseapp.com",
    databaseURL: "https://e-commerce-app-2e61e-default-rtdb.firebaseio.com",
    projectId: "e-commerce-app-2e61e",
    storageBucket: "e-commerce-app-2e61e.appspot.com",
    messagingSenderId: "479178218268",
    appId: "1:479178218268:web:174686596e6d5ebcd138d9",
    measurementId: "G-DEPE1H4QTB"
};

firebase.initializeApp(firebaseConfig);

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
    console.log("onBackgroundMessage", message);
});
