import 'package:flutter_test/flutter_test.dart';
import 'package:vlrs/model/bus_stop.dart';
import 'package:vlrs/utils/json_utils.dart';

void main() {
  final JsonUtils jsonUtils = JsonUtils();
  const String filePath1 = '../../assets/test_files/test_file_1.json';
  const String filePath2 = '../../assets/test_files/test_file_2.json';

  TestWidgetsFlutterBinding.ensureInitialized();

  group("Test: JSON Read Test", () {
    test('Test JSON Read #1 ...', () async {
      List<BusStop> expectedList = [
        BusStop(
            name: "1",
            latitude: -36.78125,
            longitude: 175.007,
            distanceToNextStop: 436),
        BusStop(
            name: "2",
            latitude: -36.78316,
            longitude: 175.01086,
            distanceToNextStop: 3731)
      ];

      List<BusStop> actualList =
          await jsonUtils.readBusStopDataFromJson(filePath1);

      for (int i = 0; i < actualList.length; i++) {
        expect(actualList[i].name, expectedList[i].name);
        expect(actualList[i].latitude, expectedList[i].latitude);
        expect(actualList[i].longitude, expectedList[i].longitude);
        expect(actualList[i].distanceToNextStop,
            expectedList[i].distanceToNextStop);
      }
    });

    test('Test JSON Read #2 ...', () async {
      List<BusStop> expectedList = [
        BusStop(
            name: "17",
            latitude: -36.78724,
            longitude: 175.00125,
            distanceToNextStop: 2002),
        BusStop(
            name: "S/E",
            latitude: -36.78012,
            longitude: 174.99216,
            distanceToNextStop: 1447)
      ];

      List<BusStop> actualList =
          await jsonUtils.readBusStopDataFromJson(filePath2);

      for (int i = 0; i < actualList.length; i++) {
        expect(actualList[i].name, expectedList[i].name);
        expect(actualList[i].latitude, expectedList[i].latitude);
        expect(actualList[i].longitude, expectedList[i].longitude);
        expect(actualList[i].distanceToNextStop,
            expectedList[i].distanceToNextStop);
      }
    });
  });
}
