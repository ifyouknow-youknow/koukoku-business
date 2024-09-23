import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:koukoku_business/COMPONENTS/accordion_view.dart';
import 'package:koukoku_business/COMPONENTS/bargraph_view.dart';
import 'package:koukoku_business/COMPONENTS/blur_view.dart';
import 'package:koukoku_business/COMPONENTS/button_view.dart';
import 'package:koukoku_business/COMPONENTS/calendar_view.dart';
import 'package:koukoku_business/COMPONENTS/checkbox_view.dart';
import 'package:koukoku_business/COMPONENTS/circleprogress_view.dart';
import 'package:koukoku_business/COMPONENTS/dropdown_view.dart';
import 'package:koukoku_business/COMPONENTS/fade_view.dart';
import 'package:koukoku_business/COMPONENTS/iconbutton_view.dart';
import 'package:koukoku_business/COMPONENTS/loading_view.dart';
import 'package:koukoku_business/COMPONENTS/main_view.dart';
import 'package:koukoku_business/COMPONENTS/map_view.dart';
import 'package:koukoku_business/COMPONENTS/padding_view.dart';
import 'package:koukoku_business/COMPONENTS/pager_view.dart';
import 'package:koukoku_business/COMPONENTS/pill_view.dart';
import 'package:koukoku_business/COMPONENTS/progress_view.dart';
import 'package:koukoku_business/COMPONENTS/qrcode_view.dart';
import 'package:koukoku_business/COMPONENTS/roundedcorners_view.dart';
import 'package:koukoku_business/COMPONENTS/segmented_view.dart';
import 'package:koukoku_business/COMPONENTS/slider_view.dart';
import 'package:koukoku_business/COMPONENTS/switch_view.dart';
import 'package:koukoku_business/COMPONENTS/text_view.dart';
import 'package:koukoku_business/FUNCTIONS/colors.dart';
import 'package:koukoku_business/FUNCTIONS/date.dart';
import 'package:koukoku_business/FUNCTIONS/media.dart';
import 'package:koukoku_business/FUNCTIONS/misc.dart';
import 'package:koukoku_business/FUNCTIONS/recorder.dart';
import 'package:koukoku_business/FUNCTIONS/server.dart';
import 'package:koukoku_business/MODELS/coco.dart';
import 'package:koukoku_business/MODELS/constants.dart';
import 'package:koukoku_business/MODELS/DATAMASTER/datamaster.dart';
import 'package:koukoku_business/MODELS/firebase.dart';
import 'package:koukoku_business/MODELS/screen.dart';
import 'package:record/record.dart';

class PlaygroundView extends StatefulWidget {
  final DataMaster dm;
  const PlaygroundView({super.key, required this.dm});

  @override
  State<PlaygroundView> createState() => _PlaygroundViewState();
}

class _PlaygroundViewState extends State<PlaygroundView> {
  @override
  Widget build(BuildContext context) {
    return MainView(dm: widget.dm, children: [
      const PaddingView(
        child: Center(
          child: TextView(
            text: "Nothing defeats the Bagel.",
            size: 22,
            weight: FontWeight.w600,
          ),
        ),
      ),
      const SizedBox(
        height: 10,
      ),
      ButtonView(
          child: PillView(
            child: TextView(
              text: 'Press Me',
            ),
          ),
          onPress: () {
            setState(() {
              widget.dm.praiseTheBagel();
            });
          }),
      const SizedBox(
        height: 10,
      ),
    ]);
  }
}
