import 'package:currency_converter/app/app_config.dart';
import 'package:flutter/material.dart';
import 'package:sliding_sheet2/sliding_sheet2.dart';

class PopupManager {
  Future<DateTime?> showDatePickerPopup(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1950),
      lastDate: lastDate ?? DateTime(2100),
    );
  }

  Future<void> showSlidingBottomPopup(
    BuildContext context,
    Widget content, {
    double width = double.infinity,
    double? initialHeightSnap,
    List<double> heightSnaps = const [
      double.infinity,
    ],
    double borderRadius = 25,
    Color? barrierColor,
    double elevation = 16,
    Color? dragIndicatorColor,
    bool preventClose = false,
    bool preventBackPress = false,
  }) {
    return showSlidingBottomSheet(
      context,
      builder: (_) {
        final screenHeight =
            MediaQuery.of(context).orientation == Orientation.portrait
                ? MediaQuery.of(context).size.height
                : MediaQuery.of(context).size.width;

        return SlidingSheetDialog(
          color: AppConfig.backgroundSecondary,
          maxWidth: width,
          snapSpec: SnapSpec(
            initialSnap: initialHeightSnap != null
                ? initialHeightSnap / screenHeight
                : null,
            snappings: heightSnaps.map((s) => s / screenHeight).toList(),
          ),
          scrollSpec: const ScrollSpec(
            overscroll: false,
            physics: ClampingScrollPhysics(),
          ),
          duration: const Duration(milliseconds: 250),
          avoidStatusBar: true,
          headerBuilder: (_, __) => const SizedBox.shrink(),
          cornerRadius: borderRadius,
          cornerRadiusOnFullscreen: 0,
          dismissOnBackdropTap: !preventClose,
          backdropColor: barrierColor ?? Colors.black26,
          elevation: elevation,
          builder: (context, state) {
            return SafeArea(
              top: false,
              child: PopScope(
                canPop: !preventBackPress,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(
                          color: dragIndicatorColor ?? AppConfig.primaryColor,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    content,
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
