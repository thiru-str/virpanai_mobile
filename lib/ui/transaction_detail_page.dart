import 'package:flutter/material.dart';
import 'package:waioz/ui/widgets/no_orders_widget.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';

import 'widgets/common_header_app_bar.dart';
import 'widgets/neft_transaction_bottom_sheet.dart';

class TransactionDetailsScreen extends StatefulWidget {
  @override
  _TransactionDetailsScreenState createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  List<String> transactionIds = [

  ];

  void _addTransaction(String transactionId) {
    if (transactionId.isNotEmpty) {
      setState(() {
        transactionIds.add(transactionId);
      });
    }
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return NeftTransactionBottomSheet(onSubmit: _addTransaction);
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonHeaderAppBar(
        title: AppStrings.transation_details,
        onBackTap: () {
          Navigator.of(context).pop();
        },
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTransactionInfoCard(),
            SizedBox(height: 20),
            (transactionIds.length != 0) ?
            Expanded(
              child: ListView.builder(
                itemCount: transactionIds.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildTransactionStatus(transactionIds[index]),
                  );
                },
              ),
            ):
            _buildEmptyState(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showBottomSheet,
        backgroundColor: AppColors.primary,
        shape: CircleBorder(), // Ensures the button is round
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTransactionInfoCard() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [AppColors.primary, Colors.deepPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildInfoRow('Name:', 'Rajesh Kumar')),
              SizedBox(width: 10),
              Expanded(child: _buildInfoRow('Bank Name:', 'State Bank of India')),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildInfoRow('Account No:', '123456789012')),
              SizedBox(width: 10),
              Expanded(child: _buildInfoRow('IFSC Code:', 'SBIN0000456')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: FontUtils.circularStdStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0)),
        SizedBox(height: 2),
        Text(value,
            style: FontUtils.circularStdStyle(
                color: Colors.white, fontSize: 14.0),
            softWrap: true,
            overflow: TextOverflow.visible),
      ],
    );
  }

  Widget _buildTransactionStatus(String transactionId) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200], // Row background color
        borderRadius: BorderRadius.circular(12), // Border radius for the entire row
      ),
      child: Row(
        children: [
          Container(
            color: Colors.white, // Set the image background to white
            child: Image.asset(
              'images/welcome_bg.png',
              width: 60,
              height: 60,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NEFT Transaction ID',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(transactionId),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center( // Ensures both vertical and horizontal centering
      child: Column(
        children: [
          SizedBox(height: 50),
          Image.asset(
            AppAssets.ic_no_transaction, // Your empty state image
            width: 120,
            height: 120,
          ),
          SizedBox(height: 10),
          Text(
            "No Payment Yet",
            style: FontUtils.circularStdStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

}
