import "package:flutter/material.dart";
import "package:metronome_app/theme/colors.dart";

import "../theme/typography.dart";

Future showInputDialogue({
  required BuildContext context,
  required Function() handleSubmit,
  required String title,
  required String hintText,
  required TextEditingController controller,
  required String confirmText,
  TextInputType? type,
  }) {


  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: BodyText(title),
          content: TextFormField(

            keyboardType: type,
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              label: BodyText("Search"),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)
              ),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary)
              ),
            ),

            style: TextStyles.body,
          ),
          actions: [
            //cancel button
            ElevatedButton(
                onPressed: () {Navigator.pop(context);}, child: BodyText("Cancel")
            ),
            //Create button
            ElevatedButton(
              onPressed: handleSubmit,
              child: BodyText(confirmText),
            ),
          ],
        );
      }
  );
}