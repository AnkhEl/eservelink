import 'package:eservelink/features/onboarding/domain/entities/onboarding_info.dart';

class OnboardingPagesLocalDatasource {
  //TODO: N.B I might move the images to Firebase and remove assets/ from the app

  List<OnboardingInfo> getOnboardingPageData = [
    OnboardingInfo(
      title: "Title1",
      imagePath: "assets/onboarding1.png",
      description:
          "A short description about something that is definitely not so short regarding this beautiful app that we are creating",
    ),
    OnboardingInfo(
      title: "Title2",
      imagePath: "assets/onboarding2.png",
      description:
          "A short description about something that is definitely not so short regarding this beautiful app that we are creating",
    ),
    OnboardingInfo(
      title: "Title3",
      imagePath: "assets/onboarding3.png",
      description:
          "A short description about something that is definitely not so short regarding this beautiful app that we are creating",
    ),
    OnboardingInfo(
      title: "Title4",
      imagePath: "assets/onboarding4.png",
      description:
          "A short description about something that is definitely not so short regarding this beautiful app that we are creating",
    ),
    OnboardingInfo(
      title: "Title5",
      imagePath: "assets/onboarding5.png",
      description:
          "A short description about something that is definitely not so short regarding this beautiful app that we are creating",
    ),
  ];
}
