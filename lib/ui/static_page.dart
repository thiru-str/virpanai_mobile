import 'package:flutter/material.dart';
import 'package:waioz/ui/widgets/common_header_app_bar.dart';

import '../utility/common_html.dart';

class StaticPage extends StatefulWidget {

  final String pageTitle;
  final String htmlData;

  const StaticPage({Key? key, required this.pageTitle, required this.htmlData})
      : super(key: key);

  @override
  _StaticPageState createState() => _StaticPageState();
}

class _StaticPageState extends State<StaticPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:CommonHeaderAppBar(
        title: widget.pageTitle,
        onBackTap: () {
          Navigator.of(context).pop();
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 8),
          child: SingleChildScrollView(child: CommonHtmlWidget(htmlContent: widget.htmlData)),
        ),
      ),
    );
  }
}
