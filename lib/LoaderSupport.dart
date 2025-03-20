import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoaderSupport extends AppBody{
  static AppBody loadingAnimation = AppBody(
    LoadingAnimationWidget.dotsTriangle(
      color: Color(0xFF00FFFF),
      size: 80,
    ),
  );

  LoaderSupport(super.widget);

}
class AppBody {
  final Widget widget;
  AppBody(this.widget,);
}