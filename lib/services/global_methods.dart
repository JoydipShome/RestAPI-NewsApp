import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:intl/intl.dart';

class GlobalMethods {
  static String formattedDateText(String publishedAt) {
    final parsedData = DateTime.parse(publishedAt);
    String formattedDate = DateFormat("yyyy-MM-dd hh:mm").format(parsedData);
    DateTime publishedDate =
        DateFormat("yyyy-MM-dd hh:mm").parse(formattedDate);
    return "${publishedDate.day}/${publishedDate.month}/${publishedDate.year} ON ${publishedDate.hour}:${publishedDate.second}";
  }

  static Future<void> errorDialog({
    required String errorMessage,
    required BuildContext context,
  }) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(errorMessage),
            title: (Row(
              children: const [
                Icon(
                  IconlyBold.danger,
                  color: Colors.red,
                ),
                SizedBox(width: 8),
                Text('An Error Occurred')
              ],
            )),
            actions: [
              TextButton(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('OK'))
            ],
          );
        });
  }
}