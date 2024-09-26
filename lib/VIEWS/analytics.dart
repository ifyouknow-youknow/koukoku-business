import 'package:flutter/material.dart';
import 'package:koukoku_business/COMPONENTS/button_view.dart';
import 'package:koukoku_business/COMPONENTS/iconbutton_view.dart';
import 'package:koukoku_business/COMPONENTS/main_view.dart';
import 'package:koukoku_business/COMPONENTS/padding_view.dart';
import 'package:koukoku_business/COMPONENTS/text_view.dart';
import 'package:koukoku_business/FUNCTIONS/media.dart';
import 'package:koukoku_business/MODELS/DATAMASTER/datamaster.dart';
import 'package:koukoku_business/MODELS/screen.dart';

class Analytics extends StatefulWidget {
  final DataMaster dm;
  const Analytics({super.key, required this.dm});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  void onHandleScan() async {}
  @override
  Widget build(BuildContext context) {
    return MainView(dm: widget.dm, children: [
      Expanded(
        child: Stack(
          children: [
            PaddingView(
              paddingTop: 0,
              child: Row(
                children: [
                  TextView(
                    text: 'Analytics',
                    size: 20,
                    weight: FontWeight.w600,
                    spacing: -1,
                  ),
                ],
              ),
            ),

            // ABSOLUTE
            Positioned(
              bottom: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButtonView(
                    backgroundColor: Colors.black,
                    icon: Icons.qr_code_scanner,
                    iconSize: 32,
                    width: 34,
                    iconColor: Colors.white,
                    onPress: () async {
                      final data = await function_ScanQRCode(context);
                      print(
                          "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-");
                      print(data);
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      )
    ]);
  }
}
