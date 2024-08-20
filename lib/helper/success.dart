import 'package:flutter/material.dart';

showSuccess(BuildContext context, String msg) async {
  await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Row(children: [
              Icon(Icons.check, color: Colors.green),
              Text("Sucesso"),
            ]),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(msg),
              ],
            ),
            actions: [
              TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  })
            ]);
      });
}