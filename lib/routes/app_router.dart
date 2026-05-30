// Active service screen imports
import 'package:bhukkdelivery/screen/car_booking_screen/car_booking_screen.dart';
import 'package:bhukkdelivery/screen/car_booking_screen/car_booking_take_orders_screen.dart';
import 'package:bhukkdelivery/screen/car_booking_screen/car_booking_history_screen.dart';
import 'package:bhukkdelivery/screen/car_booking_screen/car_booking_earnings_screen.dart';
import 'package:bhukkdelivery/screen/earnings_screen/earnings_screen.dart';
import 'package:bhukkdelivery/screen/home_screen/home_screen.dart';
import 'package:bhukkdelivery/screen/parcel_screen/parcel_screen.dart';
import 'package:bhukkdelivery/screen/parcel_screen/parcel_take_orders_screen.dart';
import 'package:bhukkdelivery/screen/parcel_screen/parcel_earnings_screen.dart';
import 'package:bhukkdelivery/screen/parcel_screen/parcel_history_screen.dart';
import 'package:bhukkdelivery/screen/main_shell.dart';
import 'package:bhukkdelivery/screen/otp_screen/otp_screen.dart';
import 'package:bhukkdelivery/screen/medicine_screen/medicine_screen.dart';
import 'package:bhukkdelivery/screen/medicine_screen/medicine_earnings_screen.dart';
import 'package:bhukkdelivery/screen/medicine_screen/medicine_history_screen.dart';
import 'package:bhukkdelivery/screen/medicine_screen/medicine_take_orders_screen.dart';
import 'package:bhukkdelivery/screen/live_navigation_screen/live_navigation_screen.dart';
import 'package:bhukkdelivery/screen/new_order_request_screen/new_order_request_screen.dart';
import 'package:bhukkdelivery/screen/orders_screen/orders_screen.dart';
import 'package:bhukkdelivery/screen/profile_screen/profile_screen.dart';
import 'package:bhukkdelivery/screen/splash_screen/splash_screen.dart';
import 'package:bhukkdelivery/screen/suspended_screen/suspended_screen.dart';
import 'package:bhukkdelivery/screen/help_support_screen/help_support_screen.dart';
import 'package:bhukkdelivery/screen/earning_details_screen/earning_details_screen.dart';
import 'package:bhukkdelivery/screen/edit_profile_screen/edit_profile_screen.dart';
import 'package:bhukkdelivery/screen/settings_screen/settings_screen.dart';
import 'package:bhukkdelivery/screen/snacks_inventory_screen/snacks_inventory_screen.dart';
import 'package:bhukkdelivery/screen/login_screen/login_screen.dart';
import 'package:bhukkdelivery/screen/register_screen/register_screen.dart';
import 'package:bhukkdelivery/screen/payment_screen/payment_screen.dart';
import 'package:bhukkdelivery/services/api/api_config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ── Commented-out imports for disabled services ──
// import 'package:bhukkdelivery/screen/ambulance_screen/ambulance_screen.dart';
// import 'package:bhukkdelivery/screen/ambulance_screen/take_order_screen.dart';
// import 'package:bhukkdelivery/screen/ambulance_screen/ambulance_earnings_screen.dart';
// import 'package:bhukkdelivery/screen/ambulance_screen/ambulance_history_screen.dart';
// import 'package:bhukkdelivery/screen/food_delivery_screen/food_delivery_screen.dart';
// import 'package:bhukkdelivery/screen/food_delivery_screen/food_take_orders_screen.dart';
// import 'package:bhukkdelivery/screen/food_delivery_screen/food_earnings_screen.dart';
// import 'package:bhukkdelivery/screen/food_delivery_screen/food_history_screen.dart';
// import 'package:bhukkdelivery/screen/cosmatics_screen/cosmatics_screen.dart';
// import 'package:bhukkdelivery/screen/beverages_screen/beverages_screen.dart';
// import 'package:bhukkdelivery/screen/beverages_screen/beverages_earnings_screen.dart';
// import 'package:bhukkdelivery/screen/beverages_screen/beverages_history_screen.dart';
// import 'package:bhukkdelivery/screen/cosmatics_screen/cosmatics_take_orders_screen.dart';
// import 'package:bhukkdelivery/screen/cosmatics_screen/cosmatics_history_screen.dart';
// import 'package:bhukkdelivery/screen/cosmatics_screen/cosmatics_earnings_screen.dart';
// import 'package:bhukkdelivery/screen/heavy_delivery_screen/heavy_delivery_screen.dart';

final homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'homeNav');
final ordersNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'ordersNav');
final earningsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'earningsNav');
final profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profileNav');

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // ... (rest of the non-shell routes remain same)
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

    GoRoute(
      path: '/suspended',
      builder: (context, state) {
        final message = state.uri.queryParameters['message'] ??
            'Your account has been temporarily suspended due to excessive cancellations.';
        final banType = state.uri.queryParameters['banType'];
        return SuspendedScreen(message: message, banType: banType);
      },
    ),

    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    GoRoute(
      path: '/register',
      builder: (context, state) {
        final phone = state.uri.queryParameters['phone'];
        return RegisterScreen(prefilledPhone: phone);
      },
    ),

    GoRoute(
      path: '/payment',
      builder: (context, state) {
        final params = state.uri.queryParameters;
        return PaymentScreen(
          serviceType: params['serviceType'] ?? 'general',
          amount: double.tryParse(params['amount'] ?? '') ?? 0,
          orderId: params['orderId'] ?? 'ORD-001',
        );
      },
    ),

    // Main app — with bottom nav
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0: Home
        StatefulShellBranch(
          navigatorKey: homeNavigatorKey,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'new_order',
                  builder: (context, state) => const NewOrderRequestScreen(),
                ),
                GoRoute(
                  path: 'live_navigation',
                  builder: (context, state) => const LiveNavigationScreen(),
                  routes: [
                    GoRoute(
                      path: 'otp',
                      builder: (context, state) => const OtpScreen(),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'help_support',
                  builder: (context, state) => const HelpSupportScreen(),
                ),
                GoRoute(
                  path: 'snacks',
                  builder: (context, state) => const SnacksInventoryScreen(),
                ),
                // Medicine
                GoRoute(
                  path: 'medicine',
                  builder: (context, state) => const MedicineScreen(),
                  routes: [
                    GoRoute(
                      path: 'earnings',
                      builder: (context, state) => const MedicineEarningsScreen(),
                    ),
                    GoRoute(
                      path: 'history',
                      builder: (context, state) => const MedicineHistoryScreen(),
                    ),
                    GoRoute(
                      path: 'take_orders',
                      builder: (context, state) => const MedicineTakeOrdersScreen(),
                    ),
                  ],
                ),
                // Parcel
                GoRoute(
                  path: 'parcel',
                  builder: (context, state) => const ParcelScreen(),
                  routes: [
                    GoRoute(
                      path: 'earnings',
                      builder: (context, state) => const ParcelEarningsScreen(),
                    ),
                    GoRoute(
                      path: 'history',
                      builder: (context, state) => const ParcelHistoryScreen(),
                    ),
                    GoRoute(
                      path: 'take_orders',
                      builder: (context, state) =>
                          const ParcelTakeOrdersScreen(),
                    ),
                  ],
                ),
                // Car/Cab Booking
                GoRoute(
                  path: 'car_booking',
                  builder: (context, state) => const CarBookingScreen(),
                  routes: [
                    GoRoute(
                      path: 'take_orders',
                      builder: (context, state) =>
                          const CarBookingTakeOrdersScreen(),
                    ),
                    GoRoute(
                      path: 'earnings',
                      builder: (context, state) =>
                          const CarBookingEarningsScreen(),
                    ),
                    GoRoute(
                      path: 'history',
                      builder: (context, state) =>
                          const CarBookingHistoryScreen(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        // Tab 1: Orders
        StatefulShellBranch(
          navigatorKey: ordersNavigatorKey,
          routes: [
            GoRoute(
              path: '/orders',
              builder: (context, state) => const OrdersScreen(),
            ),
          ],
        ),
        // Tab 2: Earnings
        StatefulShellBranch(
          navigatorKey: earningsNavigatorKey,
          routes: [
            GoRoute(
              path: '/earnings',
              builder: (context, state) => const EarningsScreen(),
              routes: [
                GoRoute(
                  path: 'earning_details',
                  builder: (context, state) => const EarningDetailsScreen(),
                ),
              ],
            ),
          ],
        ),
        // Tab 3: Profile
        StatefulShellBranch(
          navigatorKey: profileNavigatorKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'edit_profile',
                  builder: (context, state) => const EditProfileScreen(),
                ),
                GoRoute(
                  path: 'settings',
                  builder: (context, state) => const SettingsScreen(),
                ),
                GoRoute(
                  path: 'help_support',
                  builder: (context, state) => const HelpSupportScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

