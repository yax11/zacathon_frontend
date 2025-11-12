import 'package:flutter/material.dart';
import '../../app/core/theme/app_colors.dart';
import '../../app/core/utils/helpers.dart';

enum TransactionType { credit, debit }

class TransactionItem {
  const TransactionItem({
    required this.id,
    required this.type,
    required this.name,
    required this.transactionType,
    required this.amount,
    required this.date,
  });

  final String id;
  final TransactionType type;
  final String name;
  final String transactionType;
  final double amount;
  final String date;
}

class RecentTransactions extends StatelessWidget {
  const RecentTransactions({
    super.key,
    this.transactions = _defaultTransactions,
    this.onViewAll,
  });

  final List<TransactionItem> transactions;
  final VoidCallback? onViewAll;

  static const List<TransactionItem> _defaultTransactions = [
    TransactionItem(
      id: '1',
      type: TransactionType.debit,
      name: 'abraham joseph',
      transactionType: 'P2P',
      amount: 21.00,
      date: '09 November, 2025',
    ),
    TransactionItem(
      id: '2',
      type: TransactionType.credit,
      name: 'NGN to USD',
      transactionType: 'Swap',
      amount: 20000.00,
      date: '29 October, 2025',
    ),
    TransactionItem(
      id: '3',
      type: TransactionType.debit,
      name: 'Jane Smith',
      transactionType: 'Transfer',
      amount: 5000.00,
      date: '25 October, 2025',
    ),
    TransactionItem(
      id: '4',
      type: TransactionType.credit,
      name: 'Salary Payment',
      transactionType: 'Credit',
      amount: 150000.00,
      date: '01 October, 2025',
    ),
  ];

  Color _statusColor(TransactionType type) {
    return type == TransactionType.credit ? AppColors.success : AppColors.error;
  }

  IconData _statusIcon(TransactionType type) {
    return type == TransactionType.credit
        ? Icons.south_west_rounded
        : Icons.north_east_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent transactions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                ),
                child: const Text(
                  'See all',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: List.generate(transactions.length, (index) {
                final transaction = transactions[index];
                final color = _statusColor(transaction.type);
                final icon = _statusIcon(transaction.type);
                final amountText = Helpers.formatCurrency(transaction.amount);

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transaction.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${transaction.transactionType} • ${transaction.date}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${transaction.type == TransactionType.debit ? '-' : '+'}$amountText',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: transaction.type == TransactionType.debit
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index != transactions.length - 1)
                      const Divider(
                        height: 1,
                        thickness: 0.5,
                        color: AppColors.borderLight,
                      ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

