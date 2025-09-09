import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/neft_transaction_response.dart';
import 'package:waioz/model/public_detail_model.dart';
import 'package:waioz/ui/widgets/no_orders_widget.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_config.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/image_fallback_widget.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

import 'widgets/common_header_app_bar.dart';
import 'widgets/neft_transaction_bottom_sheet.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final String orderID;

  const TransactionDetailsScreen({Key? key, required this.orderID})
      : super(key: key);

  @override
  _TransactionDetailsScreenState createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  UpiDetails? upiDetails;
  NeftTransactionResponse? transactionResponse;

  @override
  void initState() {
    super.initState();
    fetchBankAndTransactionDetails();
  }

  void handleNEFTTransactionSubmit(Map<String, dynamic> data) async {
    data['order_id'] = widget.orderID;
    await ApiService().submitNEFTTransaction(context, data);
    fetchBankAndTransactionDetails();
  }

  Future<void> fetchBankAndTransactionDetails() async {
    final publicDetails = await SharedPreferencesUtil().getPublicDetails();
    final neftTransactionDetails =
        await ApiService().getNEFTTransaction(context, widget.orderID);
    setState(() {
      upiDetails = publicDetails?.upiDetails;
      transactionResponse = neftTransactionDetails;
    });
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return NeftTransactionBottomSheet(
            onSubmit: handleNEFTTransactionSubmit);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonHeaderAppBar(
        title: AppStrings.transation_details,
        onBackTap: () => Navigator.of(context).pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //_buildTransactionInfoCard(),
            _buildQrCard(),
            const SizedBox(height: 20),
            transactionResponse?.neftPayment?.isNotEmpty ?? false
                ? Expanded(
                    child: ListView.builder(
                      itemCount: transactionResponse?.neftPayment?.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildTransactionStatus(
                              transactionResponse?.neftPayment?[index]),
                        );
                      },
                    ),
                  )
                : _buildEmptyState(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showBottomSheet,
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTransactionInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
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
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: _buildInfoRow('${AppStrings.name}:',
                      upiDetails?.upiId ?? "")),
              const SizedBox(width: 10),
              Expanded(
                  child: _buildInfoRow(
                      '${AppStrings.bank_name}:', upiDetails?.upiNotes ?? "")),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: _buildInfoRow('${AppStrings.account_no}:',
                      '')),
              const SizedBox(width: 10),
              Expanded(
                  child: _buildInfoRow(
                      '${AppStrings.IFSC_code}:','')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQrCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
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
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            AppConfig.appName,
            style: FontUtils.primaryFontStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          // QR Code
          Visibility(
            visible: (upiDetails?.upiId??'').isNotEmpty,
            child: QrImageView(
              data: upiDetails?.upiId??'',
              version: QrVersions.auto,
              size: 180.0,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          // UPI ID row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "UPI ID: ",
                  style: FontUtils.primaryFontStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  upiDetails?.upiId??'',
                  style: FontUtils.primaryFontStyle(color: Colors.black),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: upiDetails?.upiId??''));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("UPI ID copied!")),
                    );
                  },
                  child: const Icon(Icons.copy, size: 16, color: Colors.black),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          if (upiDetails?.upiNotes != null && (upiDetails?.upiNotes??'').isNotEmpty)
            Text(
              upiDetails?.upiNotes??'',
              style: FontUtils.primaryFontStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FontUtils.primaryFontStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style:
              FontUtils.primaryFontStyle(color: Colors.white, fontSize: 14.0),
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
      ],
    );
  }

  Widget _buildTransactionStatus(NeftPayment? neftPayment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            color: Colors.white,
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    backgroundColor:
                        Colors.transparent, // Makes the background transparent
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context), // Close on tap
                      child: InteractiveViewer(
                        panEnabled: false, // Disable panning for better UX
                        boundaryMargin: EdgeInsets.all(0),
                        child: (neftPayment?.image == null ||
                                (neftPayment?.image?.isEmpty ?? false))
                            ? const ImageFallbackWidget(h: 120, w: 120)
                            : CachedNetworkImage(
                                imageUrl: neftPayment!.image!,
                                fit: BoxFit.contain,
                                errorWidget: (context, url, error) =>
                                   const ImageFallbackWidget(h: 120, w: 120),
                              ),
                      ),
                    ),
                  ),
                );
              },
              child: (neftPayment?.image == null ||
                      (neftPayment?.image?.isEmpty ?? false))
                  ?const ImageFallbackWidget(h: 120, w: 120)
                  : CachedNetworkImage(
                      imageUrl: neftPayment!.image!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>const ImageFallbackWidget(
                        h: 120,
                        w: 120,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.customer_summery,
                  style:
                      FontUtils.primaryFontStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  neftPayment?.description ?? "",
                  style: FontUtils.primaryFontStyle(color: AppColors.textColor),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 50),
          Image.asset(
            AppAssets.ic_no_transaction,
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.no_payment_yet,
            style: FontUtils.primaryFontStyle(
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
