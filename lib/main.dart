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
            if (args is User) {
              return MaterialPageRoute(
                builder: (context) => HomePage(currentUser: args),
              );
            }
            return MaterialPageRoute(
              builder: (context) => HomePage(
                currentUser: User(
                  nim: '231401034',
                  fullName: 'User Testing',
                  role: UserRole.voter,
                  hasVoted: false,
                  faceEmbedding: [],
                  faculty: 'Ilmu Komputer',
                  major: 'Teknologi Informasi',
                  ktmImageUrl: '',
                  faceImageUrl: '',
                  createdAt: DateTime.now(),
                  gender: 'Laki-laki',
                  placeOfBirth: 'Medan',
                  dateOfBirth: DateTime(2000, 1, 1),
                  phoneNumber: '081234567890',
                  password: 'dummy',
                  faceData: '',
                  ktmData: '',
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

        // ✅ VOTING FLOW (FIXED)
          case '/voting-welcome':
            final election = settings.arguments as ElectionModel;
            return MaterialPageRoute(
              // Hapus const karena 'election' adalah variabel dinamis
              builder: (context) => VotingWelcomePage(election: election),
            );

          default:
            return MaterialPageRoute(builder: (context) => const SplashPage());
        }
      },
    );
  }
}