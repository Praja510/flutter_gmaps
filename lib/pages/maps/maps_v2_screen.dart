import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../models/gmaps_type.dart';

class MapsV2Screen extends StatefulWidget {
  const MapsV2Screen({Key? key}) : super(key: key);

  @override
  State<MapsV2Screen> createState() => _MapsV2ScreenState();
}

class _MapsV2ScreenState extends State<MapsV2Screen> {
  var mapType = MapType.normal;
  double latitude = -6.315843086890935;
  double longitude = 106.90425279337026;
  Position? devicePosition;
  late GoogleMapController _controller;
  String? address;

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Goggle Maps V2',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          PopupMenuButton(
            onSelected: onSelectedMapType,
            itemBuilder: (context) =>
                googleMapTypes
                    .map(
                      (mapType) =>
                      PopupMenuItem(
                        value: mapType.title,
                        child: Text(mapType.title),
                      ),
                )
                    .toList(),
          ),
        ],
      ),
      body: Stack(
        children: [
          //Google Maapas
          _buidMaps(),
          //card
          _buildSearchCard(),
        ],
      ),
    );
  }

  _buildSearchCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 150,
        width: double.infinity,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(10),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 8, bottom: 4),
                child: TextField(
                  decoration: InputDecoration(
                      hintText: 'Masukkan alamat...',
                      contentPadding: const EdgeInsets.only(top: 15, left: 15),
                      suffixIcon: IconButton(
                        onPressed: () {
                          searchLocation();
                        },
                        icon: const Icon(Icons.search),
                      )),
                  onChanged: (value) {
                    address = value;
                  },
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    getLocation().then((value) {
                      setState(() {
                        devicePosition = value;
                      });
                      final deviceLat = devicePosition?.latitude;
                      final deviceLng = devicePosition?.longitude;
                      final cameraPosition = CameraPosition(
                          target: LatLng(deviceLat!, deviceLng!), zoom: 17);
                      final cameraUpdate =
                      CameraUpdate.newCameraPosition(cameraPosition);
                      _controller.animateCamera(cameraUpdate);
                    });
                  },
                  child: const Text("Get My Location")),
              const SizedBox(
                height: 8,
              ),
              devicePosition == null
                  ? const Text("Lokasi belum terdeteksi")
                  : Text(
                  "My location ${devicePosition?.latitude} ${devicePosition
                      ?.longitude}")
            ],
          ),
        ),
      ),
    );
  }

  _buidMaps() =>
      GoogleMap(
        mapType: mapType,
        initialCameraPosition:
        CameraPosition(target: LatLng(latitude, longitude), zoom: 17),
        myLocationEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
      );

  void onSelectedMapType(String value) {
    setState(() {
      if (value == "Normal") {
        mapType = MapType.normal;
      } else if (value == "Hybrid") {
        mapType = MapType.hybrid;
      } else if (value == "Terrain") {
        mapType = MapType.terrain;
      } else if (value == "Satellite") {
        mapType = MapType.satellite;
      }
    });
  }

  Future requestPermission() async {
    await Permission.location.request();
  }

  Future<Position?> getLocation() async {
    Position? currentPosition;

    try {
      currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      currentPosition = null;
      rethrow;
    }
    return currentPosition;
  }

  Future searchLocation() async {
    try {
      await GeocodingPlatform.instance.locationFromAddress(address!).then((
          value) {
        final lat = value[0].latitude;
        final lng = value[0].longitude;
        final target = LatLng(lat, lng);
        final cameraPosition = CameraPosition(target: target, zoom: 17);
        final cameraUpdate = CameraUpdate.newCameraPosition(cameraPosition);
        return _controller.animateCamera(cameraUpdate);
      });
    } catch(e) {
      Fluttertoast.showToast(msg: "Alamat tidak ada bestie",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16);
    }
  }
}
