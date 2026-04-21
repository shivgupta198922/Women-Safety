
import 'package:sensors_plus/sensors_plus.dart';

class FallDetector {

  void startDetection() {
    accelerometerEvents.listen((event) {
      if (event.x.abs() > 20 || event.y.abs() > 20) {
        print("Possible fall detected");
      }
    });
  }

}
