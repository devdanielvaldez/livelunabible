import 'package:flutter/material.dart';
import 'package:meetup/constants/app_colors.dart';
import 'package:meetup/constants/app_text_styles.dart';
import 'package:meetup/widgets/busy_indicator.dart';
import 'package:velocity_x/velocity_x.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final Function onPressed;
  final ShapeBorder shape;
  final bool isFixedHeight;
  final bool loading;
  final double shapeRadius;
  final Color color;

  const CustomButton({
    this.title,
    this.onPressed,
    this.shape,
    this.isFixedHeight = false,
    this.loading = false,
    this.shapeRadius = Vx.dp4,
    this.color,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        primary: color ?? AppColor.primaryColor,
        onSurface: loading ? AppColor.primaryColor : null,
        shape: shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(shapeRadius),
            ),
      ),
      child: loading
          ? const BusyIndicator()
          : SizedBox(
              width: double.infinity,
              height: isFixedHeight ? Vx.dp32 : null,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyle.h3TitleTextStyle(
                  color: Colors.white,
                ),
              ),
            ),
    );
  }
}
