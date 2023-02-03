import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:meetup/constants/app_images.dart';
import 'package:meetup/constants/app_routes.dart';
import 'package:meetup/constants/app_strings.dart';
import 'package:meetup/services/auth.service.dart';
import 'base.view_model.dart';
import 'package:velocity_x/velocity_x.dart';

class OnboardingViewModel extends MyBaseViewModel {
  OnboardingViewModel(BuildContext context) {
    viewContext = context;
  }

  final PageController pageController = PageController();

  final List<OnBoardModel> onBoardData = [
    OnBoardModel(
      title: "Meeting from anywhere".tr(),
      description: "Start/Join a meeting from anywhere in the world".tr(),
      imgUrl: AppImages.onboarding1,
    ),
    OnBoardModel(
      title: "Stay in touch".tr(),
      description:
          "Also connected with colleagues, family & friends via messages".tr(),
      imgUrl: AppImages.onboarding2,
    ),
    OnBoardModel(
      title: "Video conferencing".tr(),
      description:
          "Start a video call on the go with colleagues, family & friends".tr(),
      imgUrl: AppImages.onboarding3,
    ),
  ];

  void onDonePressed() async {
    await AuthServices.prefs.setBool(AppStrings.firstTimeOnApp, false);
    viewContext.navigator.pushNamedAndRemoveUntil(
      AppRoutes.homeRoute,
      (route) => false,
    );
  }
}

class OnBoardModel {
  String title;
  String description;
  String imgUrl;

  OnBoardModel({
    this.title,
    this.description,
    this.imgUrl,
  });
}
