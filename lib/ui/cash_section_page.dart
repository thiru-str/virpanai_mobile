
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waioz/ui/cash_flow_page.dart';
import 'package:waioz/ui/dialogs/open_dialog_box.dart';
import 'package:waioz/ui/payment_flow_widget.dart';

import '../api/api_service.dart';
import '../model/login_response_model.dart' as login_model;
import '../model/open_cash_response_model.dart';
import '../utility/AppColors.dart';
import '../utility/shared_preferences_util.dart';

class CashSectionPage extends StatefulWidget {
  const CashSectionPage({super.key});

  @override
  State<CashSectionPage> createState() => _CashSectionPageState();
}

class _CashSectionPageState extends State<CashSectionPage> {
  bool? boxOpened = false;
  final ApiService apiService = ApiService();

  final List<PaymentItem> items = [
    PaymentItem(paymentType: 'printer', amount: 1, total: 100),
    PaymentItem(paymentType: 'Credit Card', amount: 1, total: 100),
    PaymentItem(paymentType: 'App', amount: 1, total: 100),
  ];

  int? globalUserId,branchId;
  login_model.Data? userData;
  OpenCashResponse? openCashResponse;

  @override
  void initState() {
    super.initState();
    getPreferenceDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf4f4f4),
      body: !boxOpened!
          ? boxOpenWidget()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const CashFlowWidget(),
                    PaymentTableWidget(itemTitle: 'Charged', items: items),
                    PaymentTableWidget(itemTitle: 'Bills', items: items),
                  ],
                ),
              ),
            ),
    );
  }

  // Pages
  Widget boxOpenWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'images/closed_box_icon.svg',
            height: 80,
          ),
          SizedBox(height: 16),
          Text("The box is not open", style: TextStyle(fontSize: 18)),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              OpenBoxDialog.show(context, (inputValue) {
                // This code will be executed after "Open Box" is pressed
                print("Received input: $inputValue");
                openBoxApi(inputValue);
                // Additional logic, like updating state or navigating
              });
            },
            child: Text("Open Box",style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold,fontSize: 23,color: Colors.white),),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              foregroundColor: Colors.white,
              backgroundColor: AppColors.primary,
              minimumSize: const Size(240, 60),
            ),
          ),
        ],
      ),
    );
  }

  void getPreferenceDetails() async{
    userData = await getLoginResponse();
    globalUserId = userData?.id;
    branchId = await SharedPreferencesUtil().getInt('branch_id');
    boxOpened = await SharedPreferencesUtil().getBool('box_opened');
    setState(() {
      boxOpened;
    });
  }

  Future<login_model.Data?> getLoginResponse() async {
    dynamic userData = await SharedPreferencesUtil().getMap('user_data');
    if (userData != null) {
      return login_model.Data.fromJson(userData);
    }
    return null;
  }

  void openBoxApi(String inputValue) async {
    try {
      int? openBoxValue = int.tryParse(inputValue);
      openCashResponse =
          await apiService.openCash(context,userData!.id!, openBoxValue!);
      setState(() {
        boxOpened = true;
        SharedPreferencesUtil().saveBool('box_opened', true);
        Navigator.pop(context);
      });
    } catch (e) {
      setState(() {

      });
      print(e);
    }
  }

}
