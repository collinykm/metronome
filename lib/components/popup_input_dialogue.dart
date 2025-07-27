import "package:flutter/material.dart";

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
            ),
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