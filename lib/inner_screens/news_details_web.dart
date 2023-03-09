import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:proj45_restapi_newsapp/services/global_methods.dart';
import 'package:proj45_restapi_newsapp/widgets/verical_spacing.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../providers/news_provider.dart';
import '../services/utils.dart';

class NewsDetailsWebView extends StatefulWidget {
  const NewsDetailsWebView({Key? key, required this.url}) : super(key: key);
  final String url;

  @override
  State<NewsDetailsWebView> createState() => _NewsDetailsWebViewState();
}

class _NewsDetailsWebViewState extends State<NewsDetailsWebView> {
  late WebViewController _webViewController;
  double _progress = 0.0;
  // final url = "https://www.ndtv.com/";

  @override
  Widget build(BuildContext context) {
    final Color color = Utils(context).getColor;
    final newsProvider = Provider.of<NewsProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        if (await _webViewController.canGoBack()) {
          _webViewController.goBack();
          // stay inside
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(IconlyLight.arrowLeft2),
              onPressed: () {
                Navigator.pop(context);
              }),
          iconTheme: IconThemeData(color: color),
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          centerTitle: true,
          title: Text(
            widget.url,
            style: TextStyle(color: color),
          ),
          actions: [
            IconButton(
              onPressed: () async {
                await _showModalSheetFct();
              },
              icon: const Icon(Icons.more_horiz),
            )
          ],
        ),
        body: Column(
          children: [
            LinearProgressIndicator(
              value: _progress,
              color: _progress == 1 ? Colors.transparent : Colors.blue,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
            Expanded(
              child: WebView(
                initialUrl: widget.url, // as it is outside of the state class
                zoomEnabled: true,
                onProgress: (progress) {
                  setState(() {
                    _progress = progress / 100;
                  });
                },
                onWebViewCreated: (controller) {
                  _webViewController = controller;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showModalSheetFct() async {
    await showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        context: context,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              children: [
                const VerticalSpacing(height: 20),
                Center(
                  child: Container(
                    height: 5,
                    width: 35,
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
                const VerticalSpacing(height: 20),
                const Text(
                  "More Options",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                const VerticalSpacing(height: 20),
                const Divider(thickness: 2),
                const VerticalSpacing(height: 20),
                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text("Share"),
                  onTap: () async {
                    try {
                      await Share.share(widget.url,
                          subject: 'Look what I made!');
                    } catch (e) {
                      GlobalMethods.errorDialog(
                          errorMessage: e.toString(), context: context);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.open_in_browser),
                  title: const Text("Open  in Browser"),
                  onTap: () async {
                    if (!await launchUrl(Uri.parse(widget.url))) {
                      throw 'Could not launch $widget.url';
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text("Refresh"),
                  onTap: () async {
                    try {
                      await _webViewController.reload();
                    } catch (e) {
                      log("Error occoured $e");
                    } finally {
                      Navigator.pop(context);
                    }
                    ;
                  },
                ),
              ],
            ),
          );
        });
  }
}
