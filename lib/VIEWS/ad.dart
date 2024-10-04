import 'package:flutter/material.dart';
import 'package:koukoku_business/COMPONENTS/border_view.dart';
import 'package:koukoku_business/COMPONENTS/button_view.dart';
import 'package:koukoku_business/COMPONENTS/future_view.dart';
import 'package:koukoku_business/COMPONENTS/main_view.dart';
import 'package:koukoku_business/COMPONENTS/padding_view.dart';
import 'package:koukoku_business/COMPONENTS/pill_view.dart';
import 'package:koukoku_business/COMPONENTS/roundedcorners_view.dart';
import 'package:koukoku_business/COMPONENTS/segmented_view.dart';
import 'package:koukoku_business/COMPONENTS/text_view.dart';
import 'package:koukoku_business/FUNCTIONS/colors.dart';
import 'package:koukoku_business/FUNCTIONS/date.dart';
import 'package:koukoku_business/FUNCTIONS/nav.dart';
import 'package:koukoku_business/MODELS/DATAMASTER/datamaster.dart';
import 'package:koukoku_business/MODELS/constants.dart';
import 'package:koukoku_business/MODELS/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:koukoku_business/MODELS/screen.dart';
import 'package:koukoku_business/VIEWS/user_scans.dart'; // Ensure you import Firestore

class Ad extends StatefulWidget {
  final DataMaster dm;
  final Map<String, dynamic> ad;
  const Ad({super.key, required this.dm, required this.ad});

  @override
  State<Ad> createState() => _AdState();
}

class _AdState extends State<Ad> {
  String _option = "Scans";
  DocumentSnapshot? _lastDocument; // Track last document for pagination
  List<dynamic> _scans = []; // Store the fetched scans
  bool _isLoading = false; // Track loading state
  bool _hasMore = true; // Check if more scans can be loaded

  // Fetch Scans and Append to List
  Future<void> _fetchScans() async {
    if (_isLoading || !_hasMore) return; // Prevent multiple requests

    setState(() {
      _isLoading = true;
    });

    final docs = await firebase_GetAllDocumentsQueriedOrderedLimitedPaginated(
      '${appName}_Scans',
      [
        {'field': 'adId', 'operator': '==', 'value': widget.ad['id']},
      ],
      'date',
      true,
      50,
      _lastDocument, // Pass the last document for pagination
    );
    //
    final newDocs = [];
    for (var scan in docs) {
      final doc =
          await firebase_GetDocument('${appName}_Users', scan['userId']);
      final obj = {...scan, 'user': doc};
      newDocs.add(obj);
    }

    if (newDocs.isNotEmpty) {
      setState(() {
        _lastDocument =
            newDocs.last['documentSnapshot']; // Update the last document
        _scans.addAll(newDocs); // Append the new scans
      });
    } else {
      setState(() {
        _hasMore = false; // No more scans to load
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchScans(); // Initial scan fetch
  }

  @override
  Widget build(BuildContext context) {
    return MainView(
      dm: widget.dm,
      children: [
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
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SegmentedView(
              options: ['Scans', 'Analytics'],
              textSize: 16,
              borderColor: hexToColor("#FF1F54"),
              value: _option,
              setter: (option) {
                setState(() {
                  _option = option;
                });
              },
            ),
          ],
        ),
        //
        if (_option == 'Scans')
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (_scans.isNotEmpty)
                    Column(
                      children: [
                        for (var scan in _scans)
                          BorderView(
                            bottom: true,
                            bottomColor: Colors.black12,
                            child: ButtonView(
                              onPress: () {
                                nav_Push(
                                  context,
                                  UserScans(
                                    dm: widget.dm,
                                    user: scan['user'],
                                    adId: scan['adId'],
                                  ),
                                );
                              },
                              child: PaddingView(
                                child: Row(
                                  children: [
                                    Icon(Icons.qr_code),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextView(
                                          text:
                                              '${scan['user']['firstName']} ${scan['user']['lastName']}',
                                          size: 17,
                                          weight: FontWeight.w500,
                                          font: 'poppins',
                                        ),
                                        TextView(
                                          text:
                                              'scanned on ${formatDate(DateTime.fromMillisecondsSinceEpoch(scan['date']))}',
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  else
                    PaddingView(
                      child: const Center(
                        child: PaddingView(
                          child: TextView(
                            text: 'No scans yet.',
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  if (_hasMore)
                    PaddingView(
                      child: ButtonView(
                          child: PillView(
                            backgroundColor: hexToColor('#F6F8FA'),
                            child: TextView(
                              text: _isLoading ? 'Loading...' : 'see more..',
                            ),
                          ),
                          onPress: () {
                            _fetchScans();
                          }),
                    )
                  else
                    PaddingView(
                      child: TextView(
                        text: 'No more scans',
                      ),
                    )
                ],
              ),
            ),
          ),
        if (_option == 'Analytics')
          Expanded(
              child: SingleChildScrollView(
            child: PaddingView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RoundedCornersView(
                      backgroundColor: hexToColor('#E9F1FA'),
                      child: PaddingView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextView(
                              text: 'views',
                              size: 18,
                              color: Colors.black87,
                              weight: FontWeight.w400,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                TextView(
                                  text: widget.ad['seenViews'].toString(),
                                  size: 50,
                                  weight: FontWeight.w600,
                                ),
                                TextView(
                                  text: '/ ${widget.ad['views']}',
                                  size: 18,
                                )
                              ],
                            )
                          ],
                        ),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  RoundedCornersView(
                      backgroundColor: hexToColor('#E9F1FA'),
                      child: PaddingView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextView(
                              text: 'clicks',
                              size: 18,
                              color: Colors.black87,
                              weight: FontWeight.w400,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                TextView(
                                  text: widget.ad['clicks'].toString(),
                                  size: 50,
                                  weight: FontWeight.w600,
                                ),
                              ],
                            )
                          ],
                        ),
                      ))
                ],
              ),
            ),
          ))
      ],
    );
  }
}
