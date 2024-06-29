import 'package:flutter/material.dart';

showError(BuildContext context, String titulo, String erro) async {
  await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Row(children: [
              Icon(Icons.error, color: Colors.red),
              Text("Erro"),
            ]),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo),
                Text(erro),
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