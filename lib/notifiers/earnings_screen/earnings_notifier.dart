import 'package:bhukkdelivery/notifiers/orders_screen/orders_notifier.dart';
import 'package:bhukkdelivery/providers/profile/profile_provider.dart';
import 'package:bhukkdelivery/services/api/earnings_service.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Earning transaction entry ──
class EarningTransaction {
  final String id;
  final String title;
  final String date;
  final double amount;
  final String type; // 'trip', 'payout', 'fee', 'bonus', 'tip'
  final String paymentMode; // 'cod', 'online'
  final String serviceType;

  const EarningTransaction({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.type,
    this.paymentMode = 'online',
    this.serviceType = 'food',
  });

  factory EarningTransaction.fromJson(Map<String, dynamic> json) {
    // Backend sends 'transaction_type' (e.g. COMMISSION, CASH_COLLECTED)
    final rawType = (json['transaction_type'] ?? json['type'] ?? 'trip')
        .toString()
        .toLowerCase();

    // Normalize backend transaction types to UI icon categories
    String normalizedType;
    switch (rawType) {
      case 'cash_collected':
        normalizedType = 'payout';
        break;
      case 'earning':
      case 'order_payment':
      case 'ride_payment':
      case 'parcel_payment':
      case 'payout':
      case 'payment':
        normalizedType = 'payout';
        break;
      case 'tip':
        normalizedType = 'tip';
        break;
      case 'bonus':
      case 'incentive':
      case 'surge':
        normalizedType = 'bonus';
        break;
      case 'commission':
      case 'platform_fee':
      case 'penalty':
      case 'settlement':
        normalizedType = 'fee';
        break;
      default:
        normalizedType = 'trip';
    }

    final paymentModeRaw =
        (json['payment_mode'] ?? json['payment_method'] ?? 'online')
            .toString()
            .toLowerCase();
    String paymentMode;
    if (paymentModeRaw.contains('cod') || paymentModeRaw.contains('cash')) {
      paymentMode = 'cod';
    } else {
      paymentMode = 'online';
    }

    return EarningTransaction(
      id: (json['id'] ?? json['transaction_id'])?.toString() ?? '',
      title: json['title'] ?? json['description'] ?? 'Transaction',
      date: json['date'] ?? json['created_at'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      type: normalizedType,
      paymentMode: paymentMode,
      serviceType: json['service_type'] ?? 'food',
    );
  }
}

// ── Pie slice from backend ──
class IncomePieSlice {
  final String category;
  final double amount;
  final double percentage;

  const IncomePieSlice({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  factory IncomePieSlice.fromJson(Map<String, dynamic> json) {
    return IncomePieSlice(
      category: json['category']?.toString() ?? 'Other',
      amount: (json['amount'] ?? 0.0).toDouble(),
      percentage: (json['percentage'] ?? 0.0).toDouble(),
    );
  }
}

// ── GST / Earning Config from backend ──
class EarningConfigItem {
  final String label;
  final double value;
  final String type; // 'percentage', 'flat', 'per_km'
  final String? description;

  const EarningConfigItem({
    required this.label,
    required this.value,
    required this.type,
    this.description,
  });

  factory EarningConfigItem.fromJson(Map<String, dynamic> json) {
    return EarningConfigItem(
      label: json['label']?.toString() ?? json['name']?.toString() ?? '',
      value: (json['value'] ?? json['amount'] ?? json['rate'] ?? 0.0).toDouble(),
      type: json['type']?.toString() ?? json['charge_type']?.toString() ?? 'percentage',
      description: json['description']?.toString() ?? json['info']?.toString(),
    );
  }

  String get displayValue {
    switch (type) {
      case 'percentage':
        return '${value.toStringAsFixed(1)}%';
      case 'per_km':
        return '₹${value.toStringAsFixed(1)}/km';
      case 'flat':
      default:
        return '₹${value.toStringAsFixed(0)}';
    }
  }
}

class EarningConfig {
  final String vehicleType;
  final String vehicleLabel;
  final double baseFare;
  final double perKmRate;
  final double platformCommissionAmount;
  final double gstPercent;
  final double tdsPercent;
  final double insuranceLevy;
  final List<EarningConfigItem> breakdown;
  final String? note;

  const EarningConfig({
    required this.vehicleType,
    required this.vehicleLabel,
    this.baseFare = 0,
    this.perKmRate = 0,
    this.platformCommissionAmount = 0,
    this.gstPercent = 0,
    this.tdsPercent = 0,
    this.insuranceLevy = 0,
    this.breakdown = const [],
    this.note,
  });

  factory EarningConfig.fromJson(Map<String, dynamic> json) {
    final rawBreakdown = json['breakdown'] ?? json['charges'] ?? json['items'] ?? [];
    List<EarningConfigItem> items = [];
    if (rawBreakdown is List) {
      items = rawBreakdown
          .map((e) => EarningConfigItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return EarningConfig(
      vehicleType: json['service_type']?.toString() ?? json['vehicle_type']?.toString() ?? '',
      vehicleLabel: json['service_type']?.toString() ?? json['vehicle_label']?.toString() ?? '',
      baseFare: (json['base_fare'] ?? json['minimum_fare'] ?? 0.0).toDouble(),
      perKmRate: (json['per_km_rate'] ?? 0.0).toDouble(),
      platformCommissionAmount: (json['platform_commission'] ?? 0.0).toDouble(),
      gstPercent: (json['gst_percentage'] ?? 0.0).toDouble(),
      tdsPercent: (json['tds_percent'] ?? 0.0).toDouble(),
      insuranceLevy: (json['insurance_levy'] ?? 0.0).toDouble(),
      breakdown: items,
      note: json['note']?.toString(),
    );
  }

  bool get isEmpty => vehicleType.isEmpty && breakdown.isEmpty && baseFare == 0;
}

// ── Earning state ──
class EarningsState {
  final int selectedServiceIndex;
  final double todayEarnings;
  final double netBalance;
  final double cashInHand;
  final double commissionOwed;
  final double thisWeekEarnings;
  final double lastWeekEarnings;
  final double thisMonthEarnings;
  final double tipsEarnings;
  final double bonusEarnings;
  final double monthGrowth;
  final double rideEarnings;
  final double parcelEarnings;
  final double medicineEarnings;
  final double codEarnings; // Total COD collections
  final double onlineEarnings; // Total online payouts
  final List<double> weeklyBarData;
  final List<EarningTransaction> transactions;
  final List<IncomePieSlice> incomePie; // Backend pie data (Ride/Parcel split)
  final List<String> availableFilters;
  final EarningConfig? earningConfig;
  final bool isLoading;
  final String? errorMessage;

  const EarningsState({
    this.selectedServiceIndex = 0,
    this.todayEarnings = 0,
    this.netBalance = 0,
    this.cashInHand = 0,
    this.commissionOwed = 0,
    this.thisWeekEarnings = 0,
    this.lastWeekEarnings = 0,
    this.thisMonthEarnings = 0,
    this.tipsEarnings = 0,
    this.bonusEarnings = 0,
    this.monthGrowth = 0,
    this.rideEarnings = 0,
    this.parcelEarnings = 0,
    this.medicineEarnings = 0,
    this.codEarnings = 0,
    this.onlineEarnings = 0,
    this.weeklyBarData = const [0, 0, 0, 0, 0, 0, 0],
    this.transactions = const [],
    this.incomePie = const [],
    this.availableFilters = const ['All'],
    this.earningConfig,
    this.isLoading = false,
    this.errorMessage,
  });

  EarningsState copyWith({
    int? selectedServiceIndex,
    double? todayEarnings,
    double? netBalance,
    double? cashInHand,
    double? commissionOwed,
    double? thisWeekEarnings,
    double? lastWeekEarnings,
    double? thisMonthEarnings,
    double? tipsEarnings,
    double? bonusEarnings,
    double? monthGrowth,
    double? rideEarnings,
    double? parcelEarnings,
    double? medicineEarnings,
    double? codEarnings,
    double? onlineEarnings,
    List<double>? weeklyBarData,
    List<EarningTransaction>? transactions,
    List<IncomePieSlice>? incomePie,
    List<String>? availableFilters,
    EarningConfig? earningConfig,
    bool? isLoading,
    String? errorMessage,
  }) {
    return EarningsState(
      selectedServiceIndex: selectedServiceIndex ?? this.selectedServiceIndex,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      netBalance: netBalance ?? this.netBalance,
      cashInHand: cashInHand ?? this.cashInHand,
      commissionOwed: commissionOwed ?? this.commissionOwed,
      rideEarnings: rideEarnings ?? this.rideEarnings,
      parcelEarnings: parcelEarnings ?? this.parcelEarnings,
      medicineEarnings: medicineEarnings ?? this.medicineEarnings,
      codEarnings: codEarnings ?? this.codEarnings,
      onlineEarnings: onlineEarnings ?? this.onlineEarnings,
      thisWeekEarnings: thisWeekEarnings ?? this.thisWeekEarnings,
      lastWeekEarnings: lastWeekEarnings ?? this.lastWeekEarnings,
      thisMonthEarnings: thisMonthEarnings ?? this.thisMonthEarnings,
      tipsEarnings: tipsEarnings ?? this.tipsEarnings,
      bonusEarnings: bonusEarnings ?? this.bonusEarnings,
      monthGrowth: monthGrowth ?? this.monthGrowth,
      weeklyBarData: weeklyBarData ?? this.weeklyBarData,
      transactions: transactions ?? this.transactions,
      incomePie: incomePie ?? this.incomePie,
      availableFilters: availableFilters ?? this.availableFilters,
      earningConfig: earningConfig ?? this.earningConfig,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  String get selectedServiceLabel => availableFilters[selectedServiceIndex];
  Color get selectedServiceColor {
    final key = selectedServiceLabel.toLowerCase();
    if (key == 'all') return AppColors.primary;
    if (key == 'ride') return AppColors.primary;
    if (key == 'parcel') return AppColors.parcel;
    return serviceMetaMap[key]?.color ?? AppColors.primary;
  }

  IconData get selectedServiceIcon {
    final key = selectedServiceLabel.toLowerCase();
    if (key == 'all') return Icons.apps_rounded;
    if (key == 'ride') return Icons.electric_moped_rounded;
    if (key == 'parcel') return Icons.inventory_2_rounded;
    return serviceMetaMap[key]?.icon ?? Icons.apps_rounded;
  }
}

// ── Notifier ──
class EarningsNotifier extends Notifier<EarningsState> {
  @override
  EarningsState build() {
    final vehicleType = ref.watch(
      profileProvider.select((p) => p?.vehicleType ?? 'bike'),
    );

    final filters = ['All'];
    final isCar =
        vehicleType.contains('car') ||
        vehicleType.contains('cab') ||
        vehicleType.contains('taxi');
    final isTruck =
        vehicleType.contains('truck') ||
        vehicleType.contains('van') ||
        vehicleType.contains('lorry') ||
        vehicleType.contains('mini truck') ||
        vehicleType.contains('wheeler') ||
        vehicleType.contains('3_wheeler');

    if (isCar) {
      filters.add('Ride');
    } else if (isTruck) {
      filters.addAll(['Parcel', 'Medicine']);
    } else {
      filters.addAll(['Ride', 'Parcel', 'Medicine']);
    }

    // Start with default state and fetch
    Future.microtask(() => _fetchEarnings());

    return EarningsState(isLoading: true, availableFilters: filters);
  }

  Future<void> _fetchEarnings() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final currentService = state.availableFilters[state.selectedServiceIndex];
      final vehicleType = ref.read(profileProvider.select((p) => p?.vehicleType ?? 'bike'));

      // Fetch earnings dashboard + earning config in parallel
      final results = await Future.wait([
        EarningsService.getFullEarningsDashboard(serviceType: currentService),
        EarningsService.getEarningConfig(vehicleType: vehicleType),
      ]);

      final dashboardData = results[0];
      final configData = results[1];

      final earningConfig = configData.isNotEmpty ? EarningConfig.fromJson(configData) : null;
      debugPrint('[EarningsNotifier] Parallel API Data ($currentService): $dashboardData');
      debugPrint('[EarningsNotifier] Earning Config ($vehicleType): $configData');

      final balances = Map<String, dynamic>.from(
        dashboardData['balances'] ?? {},
      );
      final statement = dashboardData['statement'] as List? ?? [];
      final analytics = Map<String, dynamic>.from(
        dashboardData['analytics'] ?? {},
      );

      // 1. Parse Transactions
      final txns = statement.map((t) {
        return EarningTransaction.fromJson(Map<String, dynamic>.from(t));
      }).toList();

      // 2. Compute COD vs Online from parsed transactions
      double codTotal = 0.0;
      double onlineTotal = 0.0;
      for (final t in txns) {
        if (t.type == 'fee') continue; // Skip commission deductions
        if (t.paymentMode == 'cod') {
          codTotal += t.amount;
        } else {
          onlineTotal += t.amount;
        }
      }

      // 3. Parse Weekly Bar Analytics
      final rawWeeklyBars =
          analytics['weekly_bar_data'] ?? analytics['weekly_bars'];
      var weeklyBars = List<double>.filled(7, 0.0);

      const dayMap = {
        'mon': 0,
        'tue': 1,
        'wed': 2,
        'thu': 3,
        'fri': 4,
        'sat': 5,
        'sun': 6,
        'monday': 0,
        'tuesday': 1,
        'wednesday': 2,
        'thursday': 3,
        'friday': 4,
        'saturday': 5,
        'sunday': 6,
      };

      if (rawWeeklyBars is List) {
        for (int i = 0; i < rawWeeklyBars.length; i++) {
          final item = rawWeeklyBars[i];
          if (item is Map) {
            final dayStr = item['day']?.toString().toLowerCase() ?? '';
            final amount = _toDouble(item['amount']);
            final dayIdx = dayMap[dayStr];

            if (dayIdx != null) {
              weeklyBars[dayIdx] = amount;
            } else if (i < 7) {
              weeklyBars[i] = amount;
            }
          } else {
            if (i < 7) weeklyBars[i] = _toDouble(item);
          }
        }
      }

      // 4. Compute thisWeekEarnings from bars (backend doesn't provide this field)
      final computedWeekTotal = weeklyBars.fold<double>(
        0.0,
        (sum, v) => sum + v,
      );

      // 5. Parse Income Pie from backend analytics
      final rawPie =
          analytics['income_pie'] ??
          analytics['pie_data'] ??
          analytics['income_split'];
      List<IncomePieSlice> pieSlices = [];
      if (rawPie is List && rawPie.isNotEmpty) {
        pieSlices = rawPie.map((p) {
          return IncomePieSlice.fromJson(Map<String, dynamic>.from(p));
        }).toList();
      } else {
        // Fallback: Generate from COD vs Online split if backend pie is empty
        final total = codTotal + onlineTotal;
        if (total > 0) {
          if (codTotal > 0) {
            pieSlices.add(
              IncomePieSlice(
                category: 'COD',
                amount: codTotal,
                percentage: (codTotal / total * 100),
              ),
            );
          }
          if (onlineTotal > 0) {
            pieSlices.add(
              IncomePieSlice(
                category: 'Online',
                amount: onlineTotal,
                percentage: (onlineTotal / total * 100),
              ),
            );
          }
        } else if (state.rideEarnings > 0 || state.parcelEarnings > 0 || state.medicineEarnings > 0) {
          // Alternative fallback: use service breakdown
          final sTotal = state.rideEarnings + state.parcelEarnings + state.medicineEarnings;
          if (state.rideEarnings > 0) {
            pieSlices.add(
              IncomePieSlice(
                category: 'Ride',
                amount: state.rideEarnings,
                percentage: (state.rideEarnings / sTotal * 100),
              ),
            );
          }
          if (state.parcelEarnings > 0) {
            pieSlices.add(
              IncomePieSlice(
                category: 'Parcel',
                amount: state.parcelEarnings,
                percentage: (state.parcelEarnings / sTotal * 100),
              ),
            );
          }
          if (state.medicineEarnings > 0) {
            pieSlices.add(
              IncomePieSlice(
                category: 'Medicine',
                amount: state.medicineEarnings,
                percentage: (state.medicineEarnings / sTotal * 100),
              ),
            );
          }
        }
      }

      final breakdown = (balances['breakdown'] is Map)
          ? Map<String, dynamic>.from(balances['breakdown'])
          : <String, dynamic>{};

      // 6. Update State with all parsed data
      state = state.copyWith(
        isLoading: false,
        todayEarnings: _toDouble(
          balances['today_earnings'] ?? balances['daily_earnings'],
        ),
        netBalance: _toDouble(balances['net_balance'] ?? balances['balance']),
        cashInHand: _toDouble(
          balances['cash_collected_today'] ?? balances['cash_in_hand'],
        ),
        commissionOwed: _toDouble(
          balances['amount_owed_to_company'] ?? balances['commission_owed'],
        ),

        rideEarnings: _toDouble(
          breakdown['ride_earnings'] ?? breakdown['ride'],
        ),
        parcelEarnings: _toDouble(
          breakdown['parcel_earnings'] ?? breakdown['parcel'],
        ),
        medicineEarnings: _toDouble(
          breakdown['medicine_earnings'] ?? breakdown['medicine'],
        ),
        codEarnings: codTotal,
        onlineEarnings: onlineTotal,

        thisWeekEarnings: computedWeekTotal,
        thisMonthEarnings: _toDouble(
          balances['this_month_earnings'] ?? balances['monthly_earnings'],
        ),
        tipsEarnings: _toDouble(balances['tips_earnings'] ?? balances['tips']),
        bonusEarnings: _toDouble(
          balances['bonus_earnings'] ?? balances['bonus'],
        ),
        monthGrowth: _toDouble(
          analytics['month_growth'] ?? analytics['growth_percentage'],
        ),
        lastWeekEarnings: _toDouble(balances['last_week_earnings']),
        weeklyBarData: weeklyBars,
        transactions: txns,
        incomePie: pieSlices,
        earningConfig: earningConfig,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Failed to sync wallet data. Please try again.",
      );
      debugPrint('[EarningsNotifier] Parallel Sync Error: $e');
    }
  }

  double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  void selectServiceFilter(int index) {
    state = state.copyWith(selectedServiceIndex: index);
    _fetchEarnings();
  }

  Future<void> refresh() async {
    await _fetchEarnings();
  }
}
