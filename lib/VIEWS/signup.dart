import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:koukoku_business/COMPONENTS/button_view.dart';
import 'package:koukoku_business/COMPONENTS/image_view.dart';
import 'package:koukoku_business/COMPONENTS/main_view.dart';
import 'package:koukoku_business/COMPONENTS/map_view.dart';
import 'package:koukoku_business/COMPONENTS/padding_view.dart';
import 'package:koukoku_business/COMPONENTS/roundedcorners_view.dart';
import 'package:koukoku_business/COMPONENTS/text_view.dart';
import 'package:koukoku_business/COMPONENTS/textfield_view.dart';
import 'package:koukoku_business/FUNCTIONS/colors.dart';
import 'package:koukoku_business/FUNCTIONS/nav.dart';
import 'package:koukoku_business/MODELS/DATAMASTER/datamaster.dart';
import 'package:koukoku_business/MODELS/constants.dart';
import 'package:koukoku_business/MODELS/firebase.dart';
import 'package:koukoku_business/MODELS/geohash.dart';
import 'package:koukoku_business/MODELS/screen.dart';
import 'package:koukoku_business/VIEWS/dashboard.dart';

class SignUp extends StatefulWidget {
  final DataMaster dm;
  const SignUp({super.key, required this.dm});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController _businessNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _contactController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  String address = "";
  LatLng? location = null;
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordConfirmController = TextEditingController();

  //
  void onSignUp() async {
    if (_businessNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _contactController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        address == "" ||
        location == null ||
        _passwordController.text.isEmpty ||
        _passwordConfirmController.text.isEmpty) {
      setState(() {
        widget.dm.alertMissingInfo();
      });
      return;
    }

    if (_passwordController.text != _passwordConfirmController.text) {
      setState(() {
        widget.dm.setToggleAlert(true);
        widget.dm.setAlertTitle('Password Not Confirmed');
        widget.dm.setAlertText('Please make sure your passwords match.');
      });
      return;
    }

    setState(() {
      widget.dm.setToggleLoading(true);
    });

    final user =
        await auth_CreateUser(_emailController.text, _passwordController.text);
    if (user != null) {
      final success =
          await firebase_CreateDocument('${appName}_Businesses', user.uid, {
        'email': _emailController.text,
        'address': address,
        'contactName': _contactController.text,
        'geohash': Geohash.encode(location!.latitude, location!.longitude),
        'location': {
          'latitude': location!.latitude,
          'longitude': location!.longitude
        },
        'name': _businessNameController.text,
        'phone': _phoneController.text
      });
      if (success) {
        setState(() {
          widget.dm.setToggleLoading(false);
        });
        nav_PushAndRemove(context, Analytics(dm: widget.dm));
      } else {
        setState(() {
          widget.dm.setToggleLoading(false);
          widget.dm.alertSomethingWrong();
        });
        return;
      }
    } else {
      setState(() {
        widget.dm.setToggleLoading(false);
        widget.dm.alertSomethingWrong();
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainView(dm: widget.dm, children: [
      PaddingView(
        paddingBottom: 0,
        child: ButtonView(
          child: Row(
            children: [
              Icon(
                Icons.arrow_back,
                size: 22,
              ),
              SizedBox(
                width: 5,
              ),
              TextView(
                text: 'login',
                size: 18,
              ),
            ],
          ),
          onPress: () {
            nav_Pop(context);
          },
        ),
      ),
      Center(
        child: ImageView(
          imagePath: 'assets/app-icon.png',
        ),
      ),
      Expanded(
        child: SingleChildScrollView(
          child: PaddingView(
            paddingTop: 0,
            child: SizedBox(
              width: getWidth(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextView(
                        text: 'Sign Up',
                        weight: FontWeight.w800,
                        size: 30,
                        spacing: -1,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextView(
                    text: 'business name',
                  ),
                  TextfieldView(
                    controller: _businessNameController,
                    placeholder: 'ex. Koukoku Ads LLC',
                    backgroundColor: hexToColor('#F6F8FA'),
                    isCap: true,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextView(
                    text: 'email',
                  ),
                  TextfieldView(
                    controller: _emailController,
                    placeholder: 'ex. bagel@koukokuads.com',
                    backgroundColor: hexToColor('#F6F8FA'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextView(
                    text: 'contact',
                  ),
                  TextfieldView(
                    controller: _contactController,
                    placeholder: 'ex. John Doe',
                    backgroundColor: hexToColor('#F6F8FA'),
                    isCap: true,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextView(
                    text: 'phone',
                  ),
                  TextfieldView(
                    controller: _phoneController,
                    placeholder: 'ex. 1234567890',
                    backgroundColor: hexToColor('#F6F8FA'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextView(
                    text: 'address',
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  RoundedCornersView(
                    child: MapView(
                      locations: [],
                      isSearchable: true,
                      height: 120,
                      onMarkerTap: (loc) => {
                        setState(() {
                          location = loc;
                        })
                      },
                      onSearchTap: (add) => {
                        setState(() {
                          address = add;
                        })
                      },
                    ),
                  ),
                  if (location == null)
                    TextView(
                      text:
                          'Tap the marker once you’ve verified the correct location on the map.',
                      wrap: true,
                    )
                  else
                    PaddingView(
                      child: Row(
                        children: [
                          Icon(
                            Icons.where_to_vote,
                            color: hexToColor('#4D76FF'),
                            size: 22,
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          TextView(
                            text: address,
                            wrap: true,
                            size: 14,
                            weight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                    height: 10,
                  ),
                  TextView(
                    text: 'password',
                  ),
                  TextfieldView(
                    controller: _passwordController,
                    placeholder: '8 characters minimum..',
                    backgroundColor: hexToColor('#F6F8FA'),
                    isPassword: true,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextView(
                    text: 'confirm password',
                  ),
                  TextfieldView(
                    controller: _passwordConfirmController,
                    placeholder: 'Passwords must match..',
                    backgroundColor: hexToColor('#F6F8FA'),
                    isPassword: true,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ButtonView(
                          paddingTop: 8,
                          paddingBottom: 8,
                          paddingLeft: 18,
                          paddingRight: 18,
                          radius: 100,
                          backgroundColor: hexToColor('#4D76FF'),
                          child: TextView(
                            text: 'sign up',
                            color: Colors.white,
                            size: 18,
                            weight: FontWeight.w600,
                          ),
                          onPress: () {
                            onSignUp();
                          }),
                    ],
                  ),
                  // ---------------------
                  SizedBox(
                    height: 100,
                  )
                ],
              ),
            ),
          ),
        ),
      )
    ]);
  }
}
