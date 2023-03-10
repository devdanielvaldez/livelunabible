import 'dart:io';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

//
import 'package:meetup/constants/api.dart';
import 'package:meetup/constants/app_strings.dart';
import 'package:meetup/models/meeting.dart';
import 'package:meetup/models/user.dart';
import 'package:meetup/requests/meeting.request.dart';
import 'package:meetup/services/auth.service.dart';
import 'package:meetup/view_models/base.view_model.dart';
import 'package:clipboard/clipboard.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share_plus/share_plus.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:random_string/random_string.dart';

class MeetingViewModel extends MyBaseViewModel {
  //
  final MeetingRequest _meetingRequest = MeetingRequest();
  final picker = ImagePicker();
  //
  int selectedAction = 0;
  bool isNewMeetingPublic = false;
  File meetingBanner;
  TextEditingController meetingIdTEC = TextEditingController();
  TextEditingController meetingNickNameTEC = TextEditingController();
  TextEditingController newMeetingIdTEC = TextEditingController();
  TextEditingController newMeetingTitleTEC = TextEditingController();
  User currentUser;

  //
  int queryPage = 1;
  List<Meeting> publicMeetings = [];
  RefreshController refreshController = RefreshController();

  //
  MeetingViewModel(BuildContext context) {
    viewContext = context;
  }

  @override
  void initialise() async {
    //
    if (AuthServices.authenticated()) {
      currentUser = await AuthServices.getCurrentUser(force: true);
      meetingNickNameTEC.text = currentUser?.name;
      notifyListeners();
    }

    //
    newMeetingCode();

    //
    getPublicMeetings();
  }

  void newMeetingCode() {
    //
    newMeetingIdTEC.text = randomAlphaNumeric(10);
    notifyListeners();
  }

  //
  changeMeetingView(int action) {
    selectedAction = action;
    notifyListeners();
  }

  void pasteMeetingId() async {
    try {
      FlutterClipboard.paste().then((value) {
        // Do what ever you want with the value.
        meetingIdTEC.text = value;
        notifyListeners();
      });
    } catch (error) {
      viewContext.showToast(msg: "No Meeting ID pasted");
    }
  }

  //
  void copyMeetingId() async {
    try {
      FlutterClipboard.copy(newMeetingIdTEC.text).then((value) {
        //
        viewContext.showToast(msg: "Meeting ID copied");
      });
    } catch (error) {
      viewContext.showToast(msg: "No Meeting ID copied");
    }
  }

  //
  void toggleMeetingPublic(bool value) {
    isNewMeetingPublic = value;
    notifyListeners();
  }

  //
  void pickMeetingImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      meetingBanner = File(pickedFile.path);
    } else {
      meetingBanner = null;
    }

    notifyListeners();
  }

  //
  void removeBanner() async {
    meetingBanner = null;
    notifyListeners();
  }

  /// Meeting creating and joining

  //
  startJoinMeeting() async {
    if (formKey.currentState.validate()) {
      setBusy(true);
      //
      final apiResponse = await _meetingRequest.joinMeetingRequest(
        meetingID: meetingIdTEC.text,
      );
      //stop loading
      setBusy(false);

      //
      if (!apiResponse.allGood) {
        CoolAlert.show(
          context: viewContext,
          type: CoolAlertType.error,
          title: "Join Meeting",
          text: apiResponse.message,
        );
      } else {
        //join the video call
        final meeting = Meeting.fromJSON(apiResponse.body["meeting"]);
        joinMeeting(meeting);
      }
    }
  }

  joinMeeting(Meeting meeting) async {
    try {
      var options = JitsiMeetingOptions(
        roomNameOrUrl: meetingIdTEC.text,
        subject: meeting?.meetingTitle ?? "Untitled".tr(),
        userDisplayName: meetingNickNameTEC.text,
        isAudioOnly: false,
        isAudioMuted: true,
        isVideoMuted: true,
        featureFlags: {
          FeatureFlag.isWelcomePageEnabled: false,
          FeatureFlag.isChatEnabled: true,
          FeatureFlag.isInviteEnabled: meeting?.mine ?? false,
          FeatureFlag.isAddPeopleEnabled: meeting?.mine ?? false,
          FeatureFlag.isKickoutEnabled: meeting?.mine ?? false,
        },
      );

      await JitsiMeetWrapper.joinMeeting(
        options: options,
      );
    } catch (error) {
      if (kDebugMode) {
        print("Meeting error ==> $error");
      }
      viewContext.showToast(msg: "There was an error joining meeting: $error");
    }
  }

  shareNewMeeting() async {
    String shareText = "Join Meeting with: ${AppStrings.appName}\n";
    shareText +=
        "Join on your web browser: ${Api.webUrl}/meeting/${newMeetingIdTEC.text}";
    shareText += "Join on the app: ${newMeetingIdTEC.text}";

    //
    Share.share(shareText);
  }

  //
  startNewMeeting() async {
    setBusy(true);
    //
    final apiResponse = await _meetingRequest.newMeetingRequest(
      meetingID: newMeetingIdTEC.text,
      meetingTitle: newMeetingTitleTEC.text,
      meetingBanner: meetingBanner,
      isPublic: isNewMeetingPublic,
    );
    //stop loading
    setBusy(false);

    //
    if (!apiResponse.allGood) {
      CoolAlert.show(
        context: viewContext,
        type: CoolAlertType.error,
        title: "New Meeting",
        text: apiResponse.message,
      );
    } else {
      //start the video call
      final meeting = Meeting.fromJSON(apiResponse.body["meeting"]);
      await initiateNewMeeting(meeting: meeting);
      resetNewMeeting();
    }
  }

  resetNewMeeting() {
    //generate a new meeting code
    newMeetingTitleTEC.text = "";
    meetingBanner = null;
    isNewMeetingPublic = false;
    newMeetingCode();
  }

  //initiate the vidoe call
  initiateNewMeeting({Meeting meeting}) async {
    try {
      var options = JitsiMeetingOptions(
        roomNameOrUrl: meeting?.meetingID ?? newMeetingIdTEC.text,
        subject: meeting?.meetingTitle ?? "Untitled".tr(),
        userDisplayName: currentUser?.name,
        userAvatarUrl: currentUser?.photo ?? "",
        featureFlags: {
          FeatureFlag.isWelcomePageEnabled: false,
          FeatureFlag.isChatEnabled: true,
          FeatureFlag.isInviteEnabled: meeting.mine,
          FeatureFlag.isAddPeopleEnabled: meeting.mine,
          FeatureFlag.areSecurityOptionsEnabled: meeting.mine,
          FeatureFlag.isKickoutEnabled: meeting.mine,
        },
      );

      await JitsiMeetWrapper.joinMeeting(
        options: options,
      );
    } catch (error) {
      if (kDebugMode) {
        print("join error ==> $error");
      }
      viewContext.showToast(
        msg: "There was an error joining new meeting".tr(),
      );
    }
  }

  void getPublicMeetings({bool initial = true}) async {
    //
    initial ? queryPage = 1 : queryPage++;
    //
    if (initial) {
      setBusyForObject(publicMeetings, true);
      refreshController.refreshCompleted();
    }
    //
    final mMeetings =
        await _meetingRequest.publicMeetingsRequest(page: queryPage);
    if (initial) {
      publicMeetings = mMeetings;
    } else {
      publicMeetings.addAll(mMeetings);
    }

    //
    initial
        ? setBusyForObject(publicMeetings, false)
        : refreshController.loadComplete();
  }
}
