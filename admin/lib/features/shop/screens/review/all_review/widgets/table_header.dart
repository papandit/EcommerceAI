import 'package:cwt_ecommerce_admin_panel/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReviewTableHeader extends StatelessWidget {
  const ReviewTableHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 200,
          child: ElevatedButton(
              onPressed: () => Get.toNamed(TRoutes.createReview),
              child: const Text('Create New Review')),
        ),
      ],
    );
  }
}
