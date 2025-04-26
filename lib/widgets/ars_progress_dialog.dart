import 'dart:ui';

import 'package:flutter/material.dart';

class ArsProgressDialog {
  final BuildContext context;

  final Widget? loadingWidget;

  final bool? dismissable;

  final Function? onDismiss;

  final double blur;

  final Color backgroundColor;

  final bool useSafeArea;

  final Duration animationDuration;

  bool _isShowing = false;

  _ArsProgressDialogWidget? _progressDialogWidget;

  bool get isShowing => _isShowing;

  ArsProgressDialog(
    this.context, {
    this.backgroundColor = const Color(0x99000000),
    this.blur = 0,
    this.dismissable = true,
    this.onDismiss,
    this.loadingWidget,
    this.useSafeArea = false,
    this.animationDuration = const Duration(milliseconds: 300),
  }) {
    _initProgress();
  }

  void _initProgress() {
    _progressDialogWidget = _ArsProgressDialogWidget(
      blur: blur,
      dismissable: dismissable,
      backgroundColor: backgroundColor,
      onDismiss: onDismiss,
      loadingWidget: loadingWidget,
      animationDuration: animationDuration,
    );
  }

  void show() async {
    if (!_isShowing) {
      _isShowing = true;
      if (_progressDialogWidget == null) _initProgress();
      await showDialog(
        useSafeArea: useSafeArea,
        context: context,
        barrierDismissible: dismissable ?? true,
        builder: (context) => _progressDialogWidget!,
        barrierColor: Colors.transparent,
      );
      _isShowing = false;
    }
  }

  void dismiss([bool rootNavigator = false]) {
    if (_isShowing) {
      _isShowing = false;
      Navigator.of(context, rootNavigator: rootNavigator).pop();
    }
  }
}

class _ArsProgressDialogWidget extends StatelessWidget {
  Widget? loadingWidget;

  final Function? onDismiss;

  final double blur;

  final Color backgroundColor;

  final bool? dismissable;

  final Duration animationDuration;

  _ArsProgressDialogWidget({
    required this.backgroundColor,
    this.dismissable,
    this.onDismiss,
    this.loadingWidget,
    this.blur = 0,
    this.animationDuration = const Duration(milliseconds: 300),
  }) {
    loadingWidget =
        loadingWidget ??
        Container(
          padding: EdgeInsets.all(10.0),
          height: 100.0,
          width: 100.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: CircularProgressIndicator(strokeWidth: 2),
        );
  }

  @override
  Widget build(BuildContext context) {
    return _DialogBackground(
      blur: blur,
      dismissable: dismissable ?? true,
      onDismiss: onDismiss,
      color: backgroundColor,
      animationDuration: animationDuration,
      dialog: Padding(
        padding:
            MediaQuery.of(context).viewInsets +
            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Center(child: loadingWidget),
      ),
    );
  }
}

class _DialogBackground extends StatelessWidget {
  final Widget dialog;

  final bool? dismissable;

  final Function? onDismiss;

  final double blur;

  final Color color;

  final Duration animationDuration;

  late double _colorOpacity;

  _DialogBackground({
    required this.dialog,
    this.dismissable,
    this.blur = 0,
    this.onDismiss,
    this.animationDuration = const Duration(milliseconds: 300),
    required this.color,
  }) {
    _colorOpacity = color.opacity;
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: animationDuration,
      builder: (context, val, child) {
        return Material(
          type: MaterialType.canvas,
          color: color.withOpacity(val * _colorOpacity),
          child: WillPopScope(
            onWillPop: () async {
              if (dismissable ?? true) {
                if (onDismiss != null) onDismiss!();
                Navigator.pop(context);
              }
              return false;
            },
            child: Stack(
              clipBehavior: Clip.antiAlias,
              alignment: Alignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap:
                      dismissable ?? true
                          ? () {
                            if (onDismiss != null) {
                              onDismiss!();
                            }
                            Navigator.pop(context);
                          }
                          : () {},
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: val * blur,
                      sigmaY: val * blur,
                    ),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                dialog,
              ],
            ),
          ),
        );
      },
    );
  }
}
