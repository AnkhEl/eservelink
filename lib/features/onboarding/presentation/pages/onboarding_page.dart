import 'package:eservelink/core/constants/app_colors.dart';
import 'package:eservelink/features/auth/presentation/components/auth_wrapper.dart';
import 'package:eservelink/features/auth/presentation/pages/login_page.dart';
import 'package:eservelink/features/onboarding/data/datasources/onboarding_pages_local_datasource.dart';
import 'package:eservelink/features/onboarding/domain/entities/onboarding_info.dart';
import 'package:eservelink/features/onboarding/presentation/widgets/page_indicator_button.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  bool onLastPage = false;
  List<OnboardingInfo> onboardingList =
      OnboardingPagesLocalDatasource().getOnboardingPageData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 15),
        child: PageView.builder(
          itemCount: onboardingList.length,
          controller: _controller,
          onPageChanged: onPageChanged,
          itemBuilder: (context, index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(onboardingList[index].imagePath),
                SizedBox(height: 10),
                Text(
                  onboardingList[index].title,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  textAlign: TextAlign.center,
                  onboardingList[index].description,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                ),
              ],
            );
          },
        ),
      ),
      bottomSheet: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child:
            onLastPage
                ? getStartedBtn()
                : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PageIndicatorButton(
                      text: 'Skip',
                      onTap: onSkipTap,
                      controller: _controller,
                    ),
                    SmoothPageIndicator(
                      onDotClicked:
                          (index) => _controller.animateToPage(
                            index,
                            duration: Duration(milliseconds: 600),
                            curve: Curves.easeIn,
                          ),
                      controller: _controller,
                      count: onboardingList.length,
                      effect: WormEffect(activeDotColor: AppColors.primary),
                    ),
                    PageIndicatorButton(
                      text: 'Next',
                      onTap: onNextTap,
                      controller: _controller,
                    ),
                  ],
                ),
      ),
    );
  }

  void onPageChanged(index) {
    setState(() {
      onLastPage = index == onboardingList.length - 1;
    });
  }

  void onSkipTap() {
    _controller.animateToPage(
      onboardingList.length - 1,
      duration: Duration(milliseconds: 600),
      curve: Curves.easeIn,
    );
  }

  void onNextTap() {
    _controller.nextPage(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );
  }

  void onDoneTap() async {
    final sharedPref = await SharedPreferences.getInstance();
    await sharedPref.setBool("isOnboarded", true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthWrapper()),
    );
  }

  Widget getStartedBtn() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      width: MediaQuery.of(context).size.width * .9,
      height: 55,
      child: TextButton(
        onPressed: onDoneTap,
        child: Text('Get Started', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
