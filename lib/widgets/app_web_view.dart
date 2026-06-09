import 'package:creatoo/core.dart';
import 'package:creatoo/widgets/custom_back_button.dart';
import 'app_text_widget.dart';

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
    _controller = WebViewController()
      ..setBackgroundColor(Colors.transparent)
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
            // Inject dark mode CSS to make the web content blend beautifully
            _controller.runJavaScript('''
              document.body.style.backgroundColor = 'transparent';
              document.body.style.color = '#E0E0E0';
              document.body.style.fontFamily = 'Montserrat, sans-serif';
              document.body.style.padding = '0px 16px 16px 16px'; // Removed top padding to reduce gap
              document.body.style.lineHeight = '1.6';
              
              var links = document.querySelectorAll('a');
              links.forEach(function(link) {
                link.style.color = '#9759C4';
                link.style.textDecoration = 'none';
              });
              
              var headings = document.querySelectorAll('h1, h2, h3, h4, h5, h6');
              headings.forEach(function(heading) {
                heading.style.color = '#FFFFFF';
                heading.style.marginTop = '12px'; // Reduced top margin
                heading.style.marginBottom = '12px';
              });
              
              // Remove margin from the very first element to kill any extra gap at the top
              if (document.body.firstElementChild) {
                document.body.firstElementChild.style.marginTop = '0px';
              }
            ''');
            
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
      useGradient: true,
      backgroundColor: Colors.transparent,
      appBar: widget.data.enableAppBar
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: const Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Center(
                  child: CustomBackButton(),
                ),
              ),
              title: Text(
                widget.data.name.isNotEmpty ? widget.data.name : "Document",
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : null,
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: AppLoadingWidget(),
            ),
          if (_hasError)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 40.sp),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Failed to load document',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColor.premiumTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _hasError = false;
                      });
                      _controller.loadRequest(Uri.parse(widget.data.url));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.premiumAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
