import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:waioz/model/return_response.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_utils.dart';

import '../../api/api_service.dart';
import '../../model/order_detail_response.dart';


class ReturnOrderBottomSheet extends StatefulWidget {
  final String orderId;
  final String cartId;
  final Item orderItem;
  final List<ReturnReason> reasons;

  const ReturnOrderBottomSheet({
    Key? key,
    required this.cartId,
    required this.orderId,
    required this.orderItem,
    required this.reasons,
  }) : super(key: key);

  @override
  State<ReturnOrderBottomSheet> createState() => _ReturnOrderBottomSheetState();
}

class _ReturnOrderBottomSheetState extends State<ReturnOrderBottomSheet> {
  String? _selectedReason;
  String? _selectedReasonId;
  String? _customReason;
  int _selectedQty = 1;
  bool apiLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedQty = (widget.orderItem.quantity??1).toInt();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.orderItem;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔹 Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Return Order",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 16),

            // 🔹 Product Section
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: order.thumbnail??'',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                      const Icon(Icons.image_not_supported),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.productTitle??'',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.variantTitle??'',
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),

                  // 🔹 Quantity Selector (no dropdown)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_selectedQty > 1) _selectedQty--;
                            });
                          },
                          child: const Icon(Icons.remove,
                              size: 18, color: Colors.black87),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '$_selectedQty',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_selectedQty < (order.quantity??0)) _selectedQty++;
                            });
                          },
                          child: const Icon(Icons.add,
                              size: 18, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Reason
            const Text(
              "Reason",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            ...widget.reasons.map((reason) {
              return RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                dense: true,
                value: reason.id??'',
                groupValue: _selectedReasonId,
                title: Text(reason.label??'',
                    style: const TextStyle(fontSize: 14, color: Colors.black87)),
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setState(() {
                    _selectedReasonId = val;
                    _selectedReason = reason.label;
                    if (val != "Others") _customReason = null;
                  });
                },
              );
            }).toList(),

            // 🔹 Custom Reason TextField (if Others)
            if (_selectedReason == "Others")
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 12),
                child: TextField(
                  onChanged: (value) => _customReason = value,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Write a reason",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                      BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 10),

            // 🔹 Confirm Button
            apiLoading?Center(child: CircularProgressIndicator(color: AppColors.primary,),):SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedReasonId == null
                    ? null
                    : () {
                  processReturn();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Confirm Return",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> processReturn() async {
    try {
      final order = widget.orderItem;
      setState(() {
        apiLoading = true;
      });
      final ApiService apiService = ApiService();
      final response = await apiService.processReturn(context, widget.orderId??'', widget.cartId, order.id??'', _selectedQty, _selectedReasonId??'', _customReason??'', order.fulfillmentId??'');
      if(response.status??false)
        {
          AppUtils.showToast(response.message??'');
          Navigator.pop(context,true);
        }
      setState(() {
        apiLoading = false;
      });
    } catch (e) {
      print("Error fetching home page: $e");
      setState(() {
        apiLoading = false;
      });
    }
  }

}
