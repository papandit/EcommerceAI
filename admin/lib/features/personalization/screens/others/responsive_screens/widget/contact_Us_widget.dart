// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_final_fields, unused_field

import 'package:cwt_ecommerce_admin_panel/data/services/api/api_client.dart';
import 'package:cwt_ecommerce_admin_panel/common/widgets/breadcrumbs/breadcrumb_with_heading.dart';
import 'package:cwt_ecommerce_admin_panel/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

// Review Model with Additional Fields
class Review {
  final String id;
  final String name;
  final String message;
  final String email;
  final String phoneNumber;

  Review({
    required this.id,
    required this.name,
    required this.message,
    required this.email,
    required this.phoneNumber,
  });

  factory Review.fromMap(Map<String, dynamic> data, String id) {
    return Review(
      id: id,
      name: data['name'] ?? 'Anonymous',
      message: data['message'] ?? 'No Message',
      email: data['email'] ?? 'No Email',
      phoneNumber: data['phonenumber'] ?? 'No Phone Number',
    );
  }
}

class ContactUsWidget extends StatefulWidget {
  const ContactUsWidget({super.key});

  @override
  State<ContactUsWidget> createState() => _ContactUsWidgetState();
}

class _ContactUsWidgetState extends State<ContactUsWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TBreadcrumbsWithHeading(
              heading: 'Contact Us',
              breadcrumbItems: ['Contact Us'],
            ),
            SizedBox(height: TSizes.spaceBtwSections),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: ApiClient.instance.getList('/reviews'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(
                      color: Colors.orange,
                    ));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No Reviews Available'));
                  }

                  List<Review> reviews = snapshot.data!
                      .map((doc) => Review.fromMap(
                          doc, (doc['id'] ?? doc['_id'] ?? '').toString()))
                      .toList();

                  return ListView.builder(
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      var review = reviews[index];
                      return Card(
                        color: Colors.white,
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(height: 5),
                              Text("📧 Email: ${review.email}"),
                              Text("📞 Phone: ${review.phoneNumber}"),
                              SizedBox(height: 5),
                              // Text("💬 Message: ${review.message}"),
                              Text("💬 Message: "),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
