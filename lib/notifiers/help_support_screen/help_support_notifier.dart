import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── FAQ Data Model ──
class FaqItem {
  final String question;
  final String answer;
  final String category;

  const FaqItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}

// ── State ──
class HelpSupportState {
  final String searchQuery;
  final int selectedCategoryIndex;
  final List<FaqItem> allFaqs;
  final List<FaqItem> filteredFaqs;

  const HelpSupportState({
    this.searchQuery = '',
    this.selectedCategoryIndex = 0,
    required this.allFaqs,
    required this.filteredFaqs,
  });

  HelpSupportState copyWith({
    String? searchQuery,
    int? selectedCategoryIndex,
    List<FaqItem>? allFaqs,
    List<FaqItem>? filteredFaqs,
  }) {
    return HelpSupportState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryIndex: selectedCategoryIndex ?? this.selectedCategoryIndex,
      allFaqs: allFaqs ?? this.allFaqs,
      filteredFaqs: filteredFaqs ?? this.filteredFaqs,
    );
  }
}

// ── Categories ──
const List<String> helpCategories = [
  'All',
  'Payments',
  'Orders',
  'Account',
  'Navigation',
  'Safety',
];

// ── Notifier ──
class HelpSupportNotifier extends Notifier<HelpSupportState> {
  static const List<FaqItem> _defaultFaqs = [
    FaqItem(
      question: 'How are my earnings calculated?',
      answer:
          'Earnings are calculated based on base pay, distance traveled, and time taken. Tips and surge pricing bonuses are added on top of the base calculation.',
      category: 'Payments',
    ),
    FaqItem(
      question: 'When do I get my payouts?',
      answer:
          'Payouts are processed weekly every Monday. You can also request an instant payout for a small fee of ₹5 per transaction.',
      category: 'Payments',
    ),
    FaqItem(
      question: 'What if I can\'t reach the customer?',
      answer:
          'If you cannot reach the customer, try calling them twice. If they don\'t answer, wait at the location for 5 minutes. After 5 minutes, you can use the \'Report Issue\' button to cancel the order without penalty.',
      category: 'Orders',
    ),
    FaqItem(
      question: 'The restaurant is taking too long.',
      answer:
          'If the restaurant takes more than 15 minutes beyond the expected pickup time, you can unassign yourself from the delivery in the \'Report Issue\' menu.',
      category: 'Orders',
    ),
    FaqItem(
      question: 'How do I update my profile details?',
      answer:
          'Go to Profile → Edit Profile to update your name, phone number, email, and vehicle information. Changes are reflected instantly.',
      category: 'Account',
    ),
    FaqItem(
      question: 'How does the navigation system work?',
      answer:
          'Our in-app navigation uses real-time GPS routing. It automatically detects the fastest route and provides turn-by-turn directions with live traffic updates.',
      category: 'Navigation',
    ),
    FaqItem(
      question: 'What should I do in an emergency?',
      answer:
          'Use the Emergency SOS button below to immediately contact our safety team. You can also call local emergency services directly from the app.',
      category: 'Safety',
    ),
    FaqItem(
      question: 'Can I change my delivery zone?',
      answer:
          'Yes, you can update your preferred delivery zone from Settings → Delivery Preferences. Changes take effect from your next shift.',
      category: 'Navigation',
    ),
    FaqItem(
      question: 'How do I report a safety issue?',
      answer:
          'Tap the SOS button or go to Help → Report Safety Issue. Our safety team responds within 2 minutes to all critical reports, 24/7.',
      category: 'Safety',
    ),
    FaqItem(
      question: 'Why was my account temporarily suspended?',
      answer:
          'Accounts may be suspended due to low ratings, policy violations, or document expiry. Check your email for details and contact support to resolve it.',
      category: 'Account',
    ),
  ];

  @override
  HelpSupportState build() {
    return HelpSupportState(
      allFaqs: _defaultFaqs,
      filteredFaqs: _defaultFaqs,
    );
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void selectCategory(int index) {
    state = state.copyWith(selectedCategoryIndex: index);
    _applyFilters();
  }

  void _applyFilters() {
    final query = state.searchQuery.toLowerCase();
    final category = helpCategories[state.selectedCategoryIndex];

    List<FaqItem> filtered = state.allFaqs;

    // Category filter
    if (category != 'All') {
      filtered = filtered.where((f) => f.category == category).toList();
    }

    // Search filter
    if (query.isNotEmpty) {
      filtered = filtered
          .where((f) =>
              f.question.toLowerCase().contains(query) ||
              f.answer.toLowerCase().contains(query))
          .toList();
    }

    state = state.copyWith(filteredFaqs: filtered);
  }
}
