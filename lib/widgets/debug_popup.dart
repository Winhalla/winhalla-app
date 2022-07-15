import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
import 'package:winhalla_app/utils/user_class.dart';

import 'inherited_text_style.dart';

Widget RuntimeDebugPopup(User user) {
  TextEditingController controller = TextEditingController();
  return Builder(builder: (context) {
    return AlertDialog(
      elevation: 10,
      backgroundColor: kBackgroundVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      title: Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Debug panel",
              style: InheritedTextStyle.of(context).kHeadline2,
            ),
          ],
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      content: Padding(
          padding: const EdgeInsets.fromLTRB(6, 0, 4, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.black),
                padding: EdgeInsets.fromLTRB(20, 2, 20, 2),
                child: TextField(
                  controller: controller,
                  style: InheritedTextStyle.of(context).kBodyText3.apply(fontSizeFactor: 0.9, color: kText80),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'ID here',
                      hintStyle: InheritedTextStyle.of(context).kBodyText3.apply(fontSizeFactor: 0.85, color: kText80)),
                ),
              ),
              SizedBox(
                height: 2.h,
              ),
              GestureDetector(
                onTap: () {
                  secureStorage.write(key: "authKey", value: controller.text);
                },
                child: Container(
                    decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(20)),
                    padding: EdgeInsets.fromLTRB(15, 3, 15, 3),
                    child: Text(
                      "Load account",
                      style: InheritedTextStyle.of(context).kBodyText2,
                    )),
              )
            ],
          )),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [],
        )
      ],
    );
  });
}
