import 'package:flutter/material.dart';
import 'package:koukoku_business/COMPONENTS/border_view.dart';
import 'package:koukoku_business/COMPONENTS/button_view.dart';
import 'package:koukoku_business/COMPONENTS/future_view.dart';
import 'package:koukoku_business/COMPONENTS/main_view.dart';
import 'package:koukoku_business/COMPONENTS/padding_view.dart';
import 'package:koukoku_business/COMPONENTS/text_view.dart';
import 'package:koukoku_business/FUNCTIONS/date.dart';
import 'package:koukoku_business/FUNCTIONS/nav.dart';
import 'package:koukoku_business/MODELS/DATAMASTER/datamaster.dart';
import 'package:koukoku_business/MODELS/constants.dart';
import 'package:koukoku_business/MODELS/firebase.dart';
import 'package:koukoku_business/MODELS/screen.dart';

class UserScans extends StatefulWidget {
  final DataMaster dm;
  final Map<String, dynamic> user;
  final String adId;
  const UserScans(
      {super.key, required this.dm, required this.user, required this.adId});

  @override
  State<UserScans> createState() => _UserScansState();
}

class _UserScansState extends State<UserScans> {
  Future<List<dynamic>> _fetchScans() async {
    final scans = await firebase_GetAllDocumentsOrderedQueried(
        '${appName}_Scans',
        [
          {'field': 'userId', 'operator': '==', 'value': widget.user['id']},
          {'field': 'adId', 'operator': '==', 'value': widget.adId}
        ],
        'date',
        'desc');
    return scans;
  }

  //
  @override
  Widget build(BuildContext context) {
    return MainView(dm: widget.dm, children: [
      PaddingView(
        paddingBottom: 0,
        child: Column(
          children: [
            ButtonView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.chevron_left,
                    size: 24,
                  ),
                  const SizedBox(width: 5),
                  const TextView(
                    text: 'back',
                    size: 16,
                  ),
                ],
              ),
              onPress: () {
                nav_Pop(context);
              },
            ),
          ],
        ),
      ),
      //
      PaddingView(
        child: SizedBox(
          width: getWidth(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextView(
                text: '${widget.user['firstName']} ${widget.user['lastName']}',
                size: 18,
                weight: FontWeight.w600,
                font: 'poppins',
              ),
            ],
          ),
        ),
      ),
      //
      Expanded(
          child: SingleChildScrollView(
        child: FutureView(
            future: _fetchScans(),
            childBuilder: (scans) {
              return Column(
                children: [
                  for (var scan in scans)
                    BorderView(
                      bottom: true,
                      bottomColor: Colors.black12,
                      child: PaddingView(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.qr_code,
                              size: 24,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            TextView(
                              text:
                                  '${formatDate(DateTime.fromMillisecondsSinceEpoch(scan['date']))} ${formatTime(
                                DateTime.fromMillisecondsSinceEpoch(
                                  scan['date'],
                                ),
                              )}',
                              size: 16,
                            )
                          ],
                        ),
                      ),
                    )
                ],
              );
            },
            emptyWidget: Center(
              child: PaddingView(
                  child: TextView(
                text: 'No scans yet.',
              )),
            )),
      ))
    ]);
  }
}
