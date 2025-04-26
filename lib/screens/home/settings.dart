import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:softec25/bloc/main_bloc.dart';
import 'package:softec25/styles.dart';
import 'package:softec25/widgets/buttons.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  static const String routeName = '/settingScreen';

  @override
  State<SettingScreen> createState() =>
      _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  Map data = {};
  final TextEditingController _controller =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLightBgColor,
      body: SizedBox(
        width: 1.sw,
        height: 1.sh,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height:
                    ScreenUtil().statusBarHeight + 100.h,
              ),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Task Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20.h),
              PrimaryButton(
                text: 'Create Task',
                onPressed: () async {
                  data = await Provider.of<MainBloc>(
                    context,
                    listen: false,
                  ).taskCreation(_controller.text);
                  setState(() {
                    data = data;
                  });
                },
              ),

              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(data.toString()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
