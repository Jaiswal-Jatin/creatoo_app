import 'package:creatoo/core.dart';

class WebViewData {
  final String name;
  final String url;
  final bool enableAppBar;

  WebViewData(this.name, this.url, {this.enableAppBar = false});
}

class AppWebView extends StatefulWidget {
  final WebViewData data;

  AppWebView({required this.data});

  @override
  _AppWebViewState createState() => _AppWebViewState();
}

class _AppWebViewState extends State<AppWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Initialize WebViewController
    _controller = WebViewController()
      ..setBackgroundColor(AppColor.transparent)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (error) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
            print('Error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.data.url));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: widget.data.enableAppBar
          ? AppBarWidget(title: widget.data.name)
          : null,
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) Center(child: CircularProgressIndicator()),
          if (_hasError)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 64),
                  SizedBox(height: 16),
                  Text('Failed to load page', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  TextButton(
                    onPressed: () =>
                        _controller.loadRequest(Uri.parse(widget.data.url)),
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
