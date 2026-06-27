import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrderEmailForm extends StatefulWidget {
  const OrderEmailForm({super.key});

  @override
  _OrderEmailFormState createState() => _OrderEmailFormState();
}

class _OrderEmailFormState extends State<OrderEmailForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ccEmailController =
      TextEditingController(); // Controller for CC email
  final TextEditingController _messageController = TextEditingController();

  Future<void> sendEmail({
    required String name,
    required String email,
    required String ccEmail,
    required String message,
  }) async {
    const serviceId = 'service_7hywdeg';
    const templateId = 'template_86y5bwr';
    const userId = 'cV1c58or4_TDYov-0';

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
          'user_name': name,
          'user_email': email,
          'cc_email': ccEmail,
          'user_message': message,
        },
      }),
    );

    // Debugging: Print the response body to see any potential errors
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      // Show success SnackBar and keep the page as it is
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email sent successfully!')),
      );

      // Optional: Clear the form fields after successful submission
      _nameController.clear();
      _emailController.clear();
      _ccEmailController.clear();
      _messageController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send email.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Email with EmailJS'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ccEmailController,
                decoration: const InputDecoration(labelText: 'CC Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a CC email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(labelText: 'Message'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    sendEmail(
                      name: _nameController.text,
                      email: _emailController.text,
                      ccEmail: _ccEmailController.text,
                      message: _messageController.text,
                    );
                  }
                },
                child: const Text('Send Email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
