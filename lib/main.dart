import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jamiah_namaz_timetable/controller/homecntrl.dart';
import 'package:jamiah_namaz_timetable/model/settingmodel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class Cardpage extends StatefulWidget {
  const Cardpage({super.key});

  @override
  State<Cardpage> createState() => _CardpageState();
}

class _CardpageState extends State<Cardpage> {
  static const Color green = Color(0xFF4CAF50);

  final Homecntrl controller = Get.find<Homecntrl>();
  final ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchData();
    });
  }

  String formatEnglishDate(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    String weekdayName = weekdays[date.weekday - 1];
    return "${date.day}-${date.month}-${date.year}-$weekdayName";
  }

  Future<void> _shareCard() async {
    try {
      final image = await screenshotController.capture();
      if (image != null) {
        final tempDir = await getTemporaryDirectory();
        final file = await File(
          '${tempDir.path}/namaz_card_${DateTime.now().millisecondsSinceEpoch}.png',
        ).create();
        await file.writeAsBytes(image);

        await Share.shareXFiles([XFile(file.path)]);
      }
    } catch (e) {
      print('Error sharing: $e');
    }
  }

  String cleanTime(String? raw) {
    if (raw == null) return "--";
    String time = raw
        .replaceAll(RegExp(r'(am|pm)', caseSensitive: false), '')
        .trim();
    final parts = time.split(":");
    if (parts.length == 2) {
      final hour = parts[0].padLeft(2, '0');
      final minute = parts[1].padLeft(2, '0');
      return "$hour:$minute";
    }
    return time;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Namaz Timetable",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareCard,
          ),
        ],
      ),
      body: GetBuilder<Homecntrl>(
        builder: (controller) {
          final data = controller.namazData;

          final sehri = cleanTime(data?.extraTime["Sehri"]);
          final iftar = cleanTime(data?.extraTime["Iftar"]);
          final ishrak = cleanTime(data?.extraTime["Ishrak"]);
          final chast = cleanTime(data?.extraTime["Chast"]);
          final zawal = cleanTime(data?.extraTime["Zawal"]);
          final gaftab = cleanTime(data?.extraTime["Gurebe Aftab"]);

          return Center(
            child: SingleChildScrollView(
              child: Screenshot(
                controller: screenshotController,
                child: FittedBox(
                  child: Container(
                    width: 400, 
                    height: 700, 
                    decoration: BoxDecoration(
                      border: Border.all(),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              "assets/images/hedar-1.png",
                              width: 400,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 7,
                              left: 10,
                              child: Text(
                                '${data?.islamicDay}-${data?.islamicMonth}-${data?.islamicYear}-${data?.islamicDayName}',
                                style: GoogleFonts.roboto(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: green,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 7,
                              right: 10,
                              child: Text(
                                formatEnglishDate(data!.englishDate),
                                style: GoogleFonts.roboto(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.pink,
                                ),
                              ),
                            ),
                          ],
                        ),

                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildNamazTable(data),
                                    const SizedBox(height: 10),
                                    Image.asset(
                                      "assets/images/subfooter.1.png",
                                      height: 80,
                                      width: 300,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  SizedBox(
                                    width: 100,
                                    child: _buildSehriIftarCard(sehri, iftar),
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    width: 100,
                                    child: _buildIshrakCard(
                                      ishrak,
                                      chast,
                                      zawal,
                                      gaftab,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 5),
                        Image.asset(
                          "assets/images/footer-1.png",
                          height: 40,
                          width: 380,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  
  Widget _buildNamazTable(NamazTimeModel? data) {
    final times = [
      {"image": "assets/images/fzr.png", "name": "Fajr"},
      {"image": "assets/images/zhr.png", "name": "Dhuhr"},
      {"image": "assets/images/asr.png", "name": "Asr"},
      {"image": "assets/images/magrb.png", "name": "Maghrib"},
      {"image": "assets/images/isha.png", "name": "Isha"},
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset("assets/images/nm.png", width: 70),
            Image.asset("assets/images/av1.png", width: 70),
            Image.asset("assets/images/ak1.png", width: 70),
          ],
        ),
        const SizedBox(height: 8),
        ...times.map((entry) {
          final name = entry["name"]!;
          final image = entry["image"]!;
          final firstTime = cleanTime(data?.namazTime[name]?["start"]);
          final lastTime = cleanTime(data?.namazTime[name]?["end"]);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(flex: 1, child: Image.asset(image, height: 35)),
                const SizedBox(width: 3),
                Expanded(
                  flex: 1,
                  child: _buildCustomTimeCell(
                    time: firstTime,
                    bgImage: "assets/images/image16.png",
                    textColor: const Color(0xff3b5c38),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 1,
                  child: _buildCustomTimeCell(
                    time: lastTime,
                    bgImage: "assets/images/image17.png",
                    textColor: const Color(0xff9d2a2a),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCustomTimeCell({
    required String time,
    required String bgImage,
    required Color textColor,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(bgImage, width: 80, fit: BoxFit.contain),
        Text(
          time,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSehriIftarCard(String sehri, String iftar) {
    return Stack(
      children: [
        Image.asset(
          "assets/images/image19.png",
          height: 120,
          fit: BoxFit.contain,
        ),
        SizedBox(
          height: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "ખત્મે સેહરી",
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xff8f2e43),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                sehri,
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xff8f2e43),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Divider(),
              Text(
                "વકતે ઇફતાર",
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xff306d71),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                iftar,
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xff306d71),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIshrakCard(
    String ishrak,
    String chast,
    String zawal,
    String gaftab,
  ) {
    return Stack(
      children: [
        Image.asset(
          "assets/images/image7.png",
          height: 260,
          fit: BoxFit.contain,
        ),
        SizedBox(
          height: 260,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ishrakText("ઇશરાક", ishrak, const Color(0xff302c8e)),
              const Divider(),
              _ishrakText("ચાશ્ત", chast, const Color(0xff377bb8)),
              const Divider(),
              _ishrakText("ઝવાલ", zawal, const Color(0xff448532)),
              const Divider(),
              _ishrakText("ગુરૂબે\nઆફતાબ", gaftab, const Color(0xff876b61)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _ishrakText(String label, String time, Color color) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
