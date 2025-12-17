import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Pastikan lottie sudah ada, atau ganti Icon
import 'package:suara_kita/core/constants/colors.dart';
import 'package:suara_kita/core/constants/app_constants.dart';
import 'package:suara_kita/presentation/widgets/common/primary_button.dart';

class SignupSuccessPage extends StatelessWidget {
  static const routeName = '/signup-success';

  const SignupSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // Animasi Sukses (Ganti dengan Icon jika Lottie belum siap)
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 100,
                color: AppColors.success,
              ),
              // Jika Lottie sudah siap, uncomment ini:
              // child: Lottie.asset(AppConstants.animSuccess, repeat: false),
            ),

            const SizedBox(height: 32),

            Text(
              'Pendaftaran Berhasil!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayMedium,
            ),

            const SizedBox(height: 16),

            Text(
              'Data Anda telah berhasil diverifikasi.\nSilakan login untuk mulai memilih.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.grey,
              ),
            ),

            const Spacer(),

            PrimaryButton(
              text: 'MASUK SEKARANG',
              onPressed: () {
                // Reset navigasi dan kembali ke halaman Login/Welcome
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                      (route) => false,
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}