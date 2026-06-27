import 'package:cwt_ecommerce_admin_panel/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CouponTableHeader extends StatelessWidget {
  const CouponTableHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 200,
          child: ElevatedButton(onPressed: () => Get.toNamed(TRoutes.createCoupon), child: const Text('Create New Coupon')),
        ),
      ],
    );
  }
}
