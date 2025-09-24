import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jamiah_namaz_timetable/controller/homecntrl.dart';
import 'package:jamiah_namaz_timetable/model/settingmodel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Cardpage extends StatefulWidget {
  const Cardpage({super.key});

  @override
  State<Cardpage> createState() => _CardpageState();
}

class _CardpageState extends State<Cardpage> {
  static const Color green = Color(0xFF4CAF50);
  static const Color red = Color(0xFFF44336);

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
        title: Text(
          "Namaz Timetable",
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
        ),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white, size: 22.sp),
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

          return SingleChildScrollView(
            padding: EdgeInsets.all(12.w),
            child: Center(
              child: Screenshot(
                controller: screenshotController,
                child: Container(
                  // height: 608.h,
                  width: 0.95.sw,
                  // color: const Color(0xfffdfeff),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            "assets/images/hedar-1.png",
                            width: 1.sw,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 7.h,
                            left: 5.w,
                            child: Text(
                              '${data?.islamicDay}-${data?.islamicMonth}-${data?.islamicYear}-${data?.islamicDayName}',
                              style: GoogleFonts.roboto(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w900,
                                color: green,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 7.h,
                            right: 5.w,
                            child: Text(
                              formatEnglishDate(data!.englishDate),
                              style: GoogleFonts.roboto(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.pink,
                              ),
                            ),
                          ),
                        ],
                      ),

                      Padding(
                        padding: EdgeInsets.all(0.w),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                // crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildNamazTable(data),
                                  SizedBox(height: 10.h),
                                  Image.asset(
                                    "assets/images/subfooter.1.png",
                                    height: 80.h,
                                    width: 400.w,
                                  ),
                                ],
                              ),
                            ),

                            Column(
                              children: [
                                SizedBox(
                                  width: 90.w,
                                  child: _buildSehriIftarCard(sehri, iftar),
                                ),
                                SizedBox(height: 4.h),
                                SizedBox(
                                  width: 90.w,
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

                      SizedBox(height: 5.h),
                      SizedBox(
                        width: 450.w,
                        child: Image.asset(
                          "assets/images/footer-1.png",
                          height: 40.h,
                          // width: 700.w,
                        ),
                      ),
                    ],
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset("assets/images/nm.png", width: 80.w),
              Image.asset("assets/images/av1.png", width: 80.w),
              Image.asset("assets/images/ak1.png", width: 80.w),
            ],
          ),
          SizedBox(height: 8.h),

          ...times.map((entry) {
            final name = entry["name"]!;
            final image = entry["image"]!;
            final firstTime = cleanTime(data?.namazTime[name]?["start"]);
            final lastTime = cleanTime(data?.namazTime[name]?["end"]);

            return Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                children: [
                  Expanded(flex: 1, child: Image.asset(image)),
                  SizedBox(width: 3.w),
                  Expanded(
                    flex: 1,
                    child: _buildCustomTimeCell(
                      time: firstTime,
                      bgImage: "assets/images/image16.png",
                      textColor: const Color(0xff3b5c38),
                    ),
                  ),
                  SizedBox(width: 4.w),
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
      ),
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
        Image.asset(bgImage, width: 80.w, fit: BoxFit.contain),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: Text(
            time,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
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
          height: 110.h,
          // width: 130.w,
          fit: BoxFit.contain,
        ),
        Container(
          width: 75.w,
          height: 110.h,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "ખત્મે સેહરી",
                style: TextStyle(
                  fontSize: 11.sp,
                  color: const Color(0xff8f2e43),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                sehri,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: const Color(0xff8f2e43),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Divider(height: 3, color: Colors.grey, indent: 15, endIndent: 25),
              Text(
                "વકતે ઇફતાર",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xff306d71),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                iftar,
                style: TextStyle(
                  fontSize: 15.sp,
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
          height: 270.h,
          // width: 140.w,
          fit: BoxFit.contain,
        ),
        Container(
          height: 270.h,
          width: 75.w,
          // top: 18.h,
          // left: 10.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ishrakText("ઇશરાક", ishrak, const Color(0xff302c8e)),
              Divider(height: 3, color: Colors.grey, indent: 15, endIndent: 25),
              _ishrakText("ચાશ્ત", chast, const Color(0xff377bb8)),
              Divider(height: 3, color: Colors.grey, indent: 15, endIndent: 25),
              _ishrakText("ઝવાલ", zawal, const Color(0xff448532)),
              Divider(height: 3, color: Colors.grey, indent: 15, endIndent: 25),
              _ishrakText("ગુરૂબે\nઆફતાબ", gaftab, const Color(0xff876b61)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _ishrakText(String label, String time, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,

          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.sp,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          time,
          // textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
