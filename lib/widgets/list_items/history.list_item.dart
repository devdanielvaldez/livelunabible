import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:meetup/constants/app_images.dart';
import 'package:meetup/models/meeting.dart';
import 'package:velocity_x/velocity_x.dart';

class HistoryListItem extends StatelessWidget {
  const HistoryListItem(this.meeting, this.onCallPressed, {Key key})
      : super(key: key);

  final Meeting meeting;
  final Function onCallPressed;
  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        //
        //banner
        CachedNetworkImage(
          imageUrl: meeting.banner,
          fit: BoxFit.cover,
          errorWidget: (context, url, progress) {
            return Image.asset(
              AppImages.onboarding1,
              fit: BoxFit.cover,
            );
          },
        ).wFull(context).h(context.percentHeight * 10),

        //
        HStack(
          [
            //
            VStack(
              [
                meeting.meetingTitle.text.make(),
                meeting.meetingID.text.lg.semiBold.make(),
                meeting.meetingDate.text.make(),
                meeting.isPublic
                    ? "Public".tr().text.purple500.make()
                    : "Private".tr().text.red500.make(),
              ],
            ).expand(),

            //rejoin
            const Icon(
              FlutterIcons.videocamera_ant,
              size: 20,
            )
                .box
                .p16
                .roundedFull
                .color(context.theme.backgroundColor)
                .make()
                .onInkTap(onCallPressed),
          ],
        ).p16(),
      ],
    )
        .box
        .margin(const EdgeInsets.all(5))
        .color(context.theme.cardColor)
        .roundedSM
        .clip(Clip.antiAlias)
        .shadow
        .make();
  }
}
