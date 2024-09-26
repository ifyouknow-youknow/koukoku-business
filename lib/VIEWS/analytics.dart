import 'package:flutter/material.dart';
import 'package:koukoku_business/COMPONENTS/button_view.dart';
import 'package:koukoku_business/COMPONENTS/iconbutton_view.dart';
import 'package:koukoku_business/COMPONENTS/main_view.dart';
import 'package:koukoku_business/COMPONENTS/padding_view.dart';
import 'package:koukoku_business/COMPONENTS/text_view.dart';
import 'package:koukoku_business/FUNCTIONS/colors.dart';
import 'package:koukoku_business/FUNCTIONS/media.dart';
import 'package:koukoku_business/FUNCTIONS/misc.dart';
import 'package:koukoku_business/MODELS/DATAMASTER/datamaster.dart';
import 'package:koukoku_business/MODELS/constants.dart';
import 'package:koukoku_business/MODELS/firebase.dart';
import 'package:koukoku_business/MODELS/screen.dart';

class Analytics extends StatefulWidget {
  final DataMaster dm;
  const Analytics({super.key, required this.dm});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  void onHandleScan(String data) async {
    setState(() {
      widget.dm.setToggleAlert(true);
      widget.dm.setAlertTitle('Proceed?');
      widget.dm.setAlertText('Proceed with the scan?');
      widget.dm.setAlertButtons([
        PaddingView(
          paddingTop: 0,
          paddingBottom: 0,
          child: ButtonView(
              paddingTop: 8,
              paddingBottom: 8,
              paddingLeft: 18,
              paddingRight: 18,
              radius: 100,
              backgroundColor: hexToColor('#3490F3'),
              child: TextView(
                text: 'Proceed',
                color: Colors.white,
              ),
              onPress: () async {
                setState(() {
                  widget.dm.setToggleAlert(false);
                  widget.dm.setToggleLoading(true);
                });
                final split = data.split('~');
                final userId = split[0];
                final adId = split[1];

                final success = await firebase_CreateDocument(
                    '${appName}_Scans', randomString(25), {
                  'adId': adId,
                  'businessId': widget.dm.user['id'],
                  'date': DateTime.now().millisecondsSinceEpoch,
                  'userId': userId
                });
                if (success) {
                  setState(() {
                    widget.dm.setToggleLoading(false);
                    widget.dm.setToggleAlert(true);
                    widget.dm.setAlertTitle('Success');
                    widget.dm.setAlertText(
                        'The scan has been added to the ad records.');
                  });
                } else {
                  setState(() {
                    widget.dm.setToggleLoading(false);
                    widget.dm.alertSomethingWrong();
                  });
                }
              }),
        )
      ]);
    });
  }

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
                      if (data != null) {
                        onHandleScan(data);
                      }
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
