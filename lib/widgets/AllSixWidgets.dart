import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../projectController/page_one_controller.dart';
import '../services/app_text_style.dart';
import '../services/app_theme.dart';
import '../services/scale_util.dart';

class AllSixCards extends GetWidget<PageOneController> {
 
 final appTheme = Get.find<AppTheme>();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ScaleUtil.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: ScaleUtil.height(40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.deepPurpleAccent,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Daily journal',
                    style: AppTextTheme.textTheme.bodyMedium
                  ),
                ),
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: Container(
                  height: ScaleUtil.height(40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.deepPurpleAccent,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Take notes',
                    style: AppTextTheme.textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: ScaleUtil.height(10),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: ScaleUtil.height(40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.deepPurpleAccent,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'All reminders',
                    style: AppTextTheme.textTheme.bodyMedium,
                  ),
                ),
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: Container(
                  height: ScaleUtil.height(40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.deepPurpleAccent,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Completed tasks',
                    style: AppTextTheme.textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: ScaleUtil.height(10),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: ScaleUtil.height(40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.deepPurpleAccent,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Upcoming',
                    style: AppTextTheme.textTheme.bodyMedium,
                  ),
                ),
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: Container(
                  height: ScaleUtil.height(40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.deepPurpleAccent,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Vision',
                    style: AppTextTheme.textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
