import 'package:flutter/material.dart';
import '../utils/app_color.dart';

class TransactionFilterBar extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const TransactionFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = ['Semua', 'Pemasukan', 'Pengeluaran'];

    return Row(
      children: filters.map((filter) {
        bool selected = selectedFilter == filter;
        return Expanded(
          child: GestureDetector(
            onTap: () => onFilterChanged(filter),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected ? AppTheme.purplePastel : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : AppTheme.pinkAccent.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppTheme.purplePastel.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  filter == 'Semua'
                      ? "✨ Semua"
                      : (filter == 'Pemasukan' ? "📥 Masuk" : "📤 Keluar"),
                  style: TextStyle(
                    fontSize: 12,
                    color: selected ? Colors.white : AppTheme.textDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}