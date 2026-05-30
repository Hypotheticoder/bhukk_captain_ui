import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class _Category {
  final String label;
  final IconData icon;
  final Color color;
  final String? route;
  const _Category(this.label, this.icon, this.color, {this.route});
}

class ServiceCategoryCard extends StatelessWidget {
  const ServiceCategoryCard({super.key});

  static const _categories = <_Category>[
    // _Category('Ambulance', Icons.local_hospital_rounded, AppColors.ambulance,
    //     route: '/home/ambulance'),
    _Category(
      'Parcel',
      Icons.inventory_2_rounded,
      AppColors.parcel,
      route: '/home/parcel',
    ),
    // _Category(
    //     'Heavy Delivery', Icons.local_shipping_rounded, AppColors.heavyHaul,
    //     route: '/home/heavy_delivery'),
    _Category(
      'Car Booking',
      Icons.directions_car_rounded,
      AppColors.carBooking,
      route: '/home/car_booking',
    ),
    // _Category(
    //   'Food Delivery',
    //   Icons.restaurant_rounded,
    //   AppColors.foodDelivery,
    //   route: '/home/food_delivery',
    // ),
    // _Category('Beverages', Icons.local_cafe_rounded, AppColors.beverages,
    //     route: '/home/beverages'),
    // _Category(
    //   'Cosmatics',
    //   Icons.face_retouching_natural_rounded,
    //   AppColors.purple,
    //   route: '/home/cosmatics',
    // ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          return _buildPill(context, cat, colors);
        },
      ),
    );
  }

  Widget _buildPill(BuildContext context, _Category cat, C colors) {
    return GestureDetector(
      onTap: cat.route != null ? () => context.push(cat.route!) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md + 2,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: cat.color.withAlpha(colors.isDark ? 35 : 22),
          borderRadius: AppRadius.pillAll,
          border: Border.all(
            color: cat.color.withAlpha(colors.isDark ? 60 : 45),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(cat.icon, color: cat.color, size: 16),
            const SizedBox(width: 6),
            Text(
              cat.label,
              style: AppTextStyles.caption.copyWith(
                color: cat.color,
                fontWeight: FontWeight.w600,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
