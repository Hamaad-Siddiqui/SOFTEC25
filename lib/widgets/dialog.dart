import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:softec25/styles.dart';
import 'package:softec25/widgets/buttons.dart';

// Shows a dialog box with a message
void showCustomDialog(
  BuildContext context, {
  required String title,
  required String description,
  VoidCallback? onPressed,
  bool dismissable = true,
  String? buttonText,
  Color? buttonColor,
}) {
  showGeneralDialog(
    useRootNavigator: true,
    barrierLabel: "Barrier",
    barrierDismissible: dismissable,
    barrierColor: AppColors.barrierColor,
    transitionDuration: const Duration(milliseconds: 300),
    context: context,
    pageBuilder: (ctx, __, ___) {
      return Align(
        alignment: Alignment.center,
        child: Container(
          width: 318.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25.r),
          ),
          padding: EdgeInsets.only(
            left: 18.w,
            right: 18.w,
            top: 25.h,
            bottom: 25.h,
          ),
          child: Material(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: interBold.copyWith(
                    fontSize: 22.sp,
                    color: AppColors.darkTextColor,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  description,
                  style: medium.copyWith(
                    fontSize: 17.sp,
                    color: AppColors.darkTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 60.h),
                PrimaryButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pop();
                    if (onPressed != null) {
                      onPressed();
                    }
                  },
                  text: buttonText ?? 'Ok',
                  backgroundColor: buttonColor,
                  textStyle: bold.copyWith(
                    fontSize: 16.sp,
                    color: AppColors.lightTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
