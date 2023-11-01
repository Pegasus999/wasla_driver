import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class API {
  static Future getClient() async {
    return [LatLng(36.811352, 7.720963), LatLng(36.805537, 7.713936)];
  }

  static Future getClientLocation() async {
    return LatLng(36.811352, 7.720963);
  }
}
