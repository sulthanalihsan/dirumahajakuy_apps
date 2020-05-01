import 'dart:async';

import 'package:background_fetch/background_fetch.dart';
import 'package:dirumahajakuy/commons/color_palletes.dart';
import 'package:dirumahajakuy/commons/database_helper.dart';
import 'package:dirumahajakuy/commons/pref_helper.dart';
import 'package:dirumahajakuy/const/app_constant.dart';
import 'package:dirumahajakuy/notifier/data_challenge_notifier.dart';
import 'package:dirumahajakuy/notifier/user_location_notifier.dart';
import 'package:dirumahajakuy/screens/account_screen.dart';
import 'package:dirumahajakuy/screens/first_tab.dart';
import 'package:dirumahajakuy/screens/on_boarding_screen.dart';
import 'package:dirumahajakuy/screens/second_tab.dart';
import 'package:dirumahajakuy/service/location_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:location/location.dart' as locationq;
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

void backgroundFetchHeadlessTask(String taskId) async {
  print("[BackgroundFetch] Headless event received: $taskId");
  BackgroundFetch.finish(taskId);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var isFirst = true;
  try {
    isFirst = await PrefHelper.read(AppConst.isFirst);
  } catch (e) {
    print('EROR CUY');
  }
  runApp(MyApp(isFirst: isFirst));
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MyApp extends StatelessWidget {
  final isFirst;

  const MyApp({this.isFirst});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DataChallengeNotifier>(
            create: (context) => DataChallengeNotifier()),
        ChangeNotifierProvider<UserLocationNotifier>(
            create: (context) => UserLocationNotifier())
      ],
      child: new MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '#DirumahAjaKuy Apps',
        theme: new ThemeData(
          accentColor: ColorPalette.fontColor,
          buttonTheme: ButtonThemeData(
            buttonColor: ColorPalette.fontColor,
          ),
        ),
//        home: new AppClock(),
        home: isFirst ? OnBoardingPage() : AppClock(),
      ),
    );
  }
}

class AppClock extends StatefulWidget {
  @override
  _AppClockState createState() => _AppClockState();
}

class _AppClockState extends State<AppClock>
    with SingleTickerProviderStateMixin {
  UserLocationNotifier userLocNotifier;
  DataChallengeNotifier dataChallengeNotif;

  StreamSubscription<Position> _positionStreamSubscription;

  TabController _tabController;

  void savePrefFirst() async {
    await PrefHelper.save(AppConst.isFirst, false);
  }

  void _toggleListening() {
    if (_positionStreamSubscription == null) {
      const LocationOptions locationOptions =
          LocationOptions(accuracy: LocationAccuracy.medium);
      final Stream<Position> positionStream =
          Geolocator().getPositionStream(locationOptions);
      _positionStreamSubscription =
          positionStream.listen((Position position) async {
        if (dataChallengeNotif.listChallenge.length > 0) {
          await LocationService.userDistanceFromHome(position).then((distance) {
            userLocNotifier.userLocationCheck(distance);
            if (userLocNotifier.outOfRadius) {
              if (_positionStreamSubscription != null) {
                _positionStreamSubscription.cancel();
                _positionStreamSubscription = null;
              }
            }
          });
        }
        print(position == null
            ? 'Unknown'
            : position.latitude.toString() +
                ', ' +
                position.longitude.toString());
      });
      _positionStreamSubscription.pause();
    }

    setState(() {
      if (_positionStreamSubscription.isPaused) {
        _positionStreamSubscription.resume();
      } else {
        _positionStreamSubscription.pause();
      }
    });
  }

  void _getMylocation() async {
    var currentLocation;
    try {
      if (!await Geolocator().isLocationServiceEnabled()) {
        locationq.Location().requestService().then((_) async {
          currentLocation = await Geolocator()
              .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
          userLocNotifier.position = currentLocation;
        });
      } else {
        currentLocation = await Geolocator()
            .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
        userLocNotifier.position = currentLocation;
      }
      if (dataChallengeNotif.listChallenge.length > 0) {
        Position userLocation = Position(
            latitude: userLocNotifier.position.latitude,
            longitude: userLocNotifier.position.longitude);
        await LocationService.userDistanceFromHome(userLocation)
            .then((distance) {
          userLocNotifier.userLocationCheck(distance);
        });
      }
    } catch (e) {
      throw (e);
    }
    return currentLocation;
  }

  void _cekPref() async {
    await PrefHelper.getPref(AppConst.locationPref).then((result) async {
      if (result is bool) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: Text('Atur lokasi rumah anda terlebih dahulu'),
                  actions: <Widget>[
                    RaisedButton(
                      child: Text("Atur lokasi rumah"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return PlacePicker(
                                apiKey:
                                    'YOUR_KEY',
                                initialPosition: LatLng(-0.7893, 113.9213),
                                useCurrentLocation: true,
                                onPlacePicked: (result) {
                                  userLocNotifier.selectedPlace = result;
                                  _showAlert(
                                      title: 'Apakah anda yakin?',
                                      description:
                                          'Menyimpan lokasi rumah anda?',
                                      onOkButtonPressed: () {
                                        var value =
                                            '{"latitude":${userLocNotifier.selectedPlace.geometry.location.lat},"longitude":${userLocNotifier.selectedPlace.geometry.location.lng}}';
                                        PrefHelper.savePref(
                                            AppConst.locationPref, value);
                                        Navigator.of(context)
                                            .popUntil((route) => route.isFirst);
                                        Toast.show(
                                            "Lokasi Berhasil Disimpan", context,
                                            duration: Toast.LENGTH_SHORT,
                                            gravity: Toast.BOTTOM);
                                      });
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ));
      }
    });
    _getMylocation();
  }

  void _cekOutOfRadius() {
    if (userLocNotifier.outOfRadius) {
      userLocNotifier.outOfRadius = false;
//      DatabaseHelper.db.getAllChallange(1).then((listChallenge){
      if (dataChallengeNotif.listChallenge.length > 0) {
        showDialog(
            context: context,
            builder: (_) => NetworkGiffyDialog(
                  image: Image.asset(
                    "assets/sad.gif",
                    fit: BoxFit.cover,
                  ),
                  title: Text('Challenge Anda Gagal',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.w600)),
                  description: Text('Anda ketahuan keluar rumah :p'),
                  entryAnimation: EntryAnimation.TOP,
                  onlyOkButton: true,
                  onOkButtonPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ));
      }
//      });
    }
  }

  void _showAlert(
      {String title, String description, Function onOkButtonPressed}) {
    showDialog(
        context: context,
        builder: (context) => NetworkGiffyDialog(
              image: Image.asset(
                "assets/besepeda.gif",
                fit: BoxFit.cover,
              ),
              title: Text(title,
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600)),
              description: Text(
                description,
                textAlign: TextAlign.center,
              ),
              entryAnimation: EntryAnimation.TOP,
              buttonOkColor: Color(0xffff5e92),
              buttonCancelColor: Colors.black12,
              onOkButtonPressed: () {
                onOkButtonPressed();
              },
            ));
  }

  void _cekChallenge() {
    DatabaseHelper.db.getAllChallange(1).then((listChallenge) {
      if (listChallenge.length > 0) {
        listChallenge.forEach((item) {
          DateTime now = DateTime.now();
          DateTime ended = DateTime.parse(item.challengeEnded);

          var dummyNow = DateTime.parse('2020-04-14 15:52:26.750800');
          var dummyEnded = DateTime.parse('2020-04-13 14:52:10.796611');

          if (!now.difference(ended).isNegative) {
            DatabaseHelper.db.setChallenge(item, 2);
            Timer(Duration(seconds: 2), () {
              _showAlert(
                  title: 'Selamat Challenge Selesai',
                  description:
                      'Anda berhasil mendapatkan\nHadiah: ${item.prizeDescription}\nSilahkan buka menu akun',
                  onOkButtonPressed: () {
                    Navigator.pop(context);
                  });
            });
          } else {
            //do nothing
            print('NEGATIVE CUY');
          }
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userLocNotifier = Provider.of<UserLocationNotifier>(context);
    dataChallengeNotif = Provider.of<DataChallengeNotifier>(context);
    _cekChallenge();
    _cekOutOfRadius();
    BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 15,
            stopOnTerminate: false,
            startOnBoot: true,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresDeviceIdle: false,
            requiresStorageNotLow: false,
            requiredNetworkType: NetworkType.ANY,
            enableHeadless: true), (String taskId) async {
      var currentLocation;
      try {
        DatabaseHelper.db.getAllChallange(1).then((listChallenge) async {
          if (listChallenge.length > 0) {
            currentLocation = await Geolocator()
                .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
                .then((result) async {
              Position userLocation = Position(
                  latitude: result.latitude, longitude: result.longitude);
              await LocationService.userDistanceFromHome(userLocation)
                  .then((distance) {
                userLocNotifier.userLocationCheck(distance);
              });
              return result;
            });
            _cekChallenge();
          } else {
            print('Challenge Tidak Ada');
          }
        });
        print(currentLocation.toString());
      } catch (e) {
        print("ERRORRRR" + e.toString());
      }
      BackgroundFetch.finish(taskId);
    });
  }

  @override
  void initState() {
    super.initState();
    savePrefFirst();
    _tabController = TabController(vsync: this, length: 2);
    _cekPref();
    _toggleListening();
  }

  @override
  void dispose() {
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription.cancel();
      _positionStreamSubscription = null;
    }
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600.0,
      width: double.infinity,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(55.0),
              child: Container(
                color: Colors.transparent,
                child: SafeArea(
                  child: Column(
                    children: <Widget>[
                      TabBar(
                        controller: _tabController,
                        indicator: UnderlineTabIndicator(
                            borderSide: BorderSide(
                                color: Color(0xffff0863), width: 4.0),
                            insets: EdgeInsets.fromLTRB(40.0, 20.0, 40.0, 0)),
//                        indicatorSize: TabBarIndicatorSize.label,
                        indicatorWeight: 15.0,
                        labelColor: Color(0xff2d386b),
                        labelStyle: TextStyle(
                            fontSize: 12.0,
                            letterSpacing: 1.3,
                            fontWeight: FontWeight.w500),
                        unselectedLabelColor: Colors.black26,
                        tabs: <Widget>[
                          Tab(
                            text: "RECORD",
                            icon: Icon(
                              Icons.watch_later,
                              size: 40.0,
                            ),
                          ),
                          Tab(
                            text: "CHALLENGE",
                            icon: Icon(
                              Icons.bubble_chart,
                              size: 40.0,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: <Widget>[
              Center(child: FirstTab()),
//              Center(child: SecondTab()),
              Center(child: SecondTab(_tabController)),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.account_circle),
            onPressed: () {
//              AppSettings.openLocationSettings();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AccountScreen()));
            },
          ),
        ),
      ),
    );
  }
}
