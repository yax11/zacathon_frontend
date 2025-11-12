import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';

class ReceiptView extends StatelessWidget {
  const ReceiptView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final transactionType = args['type'] as String? ?? 'Inter-Bank Transfer';
    final date = args['date'] as DateTime? ?? DateTime.now();
    final debitAccount = args['account'] as String? ?? 'FINNSTART INNOVATION LAB(1217***311)';
    final creditAccount = args['creditAccount'] as String? ?? args['mobileNumber'] as String? ?? '8101854615';
    final beneficiary = args['beneficiary'] as String? ?? args['mobileNumber'] as String? ?? 'TITUS TUKURAH YAKUBU';
    final bank = args['bank'] as String? ?? args['operator'] as String? ?? 'OPAY';
    final narration = args['narration'] as String? ?? 'Done';
    final status = args['status'] as String? ?? 'Success';
    final amount = args['amount'] as String? ?? 'N200.00';

    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(date);
    final formattedDateTime = DateFormat('dd-MMM-yyyy hh:mm:ss a').format(date);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Receipt',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 32,
              height: 32,
              color: AppColors.background,
              child: Image.asset(
                'assets/icons/fav.png',
                width: 32,
                height: 32,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Receipt Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.zero,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TRANSACTION RECEIPT',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                'Z',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'ZENITH',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Date Bar
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                    ),
                    child: Text(
                      formattedDate,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Transaction Details
                  _buildDetailRow('Transaction Type', transactionType),
                  _buildDetailRow('Transaction Date', formattedDateTime),
                  _buildDetailRow('Debit Account', debitAccount),
                  _buildDetailRow('Credit Account', creditAccount),
                  _buildDetailRow('Beneficiary', beneficiary),
                  _buildDetailRow('Bank', bank),
                  _buildDetailRow('Narration', narration),
                  _buildDetailRow('Status', status),
                  const SizedBox(height: 8),
                  _buildDetailRow('Amount', amount, isAmount: true),
                  const SizedBox(height: 20),

                  // Disclaimer
                  const Text(
                    'DISCLAIMER',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your transaction has been successfully processed. Note, however, that completion of any transfer may be affected by other factors including but not limited to transmission errors, incomplete information, fluctuations on the network/internet, interruptions, glitch, delayed information or other matters beyond the Bank\'s control which may impact on the transaction and for which the Bank will not be liable. All transactions are subject to Zenith Bank confirmation and fraud proof verification.',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Contact Bar
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                    ),
                    child: const Text(
                      'For any other assistance, kindly contact us on zenithdirect@zenithbank.com and 234-1-2787000',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 10,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement save receipt
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textSecondary,
                        foregroundColor: AppColors.textWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: const Text(
                        'SAVE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement share receipt
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: const Text(
                        'SHARE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isAmount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: isAmount ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

