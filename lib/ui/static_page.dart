import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waioz/model/content_response.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../api/api_service.dart';
import '../utility/common_html.dart';

class StaticPage extends StatefulWidget {

  final String pageTitle;
  final String slug;

  const StaticPage({Key? key, required this.pageTitle, required this.slug})
      : super(key: key);

  @override
  _StaticPageState createState() => _StaticPageState();
}

class _StaticPageState extends State<StaticPage> {

  ContentResponse? contentResponse;
  bool apiLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    getContents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FEF2),
      appBar:CommonHeaderAppBar(
        title: widget.pageTitle,
        onBackTap: () {
          Navigator.of(context).pop();
        },
      ),
      body: apiLoading?Center(child: CircularProgressIndicator(color: AppColors.primary,),):SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 8),
          child: SingleChildScrollView(child: CommonHtmlWidget(htmlContent: contentResponse?.data?.content??'')),
        ),
      ),
    );
  }

  Future<void> getContents() async {
    try {
      setState(() => apiLoading = true);
      final apiService = ApiService();
      contentResponse = await apiService.getContents(context, widget.slug);
      setState(() => apiLoading = false);
    } catch (e) {
      debugPrint(e.toString());
      setState(() => apiLoading = false);
    }
  }
}