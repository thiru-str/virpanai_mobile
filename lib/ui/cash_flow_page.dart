import 'package:flutter/material.dart';
import 'package:waioz/utility/AppColors.dart';

class CashFlowWidget extends StatelessWidget {
  const CashFlowWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cash Flow',
            style:  Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold,fontSize: 30),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCashFlowCard(
                  gradientStartColor: AppColors.gradient1,
                  gradientEndColor: Colors.white,
                  title: 'Cash Fund',
                  amount: '₹ 100',
                  icon: Icons.account_balance_wallet,
                  iconColor: AppColors.gradientIcon1,
                ),
                _buildCashFlowCard(
                  gradientStartColor: AppColors.gradient2,
                  gradientEndColor: Colors.white,
                  title: 'Box',
                  amount: '₹ 100',
                  icon: Icons.inbox,
                  iconColor: AppColors.gradientIcon2,
                ),
                _buildCashFlowCard(
                  gradientStartColor: AppColors.gradient3,
                  gradientEndColor: Colors.white,
                  title: 'Total',
                  amount: '₹ 100',
                  icon: Icons.savings,
                  iconColor: AppColors.gradientIcon3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashFlowCard({
    required Color gradientStartColor,
    required Color gradientEndColor,
    required String title,
    required String amount,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      width: 300,
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientStartColor, gradientEndColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
