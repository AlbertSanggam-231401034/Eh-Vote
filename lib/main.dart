import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// --- CORE & THEME ---
import 'package:suara_kita/core/theme/app_theme.dart';
import 'package:suara_kita/firebase_options.dart';

// --- SERVICES & UTILS ---
import 'package:suara_kita/services/supabase_storage_service.dart';
import 'package:suara_kita/utils/admin_setup.dart';

// --- PROVIDERS ---
import 'package:suara_kita/presentation/providers/signup_provider.dart';
import 'package:suara_kita/presentation/providers/voting_provider.dart';

// --- MODELS ---
import 'package:suara_kita/data/models/user_model.dart';
import 'package:suara_kita/data/models/election_model.dart';

// --- PAGES ---
import 'package:suara_kita/presentation/pages/splash/splash_page.dart';
import 'package:suara_kita/presentation/pages/auth/welcome_page.dart';
import 'package:suara_kita/presentation/pages/auth/login_page.dart';
import 'package:suara_kita/presentation/pages/auth/admin_login_page.dart';

// Signup Flow
import 'package:suara_kita/presentation/pages/auth/signup/user_signup_data_page.dart';
import 'package:suara_kita/presentation/pages/auth/signup/user_signup_password_page.dart';
import 'package:suara_kita/presentation/pages/scan/face_scan_page.dart';
import 'package:suara_kita/presentation/pages/scan/ktm_scan_page.dart';
import 'package:suara_kita/presentation/pages/auth/signup/signup_face_page.dart';
import 'package:suara_kita/presentation/pages/auth/signup/signup_ktm_page.dart';
import 'package:suara_kita/presentation/pages/auth/signup/signup_success_page.dart';

// Admin
import 'package:suara_kita/presentation/pages/admin/admin_dashboard.dart';
import 'package:suara_kita/presentation/pages/admin/admin_scan_flow.dart';

// Voting Flow
import 'package:suara_kita/presentation/pages/voting_flow/voting_welcome_page.dart';
import 'package:suara_kita/presentation/pages/voting_flow/voting_face_verify_page.dart';
import 'package:suara_kita/presentation/pages/voting_flow/voting_ktm_scan_page.dart';
import 'package:suara_kita/presentation/pages/voting_flow/voting_agreement_page.dart';
import 'package:suara_kita/presentation/pages/voting_flow/candidate_selection_page.dart';
import 'package:suara_kita/presentation/pages/voting_flow/voting_confirmation_page.dart';
import 'package:suara_kita/presentation/pages/voting_flow/voting_success_page.dart';

// Main App
import 'package:suara_kita/presentation/pages/main_app/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await SupabaseStorageService.initialize();
    await AdminSetup.setupAdmins();
  } catch (e) {
    print('❌ Error initializing services: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignupProvider()),
        ChangeNotifierProvider(create: (_) => VotingProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Suara Kita - E-Voting USU',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',

      // --- BASIC ROUTES ---
      routes: {
        '/splash': (context) => const SplashPage(),
        '/welcome': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/admin-login': (context) => const AdminLoginPage(),
        '/signup': (context) => const UserSignupDataPage(),

        // Signup Flow
        '/signup-face': (context) => const SignupFacePage(),
        '/signup-ktm': (context) => const SignupKtmPage(),
        '/signup-success': (context) => const SignupSuccessPage(),

        // Voting Flow
        '/voting-face-verify': (context) => const VotingFaceVerifyPage(),
        '/voting-ktm-scan': (context) => const VotingKtmScanPage(),
        '/voting-agreement': (context) => const VotingAgreementPage(),
        '/candidate-selection': (context) => const CandidateSelectionPage(),
        '/voting-confirmation': (context) => const VotingConfirmationPage(),
        '/voting-success': (context) => const VotingSuccessPage(),
      },

      // --- DYNAMIC ROUTES (With Arguments) ---
      onGenerateRoute: (settings) {
        switch (settings.name) {

        // Home Page Logic
          case '/home':
            final args = settings.arguments;

            // 1. Jika Login Normal (args dikirim dari Login Page)
            if (args is User) {
              return MaterialPageRoute(
                builder: (context) => HomePage(currentUser: args),
              );
            }

            // 2. Jika Hot Restart (Fallback ke Data Testing Supabase Kamu)
            // ✅ FIX: Menggunakan Link Supabase Asli agar Face Verify tidak Error
            return MaterialPageRoute(
              builder: (context) => HomePage(
                currentUser: User(
                  nim: '231401034',
                  fullName: 'Albert Sanggam Nalom Sinurat',
                  role: UserRole.voter, // Tetap voter agar bisa tes voting
                  hasVoted: false, // Set false untuk tes, true untuk tes UI sudah vote
                  faceEmbedding: [],
                  faculty: 'Fakultas Ilmu Komputer dan Teknologi Informasi (Fasilkom-TI)',
                  major: 'Ilmu Komputer',

                  // 👇 URL INI PENTING UNTUK FACE RECOGNITION
                  faceImageUrl: 'https://bygrusoabptiyhmqayqx.supabase.co/storage/v1/object/public/face-images/face_231401034_1765966990620.jpg',
                  ktmImageUrl: 'https://bygrusoabptiyhmqayqx.supabase.co/storage/v1/object/public/ktm-images/ktm_231401034_1765967001846.jpg',

                  createdAt: DateTime.now(),
                  gender: 'Laki-laki',
                  placeOfBirth: 'Lubuk Pakam',
                  dateOfBirth: DateTime(2005, 9, 22),
                  phoneNumber: '081278093204',
                  password: 'dummy',
                  faceData: 'face_embedding_231401034',
                  ktmData: 'KTM_1765967004156',
                ),
              ),
            );

        // Signup Routes
          case '/user-signup-password':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => UserSignupPasswordPage(userData: args),
            );

          case '/user-signup-face':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => FaceScanPage(
                nim: args['nim'],
                onFaceScanned: (imageUrl) {
                  Navigator.pushNamed(
                      context,
                      '/user-signup-ktm',
                      arguments: {...args, 'faceImageUrl': imageUrl}
                  );
                },
              ),
            );

          case '/user-signup-ktm':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => KtmScanPage(
                nim: args['nim'],
                onKtmScanned: (imageUrl, barcodeData) async {},
              ),
            );

        // Admin Routes
          case '/admin-dashboard':
            final args = settings.arguments as User?;
            if (args == null) {
              return MaterialPageRoute(builder: (context) => const LoginPage());
            }
            return MaterialPageRoute(
              builder: (context) => AdminDashboard(currentUser: args),
            );

          case '/admin-scan-flow':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => AdminScanFlow(adminNim: args['adminNim']),
            );

        // Voting Flow
          case '/voting-welcome':
            final election = settings.arguments as ElectionModel;
            return MaterialPageRoute(
              builder: (context) => VotingWelcomePage(election: election),
            );

          default:
            return MaterialPageRoute(builder: (context) => const SplashPage());
        }
      },
    );
  }
}