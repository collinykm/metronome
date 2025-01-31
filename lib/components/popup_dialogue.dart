import "package:flutter/material.dart";

Future<bool> showPopupDialogue(BuildContext context, String title, String message, String confirmText) async {
  return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),

          actions: [
            //cancel button
            ElevatedButton(
                onPressed: () {Navigator.of(context).pop(false);}, child: Text("Cancel")
            ),
            //Create button
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(confirmText, style: TextStyle(color: Colors.red),),
            ),
          ],
        );
      }
  ) ?? false;
}