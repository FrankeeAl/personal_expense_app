import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveButton extends StatelessWidget {
  final String text;
  final VoidCallback handler;
  const AdaptiveButton(this.text, this.handler, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoButton(
            child: const Text('Choose Date',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal)),
            onPressed: handler,
          )
        : TextButton(
            child: const Text('Choose Date',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal)),
            onPressed: handler,
          );
  }
}
