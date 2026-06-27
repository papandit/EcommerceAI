import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/link.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../sidebar_controller.dart';

class TMenuItem extends StatelessWidget {
  const TMenuItem({super.key, required this.route, required this.itemName, required this.icon});

  final String route;
  final IconData icon;
  final String itemName;

  @override
  Widget build(BuildContext context) {
    final menuController = Get.put(SidebarController());
    return Link(
      uri: route != 'logout' ? Uri.parse(route) : null,
      builder: (_, __) => InkWell(
        onTap: () => menuController.menuOnTap(route),
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        focusColor: Colors.transparent,
        child: Obx(() {
          final bool active = menuController.isActive(route);
          final bool collapsed = menuController.collapsed.value;
          // Decoration Box — highlight the active item only (no hover effect).
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              decoration: BoxDecoration(
                color: active ? TColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: TColors.primary.withValues(alpha: 0.28),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),

              // Icon and Text Row
              child: Row(
                mainAxisAlignment: collapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon
                  Padding(
                    padding: collapsed
                        ? const EdgeInsets.all(11)
                        : const EdgeInsets.only(
                            left: TSizes.md, top: 8, bottom: 8, right: TSizes.md),
                    child: Tooltip(
                      message: collapsed ? itemName : '',
                      child: Icon(icon,
                          size: 20,
                          color:
                              active ? TColors.white : TColors.textSecondary),
                    ),
                  ),
                  // Text
                  if (!collapsed)
                    Flexible(
                      child: Text(itemName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 15.5,
                              fontWeight:
                                  active ? FontWeight.w700 : FontWeight.w500,
                              color: active
                                  ? TColors.white
                                  : TColors.textSecondary)),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
