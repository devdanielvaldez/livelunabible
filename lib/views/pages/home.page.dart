import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:meetup/view_models/home.vm.dart';
import 'package:meetup/views/pages/history.page.dart';
import 'package:meetup/views/pages/meeting/lounge.page.dart';
import 'package:meetup/views/pages/meeting/meeting.page.dart';
import 'package:meetup/views/pages/profile.page.dart';
import 'package:line_icons/line_icons.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key key,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(context),
      onModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                PageView(
                  controller: model.pageViewController,
                  onPageChanged: model.onPageChanged,
                  children: const [
                    //History
                    HistoryPage(),
                    //Meeting
                    MeetingPage(),
                    //
                    LoungePage(),
                    //profile
                    ProfilePage(),
                  ],
                ),

                //ad
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    alignment: Alignment.center,
                    child: AdWidget(ad: model.myBanner),
                    width: model.myBanner.size.width.toDouble(),
                    height: model.myBanner.size.height.toDouble(),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: VxBox(
            child: SafeArea(
              child: GNav(
                gap: 2,
                activeColor: Colors.white,
                color: Theme.of(context).textTheme.bodyText1.color,
                iconSize: 24,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                duration: const Duration(milliseconds: 300),
                tabBackgroundColor: context.accentColor,
                tabs: [
                  GButton(
                    icon: LineIcons.history,
                    text: 'History'.tr(),
                  ),
                  GButton(
                    icon: LineIcons.camera,
                    text: 'Meeting'.tr(),
                  ),
                  GButton(
                    icon: LineIcons.users,
                    text: 'Lounge'.tr(),
                  ),
                  GButton(
                    icon: LineIcons.user,
                    text: 'Profile'.tr(),
                  ),
                ],
                selectedIndex: model.currentIndex,
                onTabChange: model.onTabChange,
              ),
            ),
          ).p16.shadow.color(context.backgroundColor).make(),
        );
      },
    );
  }
}
