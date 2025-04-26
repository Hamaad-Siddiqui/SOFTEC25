import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:softec25/styles.dart';
import 'package:softec25/widgets/ars_progress_dialog.dart';

// For pretty printing
var _logger = Logger(
  printer: PrettyPrinter(colors: true, printEmojis: true),
);
console(msg) {
  _logger.d(msg);
}

warn(msg) {
  _logger.w(msg);
}

error(msg) {
  _logger.e(msg);
}

// Regular expression for validating an phone number
bool isPhoneNumberValid(String number) {
  console(number);
  return RegExp(
    r'(^(?:[+0]9)?[0-9]{9,18}$)',
  ).hasMatch(number.replaceAll('+', ''));
}

// Regular expression for validating an email address
bool isEmailValid(String email) {
  return RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    // better regex: (allows .co.uk, .com.au, etc)
    // [a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(\.[a-zA-Z]{2,})+
  ).hasMatch(email.toLowerCase());
}

bool isWebsiteValid(String website) {
  return RegExp(
    r"^((https?|ftp|smtp):\/\/)?(www.)?[a-z0-9]+\.[a-z]+(\/[a-zA-Z0-9#]+\/?)*$",
  ).hasMatch(website.toLowerCase());
}

bool isReferralCodeValid(String code) {
  return RegExp(r'^[0-9A-Z]{8}$').hasMatch(code);
}

// For getting the size (width and height) of a text
Size getTextSize(String text, TextStyle style) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.size;
}

Size getFixedTextSize(
  String text,
  TextStyle style,
  double width,
) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    // maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout(minWidth: 0, maxWidth: width);
  return textPainter.size;
}

MaterialColor createMaterialColor(Color color) {
  List<double> strengths = <double>[
    .05,
    .1,
    .2,
    .3,
    .4,
    .5,
    .6,
    .7,
    .8,
    .9,
  ];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

ArsProgressDialog? _progressDialog;
void showLoadingIndicator(BuildContext context) {
  _progressDialog = ArsProgressDialog(
    context,
    dismissable: false,
    blur: 2,
    backgroundColor: const Color(0x33000000),
    animationDuration: const Duration(milliseconds: 200),
    loadingWidget: Container(
      padding: const EdgeInsets.all(10.0),
      height: 100.0,
      width: 100.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: const CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          AppColors.primaryColor,
        ),
      ),
    ),
  );
  _progressDialog!.show();
}

void hideLoadingIndicator([bool rootNavigator = false]) {
  _progressDialog?.dismiss(rootNavigator);
}
