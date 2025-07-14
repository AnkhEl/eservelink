import 'package:eservelink/features/auth/presentation/pages/login_page.dart';
import 'package:eservelink/features/onboarding/presentation/widgets/page_indicator_button.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (pageIndex) {
              setState(() {
                onLastPage = pageIndex == 2;
              });
            },
            children: [
              Container(color: Colors.red),
              Container(color: Colors.orange),
              Container(color: Colors.yellow),
            ],
          ),
          Container(
            alignment: Alignment(0, 0.85),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PageIndicatorButton(
                  text: 'Skip',
                  onTap: onSkipTap,
                  controller: _controller,
                ),
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: WormEffect(),
                ),
                onLastPage
                    ? PageIndicatorButton(
                      text: 'Done',
                      onTap: () => onDoneTap(context),
                      controller: _controller,
                    )
                    : PageIndicatorButton(
                      text: 'Next',
                      onTap: onNextTap,
                      controller: _controller,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void onSkipTap() {
    _controller.jumpToPage(2);
  }

  void onNextTap() {
    _controller.nextPage(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );
  }

  void onDoneTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}
