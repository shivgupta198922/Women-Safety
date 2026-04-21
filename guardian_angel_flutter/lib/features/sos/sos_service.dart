
import 'package:geolocator/geolocator.dart';

class SOSService {

  Future<String> getLocationLink() async {
    Position position = await Geolocator.getCurrentPosition();
    return "https://maps.google.com/?q=${position.latitude},${position.longitude}";
  }

}
