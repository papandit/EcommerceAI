import 'package:flutter/material.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../widgets/login_form.dart';
import '../widgets/login_header.dart';

class LoginScreenMobile extends StatelessWidget {
  const LoginScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: THelperFunctions.isDarkMode(context) ? TColors.black : Colors.white,
      body: Container(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: const SingleChildScrollView(
          child: Column(
            children: [
              ///  Header
              TLoginHeader(),

              /// Form
              TLoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}
