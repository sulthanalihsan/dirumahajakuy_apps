import 'dart:convert';

import 'package:dirumahajakuy/commons/color_palletes.dart';
import 'package:dirumahajakuy/commons/pref_helper.dart';
import 'package:dirumahajakuy/commons/sizes.dart';
import 'package:dirumahajakuy/const/app_constant.dart';
import 'package:dirumahajakuy/models/challenge_response.dart';
import 'package:dirumahajakuy/notifier/data_challenge_notifier.dart';
import 'package:dirumahajakuy/notifier/user_location_notifier.dart';
import 'package:dirumahajakuy/widgets/custom_item_challenge/item_challenge.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  GoogleMapController mapController;
  Set<Marker> marker = {};
  LatLng latLng;
  List<Placemark> placemark = [];
  UserLocationNotifier userLocNotifier;

  getUserLocation() async {
    PrefHelper.getPref(AppConst.locationPref).then((result) {
      if (result is bool) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: Text('Atur lokasi rumah anda terlebih dahulu'),
                  actions: <Widget>[
                    RaisedButton(
                      child: Text("Load Google Map"),
                      onPressed: () {
                        pickLocation();
                      },
                    ),
                  ],
                ));
      } else {
        setState(() {
          latLng = LatLng(
              jsonDecode(result)['latitude'], jsonDecode(result)['longitude']);
          marker.clear();
          marker.add(Marker(
              markerId: MarkerId('Rumah Saya'),
              position: LatLng(latLng.latitude, latLng.longitude),
              infoWindow: InfoWindow(title: 'Rumah Saya'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue)));
          getAddress();
        });
      }
    });
  }

  getAddress() async {
    placemark = await Geolocator()
        .placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(
          latLng.latitude,
          latLng.longitude,
        ),
        zoom: 20.0)));
    setState(() {});
  }

  pickLocation()  {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return PlacePicker(
            apiKey:
            'YOUR_KEY',
            initialPosition: LatLng(-0.7893, 113.9213),
            useCurrentLocation: true,
            onPlacePicked: (result) {
//              print('LOKASI ${result.geometry.location.lat} ${result.geometry.location.lng}');
              userLocNotifier.selectedPlace = result;
              showAlert(context);
            },
          );
        },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  showAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => NetworkGiffyDialog(
              image: Image.asset(
                "assets/besepeda.gif",
                fit: BoxFit.cover,
              ),
              title: Text('Apakah anda yakin?',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600)),
              description: Text(
                'Menyimpan lokasi rumah anda?',
                textAlign: TextAlign.center,
              ),
              entryAnimation: EntryAnimation.TOP,
              buttonOkColor: Color(0xffff5e92),
              buttonCancelColor: Colors.black12,
              onOkButtonPressed: () {
                var value =
                    '{"latitude":${userLocNotifier.selectedPlace.geometry.location.lat},"longitude":${userLocNotifier.selectedPlace.geometry.location.lng}}';
                PrefHelper.savePref(AppConst.locationPref, value);
                Navigator.of(context).popUntil((route) => route.isFirst);
                Toast.show("Lokasi Berhasil Disimpan", context,
                    duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
              },
            ));
  }

  @override
  Widget build(BuildContext context) {
    var dataChallengeNotif = Provider.of<DataChallengeNotifier>(context);
    userLocNotifier = Provider.of<UserLocationNotifier>(context);

    return Scaffold(
      appBar: AppBar(
          elevation: 0.0,
          backgroundColor: ColorPalette.fontColor,
          title: Text(
            'ACCOUNT',
            style: TextStyle(
              color: ColorPalette.white,
            ),
          )),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: ColorPalette.fontColor)),
            height: Sizes.width(context) / 2.2,
            child: GoogleMap(
              mapToolbarEnabled: false,
              initialCameraPosition: CameraPosition(
                  target: LatLng(
                    -2.2751529,
                    99.405943,
                  ),
                  zoom: 1.0),
              mapType: MapType.normal,
              markers: marker,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: SizedBox(
              width: Sizes.width(context),
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 3.0,
                child: InkWell(
                  onTap: () {
                    pickLocation();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RichText(
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(children: [
                        TextSpan(
                            text: 'Rumah saya 📍: ',
                            style: TextStyle(
                                color: ColorPalette.fontColor,
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold)),
                        placemark.isNotEmpty
                            ? TextSpan(
                                text:
                                    '${placemark[0].thoroughfare}, ${placemark[0].subLocality}, ${placemark[0].subAdministrativeArea}',
                                style: TextStyle(
                                  color: ColorPalette.fontColor,
                                  fontSize: 12.0,
                                ))
                            : TextSpan(
                                text: 'Belum diatur',
                                style: TextStyle(
                                  color: ColorPalette.fontColor,
                                  fontSize: 12.0,
                                ))
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Text('YOUR FINISHED CHALLENGE',
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Color(0xffff0863),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.3)),
          ),
          Expanded(
            child: FutureBuilder<List<Challenge>>(
                future: dataChallengeNotif.getAllChallange(2),
                builder: (context, AsyncSnapshot<List<Challenge>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(
                      backgroundColor: ColorPalette.fontColor,
                    ));
                  } else if (snapshot.hasData) {
                    List<Challenge> data = snapshot.data;
                    if (data.length == 0) {
                      return Center(child: Text('Data tidak adaa'));
                    }
                    return ListView.builder(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 8.0),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          Challenge challenge = data[index];

                          return ItemChallenge(
                            titleDialog: 'Your finished challenge!',
                            descriptionDialog:
                                'Hadiah yang telah anda dapatkan\n"${challenge.prizeDescription}"\nVoucher: 3413 4213 5235',
                            fontColor: ColorPalette.fontColor,
                            titleWidget: challenge.challengeName,
                            subtitleWidget: 'Challenge Berhasil',
                            trailingWidget: challenge.prize,
                            leadingWidget: challenge.brandImage,
                            onDialogOkButtonPressed: () async {},
                          );
                        });
                  } else {
                    return Center(child: Text('Data tidak adaaaa'));
                  }
                }),
          )
        ],
      ),
    );
  }
}
