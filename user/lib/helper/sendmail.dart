import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class SendMail {
  static Future<void> sendEmail({
    // required String name,
    required String email,
    required String ccEmail,
    required String message,
  }) async {
    const serviceId = 'service_c1w80ul';
    const templateId = 'template_0ezv0l6';
    const userId = 'g1Fgn3dH9zXwMlCjY';

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': {
          // 'user_name': name,
          'user_email': email,
          'cc_email': ccEmail,
          'user_message': message,
        },
      }),
    );

    // Debugging: Print the response body to see any potential errors

    if (response.statusCode == 200) {
      // Show success SnackBar and keep the page as it is
      // TLoaders.successSnackBar(
      //     title: "Email Status", message: "Your Email Send");
      Get.showSnackbar(const GetSnackBar(
        title: "Email sent successfully!",
      ));
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Email sent successfully!')),
      // );

      // Optional: Clear the form fields after successful submission
    } else {
      Get.showSnackbar(const GetSnackBar(
        title: "Failed to send email.",
      ));
      // TLoaders.warningSnackBar(
      //     title: "Email Status", message: 'Email not Send');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Failed to send email.')),
      // );
    }
  }
}
