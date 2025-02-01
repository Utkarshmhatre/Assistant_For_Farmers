import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AirQualityData extends StatefulWidget {
  const AirQualityData({super.key});

  @override
  _AirQualityDataState createState() => _AirQualityDataState();
}

class _AirQualityDataState extends State<AirQualityData> {
  late WebViewController _webViewController;
  bool _isLoading = true;

  final String url = 'https://atmos.urbansciences.in/atmos/maps';

  @override
  void initState() {
    super.initState();
    // Initialize WebView controller
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Air Quality Map"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _webViewController.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: _webViewController,
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
