import 'package:eservelink/features/onboarding/domain/entities/onboarding_info.dart';

class OnboardingInfoModel extends OnboardingInfo {
  OnboardingInfoModel({
    required super.title,
    required super.description,
    required super.imagePath,
  });

  factory OnboardingInfoModel.fromJson(Map<String, dynamic> map) {
    return OnboardingInfoModel(
      title: map['title'],
      description: map['description'],
      imagePath: map['imagePath'],
    );
  }
}
