import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/neft_transaction_response.dart';
import 'package:waioz/model/public_detail_model.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/image_fallback_widget.dart';
import 'package:waioz/utility/shared_preferences_util.dart';
import 'package:waioz/utility/ui_typography.dart';

import 'widgets/common_header_app_bar.dart';
import 'widgets/neft_transaction_bottom_sheet.dart';

const Color _kScaffoldBg = Color(0xFFF9F9FB);

class TransactionDetailsScreen extends StatefulWidget {
  final String orderID;

  const TransactionDetailsScreen({Key? key, required this.orderID})
      : super(key: key);

  @override
  _TransactionDetailsScreenState createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  BankDetails? bankDetails;
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
      bankDetails = publicDetails?.bankDetails;
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
      backgroundColor: _kScaffoldBg,
      appBar: CommonHeaderAppBar(
        title: AppStrings.transation_details,
        onBackTap: () => Navigator.of(context).pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTransactionInfoCard(),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  AppStrings.customer_summery,
                  style: UiTypography.cardTitle()
                      .copyWith(fontSize: 18, letterSpacing: -0.2),
                ),
                const Spacer(),
                if (transactionResponse?.neftPayment?.isNotEmpty ?? false)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${transactionResponse?.neftPayment?.length}',
                      style: UiTypography.cardAction(color: AppColors.primary)
                          .copyWith(fontSize: 12.5),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            transactionResponse?.neftPayment?.isNotEmpty ?? false
                ? Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 90),
                      itemCount: transactionResponse?.neftPayment?.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildTransactionStatus(
                              transactionResponse?.neftPayment?[index]),
                        );
                      },
                    ),
                  )
                : Expanded(child: _buildEmptyState()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showBottomSheet,
        backgroundColor: AppColors.primary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Payment',
          style: FontUtils.primaryFontStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionInfoCard() {
    final infoItems = [
      _InfoItem('${AppStrings.name}:', bankDetails?.accountHolderName ?? ""),
      _InfoItem('${AppStrings.bank_name}:', bankDetails?.bankName ?? ""),
      _InfoItem('${AppStrings.account_no}:', bankDetails?.accountNumber ?? ""),
      _InfoItem('${AppStrings.IFSC_code}:', bankDetails?.ifscCode ?? ""),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.82)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.30),
            blurRadius: 22,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_outlined,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Bank Details',
                style: FontUtils.secondaryFontStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.85),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 16,
            children: infoItems
                .map(
                  (item) => SizedBox(
                    width: MediaQuery.sizeOf(context).width > 420
                        ? (MediaQuery.sizeOf(context).width - 66) / 2
                        : double.infinity,
                    child: _buildInfoRow(item.label, item.value),
                  ),
                )
                .toList(),
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
          style: FontUtils.secondaryFontStyle(
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w500,
            fontSize: 12.0,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: FontUtils.primaryFontStyle(
            color: Colors.white,
            fontSize: 15.0,
            fontWeight: FontWeight.w700,
          ),
          softWrap: true,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTransactionStatus(NeftPayment? neftPayment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
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
                  ? const ImageFallbackWidget(h: 60, w: 60)
                  : CachedNetworkImage(
                      imageUrl: neftPayment!.image!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          const ImageFallbackWidget(
                        h: 60,
                        w: 60,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.customer_summery,
                  style: UiTypography.cardTitle().copyWith(fontSize: 14.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  neftPayment?.description ?? "",
                  style: UiTypography.cardSubtitle(color: AppColors.textColor50),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AppAssets.ic_no_transaction,
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.no_payment_yet,
            style: UiTypography.cardTitle().copyWith(fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            'Add a payment using the button below',
            style: UiTypography.cardMeta(),
          ),
        ],
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;

  const _InfoItem(this.label, this.value);
}
