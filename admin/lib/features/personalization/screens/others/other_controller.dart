// ignore_for_file: prefer_final_fields

import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/others/Models/about_us_model.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/others/Models/career_model.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/others/Models/contact_us_model.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/others/Models/free_shipping_model.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/others/Models/size_chart_model.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/others/other_repository.dart';
import 'package:cwt_ecommerce_admin_panel/utils/helpers/network_manager.dart';
import 'package:cwt_ecommerce_admin_panel/utils/popups/full_screen_loader.dart';
import 'package:cwt_ecommerce_admin_panel/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Models/secure_payment_model.dart';

class OthersController extends GetxController {
  final freeshipping = TextEditingController();
  final securePayment = TextEditingController();
  final aboutusController = TextEditingController();
  final contactusController = TextEditingController();
  final sizeChartController = TextEditingController();
  final careerController = TextEditingController();
  final isLoading = false.obs;
  String departmentname = "";
  OtherRepository _otherRepository = Get.put(OtherRepository());

  Future<void> createShipping() async {
    try {
      TFullScreenLoader.popUpCircular();
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }
      final newRecord = ShippingModel(
        id: '',
        freeshipText: freeshipping.text.trim(),
      );
      await _otherRepository.addFreeShipping(newRecord);
      freeshipping.clear();
      TFullScreenLoader.stopLoading();
      TLoaders.successSnackBar(
          title: 'Congratulations', message: 'New Record has been added.');
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  Future<void> securePayments() async {
    try {
      TFullScreenLoader.popUpCircular();
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }
      final newRecord = SecurePaymentModel(
        id: '',
        securePaymentText: securePayment.text.trim(),
      );
      await _otherRepository.securepayment(newRecord);
      securePayment.clear();
      TFullScreenLoader.stopLoading();
      TLoaders.successSnackBar(
          title: 'Congratulations', message: 'New Record has been added.');
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  Future<void> aboutUs() async {
    try {
      TFullScreenLoader.popUpCircular();
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }
      final newRecord = AboutUsModel(
        id: '',
        aboutText: aboutusController.text.trim(),
      );
      await _otherRepository.aboutus(newRecord);
      print('text//${aboutusController.text.trim()}');
      aboutusController.clear();
      TFullScreenLoader.stopLoading();
      TLoaders.successSnackBar(
          title: 'Congratulations', message: 'New Record has been added.');
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  Future<void> contactUs() async {
    try {
      TFullScreenLoader.popUpCircular();
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }
      final newRecord = ContactUsModel(
        id: '',
        contactText: contactusController.text.trim(),
      );
      await _otherRepository.contactus(newRecord);
      print('text//${contactusController.text.trim()}');
      contactusController.clear();
      TFullScreenLoader.stopLoading();
      TLoaders.successSnackBar(
          title: 'Congratulations', message: 'New Record has been added.');
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  Future<void> sizeChart() async {
    try {
      TFullScreenLoader.popUpCircular();
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }
      final newRecord = SizeChartModel(
        id: '',
        sizechartText: sizeChartController.text.trim(),
      );

      await _otherRepository.sizechart(newRecord);
      print('text//${sizeChartController.text.trim()}');
      sizeChartController.clear();
      TFullScreenLoader.stopLoading();
      TLoaders.successSnackBar(
          title: 'Congratulations', message: 'New Record has been added.');
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  Future<void> career() async {
    try {
      TFullScreenLoader.popUpCircular();
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }
      final newRecord = CareerModel(
        id: '',
        careerText: careerController.text.trim(),
      );

      await _otherRepository.career(newRecord);
      print('text//${careerController.text.trim()}');
      careerController.clear();
      TFullScreenLoader.stopLoading();
      TLoaders.successSnackBar(
          title: 'Congratulations', message: 'New Record has been added.');
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }
}
