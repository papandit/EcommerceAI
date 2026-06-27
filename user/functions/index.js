/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
// const functions = require("istanbul-reports");
const functions = require("firebase-functions");
const nodemailer = require("nodemailer");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const transporter = nodemailer.createTransport({
  service: "gmail", // Example for Gmail
  auth: {
    user: "miral.codebuzz@gmail.com",
    pass: "duwf qbwi mtxg rxgf",
  },
});

exports.sendEmail = functions.https.onCall(async (data, context) => {
  const {to, subject, message} = data.data;
  logger.info("Hello data!", {data});
  logger.info("Hello to!", {to});
  logger.info("Hello to!", {subject});
  logger.info("Hello to!", {message});
  const mailOptions = {
    from: "miral.codebuzz@gmail.com",
    to: to,
    subject: subject,
    text: message,
  };

  try {
    await transporter.sendMail(mailOptions);
    return {success: true, message: "Email sent successfully!"};
  } catch (error) {
    logger.info("Hello error!", {error});
    return {success: false, message: error.message};
  }
});
