import 'package:flutter/material.dart';

// Import semua halaman yang diperlukan
import 'package:campgear/pages/splash/splash_page.dart';
import 'package:campgear/pages/auth/sign_in_page.dart';
import 'package:campgear/pages/auth/sign_up_page.dart';
import 'package:campgear/pages/auth/welcome_page.dart';
// import 'package:campgear/pages/auth/verification_page.dart';
import 'package:campgear/pages/home/home_page.dart';
import 'package:campgear/pages/admin/dashboard_page.dart';
import 'package:campgear/pages/admin/manage_orders_page.dart';
import 'package:campgear/pages/admin/manage_product_page.dart';
import 'package:campgear/pages/admin/admin_profile_page.dart';

import 'package:campgear/pages/profile/profile_page.dart';
// import 'package:campgear/pages/profile/profile_update.dart';
import 'package:campgear/pages/profile/profile_change_password.dart';
import 'package:campgear/pages/profile/profile_delete.dart';
import 'package:campgear/pages/cart/cart_page.dart';
// import 'package:campgear/pages/payment/payment_page.dart';
import 'package:campgear/pages/payment/payment_success_dialog.dart';
import 'package:campgear/pages/history/history_page.dart';
import 'package:campgear/pages/chat/chat_page.dart';
import 'package:campgear/pages/onboarding/onboarding_page.dart';
// import 'package:campgear/pages/product/product_detail_page.dart';

class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const welcome = '/welcome';
  static const signIn = '/signin';
  static const signUp = '/signup';
  static const verification = '/verification';
  static const home = '/home';

  static const profile = '/profile';
  static const profileUpdate = '/profile_update';
  static const profileChangePassword = '/profile_change_password';
  static const profileDelete = '/profile_delete';

  static const cart = '/cart';
  static const payment = '/payment';
  static const paymentSuccess = '/payment_success';
  static const history = '/history';
  static const chat = '/chat';

  // Admin routes
  static const adminDashboard = '/admin_dashboard';
  static const adminManageOrders = '/admin_manage_orders';
  static const adminManageProduct = '/admin_manage_product';
  static const adminProfile = '/admin_profile';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashPage(),
    onboarding: (context) => const OnboardingPage(),
    welcome: (context) => const WelcomePage(),
    signIn: (context) => const SignInPage(),
    signUp: (context) => const SignUpPage(),
    // verification: (context) => const VerificationPage(),
    home: (context) => const HomePage(),

    profile: (context) => const ProfilePage(),
    // profileUpdate: (context) => const ProfileUpdatePage(),
    profileChangePassword: (context) => const ProfileChangePasswordPage(),
    profileDelete: (context) => const ProfileDeletePage(),

    cart: (context) => const CartPage(),
    // payment: (context) => const PaymentPage(),
    paymentSuccess: (context) => const PaymentSuccessDialog(),
    history: (context) => const HistoryPage(),
    chat: (context) => const ChatPage(),

    adminDashboard: (context) => const AdminDashboardPage(),
    adminManageOrders: (context) => const ManageOrdersPage(),
    adminManageProduct: (context) => const ManageProductPage(),
    adminProfile: (context) => const AdminProfilePage(),
  };
}
