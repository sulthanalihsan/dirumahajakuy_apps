import 'package:dirumahajakuy/commons/color_palletes.dart';
import 'package:dirumahajakuy/commons/pref_helper.dart';
import 'package:dirumahajakuy/commons/sizes.dart';
import 'package:dirumahajakuy/const/app_constant.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:toast/toast.dart';

class ChooseHomeScreen extends StatefulWidget {
  @override
  _ChooseHomeScreenState createState() => _ChooseHomeScreenState();
}

class _ChooseHomeScreenState extends State<ChooseHomeScreen> {
  GoogleMapController mapController;
  Set<Marker> marker = {};
  Position position;

  getUserLocation() async {
    position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    setState(() {});
  }

  showAlert() {
    showDialog(
        context: context,
        builder: (_) => NetworkGiffyDialog(
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
                    '{"latitude":${position.latitude},"longitude":${position.longitude}}';
                PrefHelper.savePref(AppConst.locationPref, value);
                Navigator.pop(context);
                Toast.show("Lokasi Berhasil Disimpan", context,
                    duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
              },
            ));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorPalette.fontColor,
        title: Text('Set Lokasi Rumah Kamu'),
      ),
      body: GoogleMap(
        mapToolbarEnabled: false,
        initialCameraPosition: CameraPosition(
            target: LatLng(position?.latitude ?? -3.332996, position?.longitude ??114.6101297), zoom: 15.0),
        mapType: MapType.normal,
        markers: marker ?? {},
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorPalette.white,
        child: Icon(
          Icons.my_location,
          color: ColorPalette.fontColor,
        ),
        onPressed: () {
          setState(() {
            marker.clear();
            marker.add(Marker(
                markerId: MarkerId('Rumah Saya'),
                position: LatLng(position.latitude, position.longitude),
                infoWindow: InfoWindow(title: 'Rumah Saya'),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue)));
          });
        },
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        height: Sizes.height(context) / 10,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: RaisedButton(
            color: ColorPalette.fontColor,
            onPressed: () {
              showAlert();
            },
            child: Text('Set lokasi rumah saya',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: ColorPalette.white)),
          ),
        ),
      ),
    );
  }
}
