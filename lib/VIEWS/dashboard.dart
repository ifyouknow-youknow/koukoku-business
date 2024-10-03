import 'package:flutter/material.dart';
import 'package:koukoku_business/COMPONENTS/asyncimage_view.dart';
import 'package:koukoku_business/COMPONENTS/border_view.dart';
import 'package:koukoku_business/COMPONENTS/button_view.dart';
import 'package:koukoku_business/COMPONENTS/future_view.dart';
import 'package:koukoku_business/COMPONENTS/iconbutton_view.dart';
import 'package:koukoku_business/COMPONENTS/main_view.dart';
import 'package:koukoku_business/COMPONENTS/padding_view.dart';
import 'package:koukoku_business/COMPONENTS/pill_view.dart';
import 'package:koukoku_business/COMPONENTS/roundedcorners_view.dart';
import 'package:koukoku_business/COMPONENTS/segmented_view.dart';
import 'package:koukoku_business/COMPONENTS/text_view.dart';
import 'package:koukoku_business/FUNCTIONS/colors.dart';
import 'package:koukoku_business/FUNCTIONS/date.dart';
import 'package:koukoku_business/FUNCTIONS/media.dart';
import 'package:koukoku_business/FUNCTIONS/misc.dart';
import 'package:koukoku_business/MODELS/DATAMASTER/datamaster.dart';
import 'package:koukoku_business/MODELS/constants.dart';
import 'package:koukoku_business/MODELS/firebase.dart';

class Analytics extends StatefulWidget {
  final DataMaster dm;
  const Analytics({super.key, required this.dm});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  String _status = 'Active';
  //
  Future<List<dynamic>> _fetchCampaigns() async {
    //
    final docs = await firebase_GetAllDocumentsOrderedQueriedLimited(
        '${appName}_Campaigns',
        [
          {'field': 'userId', 'operator': '==', 'value': widget.dm.user['id']},
          {'field': 'active', 'operator': '==', 'value': true}
        ],
        'date',
        'desc',
        10);
    // DO THE CLICKS AND VIEWS THING
    for (var ad in docs) {
      final adId = ad['id'];
      final views = await firebase_GetAllDocumentsQueried('${appName}_Views', [
        {'field': 'adId', 'operator': '==', 'value': adId}
      ]);
      final viewsCount = views.length;
      await firebase_UpdateDocument('${appName}_Campaigns', adId, {
        'seenViews':
            ad['seenViews'] != null ? ad['seenViews'] + viewsCount : viewsCount
      });
      for (var view in views) {
        await firebase_DeleteDocument('${appName}_Views', view['id']);
      }
      //
      final clicks =
          await firebase_GetAllDocumentsQueried('${appName}_Clicks', [
        {'field': 'adId', 'operator': '==', 'value': adId}
      ]);
      final clicksCount = clicks.length;
      await firebase_UpdateDocument('${appName}_Campaigns', adId, {
        'clicks':
            ad['clicks'] != null ? ad['clicks'] + clicksCount : clicksCount
      });
      for (var click in clicks) {
        await firebase_DeleteDocument('${appName}_Clicks', click['id']);
      }
    }
    final newDocs = await firebase_GetAllDocumentsOrderedQueriedLimited(
        '${appName}_Campaigns',
        [
          {'field': 'userId', 'operator': '==', 'value': widget.dm.user['id']},
          {'field': 'active', 'operator': '==', 'value': true}
        ],
        'date',
        'desc',
        10);
    return newDocs;
  }

  // FUNCTIONS
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
                  widget.dm.setAlertButtons([]);
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
            Column(children: [
              PaddingView(
                paddingTop: 0,
                paddingBottom: 0,
                child: Row(
                  children: [
                    TextView(
                      text: 'Dashboard',
                      size: 20,
                      weight: FontWeight.w600,
                      spacing: -1,
                    ),
                  ],
                ),
              ),
              //
              //SEGMENTED
              PaddingView(
                paddingLeft: 0,
                paddingRight: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SegmentedView(
                      options: ['Active', 'Completed'],
                      borderColor: hexToColor("#FF1F54"),
                      value: _status,
                      setter: (status) {
                        setState(() {
                          _status = status;
                        });
                      },
                    ),
                  ],
                ),
              ),
              //
              if (_status == 'Active')
                Expanded(
                    child: SingleChildScrollView(
                  child: Column(
                    children: [
                      FutureView(
                          future: _fetchCampaigns(),
                          childBuilder: (ads) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (var ad in ads)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      PaddingView(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            AsyncImageView(
                                              imagePath: ad['imagePath'],
                                              radius: 15,
                                              width: 120,
                                              height: 120,
                                            ),
                                            SizedBox(
                                              width: 15,
                                            ),
                                            Expanded(
                                                child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                PillView(
                                                  backgroundColor:
                                                      hexToColor("#F6F8FA"),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      TextView(
                                                        text: ad['isCoupon']
                                                            ? 'Coupon'
                                                            : 'Ad',
                                                        size: 20,
                                                        weight: FontWeight.w600,
                                                      ),
                                                      TextView(
                                                        text:
                                                            '${ad['chosenOption']} size',
                                                        wrap: true,
                                                        size: 16,
                                                        weight: FontWeight.w500,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                PillView(
                                                  backgroundColor:
                                                      hexToColor('#E9F1FA'),
                                                  child: Row(
                                                    children: [
                                                      if (ad['seenViews'] !=
                                                          null)
                                                        TextView(
                                                          text: ad['seenViews']
                                                              .toString(),
                                                          size: 50,
                                                          weight:
                                                              FontWeight.w600,
                                                          spacing: -1,
                                                        ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      if (ad['seenViews'] ==
                                                          null)
                                                        TextView(
                                                          text: '0',
                                                          size: 50,
                                                          weight:
                                                              FontWeight.w600,
                                                          spacing: -1,
                                                        ),
                                                      TextView(
                                                        text:
                                                            '/${ad['views']} views',
                                                        size: 16,
                                                        weight: FontWeight.w400,
                                                        spacing: -1,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                PillView(
                                                  backgroundColor:
                                                      hexToColor("#F6F8FA"),
                                                  child: Row(
                                                    children: [
                                                      TextView(
                                                        text:
                                                            '${ad['clicks'] != null ? ad['clicks'] : 0}',
                                                        wrap: true,
                                                        size: 26,
                                                        weight: FontWeight.w600,
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      TextView(
                                                        text: 'clicks',
                                                        wrap: true,
                                                        size: 16,
                                                        weight: FontWeight.w400,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (ad['isCoupon'])
                                                  Column(
                                                    children: [
                                                      SizedBox(
                                                        height: 15,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          PillView(
                                                            backgroundColor:
                                                                hexToColor(
                                                                    "#FF1F54"),
                                                            child: TextView(
                                                              text:
                                                                  'expires ${formatShortDate(
                                                                DateTime
                                                                    .fromMillisecondsSinceEpoch(
                                                                  ad['date'],
                                                                ),
                                                              )}',
                                                              size: 14,
                                                              weight: FontWeight
                                                                  .w600,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  )
                                              ],
                                            ))
                                          ],
                                        ),
                                      ),
                                      Divider(
                                        height: 20,
                                        color: Colors.black12,
                                      )
                                    ],
                                  )
                              ],
                            );
                          },
                          emptyWidget: Center(
                            child: TextView(
                              text: 'No active campaigns',
                            ),
                          )),
                      SizedBox(
                        height: 100,
                      )
                    ],
                  ),
                ))
            ]),

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
