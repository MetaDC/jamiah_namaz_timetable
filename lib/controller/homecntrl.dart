import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jamiah_namaz_timetable/model/settingmodel.dart';

class Homecntrl extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collectionName = "namazTimes";

  NamazTimeModel? namazData;
  bool isLoading = false;

  Future<void> fetchData() async {
    isLoading = true;
    update();

    try {
      final query = await _db.collection(collectionName).limit(1).get();
      if (query.docs.isNotEmpty) {
        namazData = NamazTimeModel.fromSnap(query.docs.first);
      } else {
        /// If no data exists, create a fresh empty model
        namazData = NamazTimeModel(
          islamicDay: 1,
          islamicMonth: "Muharram",
          islamicYear: 1446,
          islamicDayName: "Saturday",
          englishDate: DateTime.now(),
          namazTime: {
            "Fajr": {"start": "", "end": ""},
            "Dhuhr": {"start": "", "end": ""},
            "Asr": {"start": "", "end": ""},
            "Maghrib": {"start": "", "end": ""},
            "Isha": {"start": "", "end": ""},
          },
          extraTime: {
            "Sehri": "",
            "Iftar": "",
            "Ishrak": "",
            "Chast": "",
            "Zawal": "",
            "Gurebe Aftab": "",
          },
        );
      }
    } catch (e) {
      print("Error fetching namaz data: $e");
    }

    isLoading = false;
    update();
  }


  Future<void> saveData(NamazTimeModel data) async {
    isLoading = true;
    update();

    try {
      final query = await _db.collection(collectionName).limit(1).get();

      if (query.docs.isNotEmpty) {
     
        await query.docs.first.reference.set(data.toMap());
      } else {
      
        await _db.collection(collectionName).add(data.toMap());
      }

      namazData = data;
    } catch (e) {
      print("Error saving namaz data: $e");
    }

    isLoading = false;
    update();
  }
}
