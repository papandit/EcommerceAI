import 'package:cwt_ecommerce_admin_panel/features/shop/models/depaerment_model.dart';
import 'package:flutter/material.dart';
import '../../../../../../common/widgets/breadcrumbs/breadcrumb_with_heading.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../widgets/edit_department_form.dart';

class EditDepartMentDesktopScreen extends StatelessWidget {
  const EditDepartMentDesktopScreen({super.key, required this.category});

  final DepartmentModel category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breadcrumbs
              const TBreadcrumbsWithHeading(
                  returnToPreviousScreen: true,
                  heading: 'Update',
                  breadcrumbItems: [TRoutes.department, 'Update']),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Form
              EditDepartmentForm(category: category),
            ],
          ),
        ),
      ),
    );
  }
}
