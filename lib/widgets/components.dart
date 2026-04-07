import 'package:flutter/material.dart';
import 'package:duitkuu/theme/app_theme.dart';
import 'package:duitkuu/utils/app_formatter.dart';

// Alias warna putih
const Color white = AppTheme.white;

/// Card statistik dengan ikon
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor = AppTheme.primaryBlue,
    this.backgroundColor = const Color(0xFFE0E7FF),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.mediumGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(title, style: AppTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.headlineSmall.copyWith(color: iconColor),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Expense item card
class ExpenseItemCard extends StatelessWidget {
  final String itemName;
  final int price;
  final String category;
  final String date;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ExpenseItemCard({
    Key? key,
    required this.itemName,
    required this.price,
    required this.category,
    required this.date,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.mediumGray),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemName,
                        style: AppTheme.titleLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          CategoryBadge(category: category),
                          const SizedBox(width: 8),
                          Text(
                            AppFormatter.formatDate(date),
                            style: AppTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(child: const Text('Edit'), onTap: onEdit),
                    PopupMenuItem(
                      child: const Text(
                        'Hapus',
                        style: TextStyle(color: AppTheme.errorRed),
                      ),
                      onTap: onDelete,
                    ),
                  ],
                  child: const Icon(Icons.more_vert),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              AppFormatter.formatCurrency(price),
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Category badge
class CategoryBadge extends StatelessWidget {
  final String category;

  const CategoryBadge({Key? key, required this.category}) : super(key: key);

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Makanan':
        return const Color(0xFFFECDCA);
      case 'Minuman':
        return const Color(0xFFFEE4DD);
      case 'Transport':
        return const Color(0xFFFEDDDF);
      case 'Belanja':
        return const Color(0xFFF0E7FF);
      case 'Kebutuhan':
        return const Color(0xFFE0F2FE);
      case 'Hiburan':
        return const Color(0xFFFEF3DD);
      case 'Lainnya':
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _getCategoryTextColor(String category) {
    switch (category) {
      case 'Makanan':
        return const Color(0xFFC41C3B);
      case 'Minuman':
        return const Color(0xFFDA5D1F);
      case 'Transport':
        return const Color(0xFFD41C1E);
      case 'Belanja':
        return const Color(0xFF6B21A8);
      case 'Kebutuhan':
        return const Color(0xFF0369A1);
      case 'Hiburan':
        return const Color(0xFFB45309);
      case 'Lainnya':
      default:
        return const Color(0xFF4B5563);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getCategoryColor(category),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _getCategoryTextColor(category),
        ),
      ),
    );
  }
}

/// Card highlight untuk dashboard
class HighlightCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color bgColor;
  final Color textColor;

  const HighlightCard({
    Key? key,
    required this.title,
    required this.value,
    required this.subtitle,
    this.bgColor = AppTheme.primaryBlue,
    this.textColor = white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgColor, bgColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }
}

/// Section header
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;

  const SectionHeader({
    Key? key,
    required this.title,
    this.actionText,
    this.onActionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTheme.headlineSmall),
        if (actionText != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionText!,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
