import 'package:flutter/material.dart';
import 'package:suara_kita/core/constants/colors.dart';
import 'package:suara_kita/core/constants/app_constants.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  // CHANGE: Make onPressed nullable
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed, // Still required, but can be null
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      // Logic: If loading, disable button. If not loading, use onPressed (which can be null to disable)
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primaryGreen,
        foregroundColor: foregroundColor ?? AppColors.white,
        disabledBackgroundColor: AppColors.grey.withOpacity(0.3),
        disabledForegroundColor: AppColors.grey,
        minimumSize: const Size(double.infinity, AppConstants.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
        ),
        elevation: onPressed == null ? 0 : 2,
      ),
      child: isLoading
          ? const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Colors.white,
        ),
      )
          : Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          fontFamily: AppConstants.fontAlmarai,
        ),
      ),
    );
  }
}