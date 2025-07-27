import "package:flutter/material.dart";

import "../theme/typography.dart";

Future<bool> showPopupDialogue(BuildContext context, String title, String message, String confirmText) async {
  return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: BodyText(title),
          content: BodyText(message),

          actions: [
            //cancel button
            ElevatedButton(
                onPressed: () {Navigator.of(context).pop(false);}, child: BodyText("Cancel")
            ),
            //Create button
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(confirmText, style: TextStyles.body.copyWith(color: Colors.red),),
            ),
          ],
        );
      }
  ) ?? false;
}