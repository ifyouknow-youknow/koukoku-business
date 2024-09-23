import 'package:flutter/material.dart';
import 'package:koukoku_business/COMPONENTS/blur_view.dart';
import 'package:koukoku_business/COMPONENTS/text_view.dart';

class AlertView extends StatefulWidget {
  final String title;
  final String message;
  final List<Widget> actions;
  const AlertView(
      {super.key,
      required this.title,
      required this.message,
      required this.actions});

  @override
  State<AlertView> createState() => _AlertViewState();
}

class _AlertViewState extends State<AlertView> {
  @override
  Widget build(BuildContext context) {
    return BlurView(
      intensity: 7,
      child: Center(
        child: AlertDialog(
          title: TextView(
            text: widget.title,
            size: 20,
            weight: FontWeight.w600,
            wrap: true,
          ),
          content: TextView(text: widget.message, size: 16, wrap: true),
          actions: widget.actions,
        ),
      ),
    );
  }
}
