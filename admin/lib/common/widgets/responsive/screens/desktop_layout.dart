import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../layouts/headers/header.dart';
import '../../layouts/sidebars/sidebar.dart';
import '../../layouts/sidebars/sidebar_controller.dart';

/// Widget for the desktop layout
class DesktopLayout extends StatelessWidget {
  DesktopLayout({super.key, this.body});

  /// Widget to be displayed as the body of the desktop layout
  final Widget? body;

  /// Key for the scaffold widget
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final sidebar = Get.put(SidebarController());
    return Scaffold(
      key: scaffoldKey,
      body: Row(
        children: [
          // Collapsible sidebar — animates between a full panel and an
          // icons-only rail when toggled.
          Obx(
            () => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: sidebar.collapsed.value ? 80 : 260,
              child: const TSidebar(),
            ),
          ),
          Expanded(
            flex: 5,
            child: Column(
              children: [
                THeader(scaffoldKey: scaffoldKey), // Header
                Expanded(child: body ?? Container()), // Body
              ],
            ),
          ),
        ],
      ),
    );
  }
}

