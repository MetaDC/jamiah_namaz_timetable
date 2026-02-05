import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
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
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchData();
    });
  }

  String convertToGujaratiNumber(String number) {
    const englishToGujarati = {
      '0': '૦',
      '1': '૧',
      '2': '૨',
      '3': '૩',
      '4': '૪',
      '5': '૫',
      '6': '૬',
      '7': '૭',
      '8': '૮',
      '9': '૯',
    };

    return number.split('').map((e) => englishToGujarati[e] ?? e).join('');
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
    if (_isSharing) return; // prevent multiple taps

    setState(() {
      _isSharing = true;
    });

    try {
      final image = await screenshotController.capture(pixelRatio: 10);
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
    } finally {
      setState(() {
        _isSharing = false;
      });
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
    return IgnorePointer(
      ignoring: _isSharing,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Namaz Timetable",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.indigo,
          actions: [
            IconButton(
              icon: _isSharing
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.share, color: Colors.white),
              onPressed: _isSharing ? null : _shareCard,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              GetBuilder<Homecntrl>(
                builder: (controller) {
                  final data = controller.namazData;

                  final sehri = cleanTime(data?.extraTime["Sehri"]);
                  final iftar = cleanTime(data?.extraTime["Iftar"]);
                  final ishrak = cleanTime(data?.extraTime["Ishrak"]);
                  final chast = cleanTime(data?.extraTime["Chast"]);
                  final zawal = cleanTime(data?.extraTime["Zawal"]);
                  final gaftab = cleanTime(data?.extraTime["Gurebe Aftab"]);

                  return Screenshot(
                    controller: screenshotController,
                    child: Center(
                      child: SizedBox(
                        width: 400,
                        height: 564.3,
                        child: Stack(
                          fit: StackFit.expand,
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              "assets/images/taqwim.png",
                              // width: 360,
                              // height: 700,
                              width: 400,
                              height: 564.3,
                              fit: BoxFit.fill,
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  height: 45,
                                  // color: Colors.amber.withOpacity(.5),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        AutoSizeText(
                                          '${convertToGujaratiNumber("${data?.islamicDay}")}-${data?.islamicMonth}-${data?.islamicYear}-${data?.islamicDayName}',
                                          style: GoogleFonts.roboto(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            color: green,
                                          ),
                                          maxLines: 1,
                                          minFontSize: 10,
                                        ),
                                        AutoSizeText(
                                          formatEnglishDate(data!.englishDate),
                                          style: GoogleFonts.roboto(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.pink,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Stack(
                                    children: [
                                      Column(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    // color: Colors.green.withOpacity(.5),
                                                    child: Column(),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    // color: Colors.blue.withOpacity(.5),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      spacing: 10,
                                                      children: [
                                                        SizedBox(height: 30),
                                                        buildNamazText(
                                                          text: cleanTime(
                                                            data.namazTime["Fajr"]?["start"] ??
                                                                "",
                                                          ),
                                                        ),
                                                        buildNamazText(
                                                          text: cleanTime(
                                                            data.namazTime["Dhuhr"]?["start"] ??
                                                                "",
                                                          ),
                                                        ),
                                                        buildNamazText(
                                                          text: cleanTime(
                                                            data.namazTime["Asr"]?["start"] ??
                                                                "",
                                                          ),
                                                        ),
                                                        buildNamazText(
                                                          text: cleanTime(
                                                            data.namazTime["Maghrib"]?["start"] ??
                                                                "",
                                                          ),
                                                        ),
                                                        buildNamazText(
                                                          text: cleanTime(
                                                            data.namazTime["Isha"]?["start"] ??
                                                                "",
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    // color: Colors.red.withOpacity(.5),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      spacing: 10,
                                                      children: [
                                                        SizedBox(height: 30),
                                                        // End Namaz times
                                                        buildNamazEndText(
                                                          text: cleanTime(
                                                            data.namazTime["Fajr"]?["end"] ??
                                                                "",
                                                          ),
                                                        ),
                                                        buildNamazEndText(
                                                          text: cleanTime(
                                                            data.namazTime["Dhuhr"]?["end"] ??
                                                                "",
                                                          ),
                                                        ),
                                                        buildNamazEndText(
                                                          text: cleanTime(
                                                            data.namazTime["Asr"]?["end"] ??
                                                                "",
                                                          ),
                                                        ),
                                                        buildNamazEndText(
                                                          text: cleanTime(
                                                            data.namazTime["Maghrib"]?["end"] ??
                                                                "",
                                                          ),
                                                        ),
                                                        buildNamazEndText(
                                                          text: cleanTime(
                                                            data.namazTime["Isha"]?["end"] ??
                                                                "",
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    // color: Colors.orange.withOpacity(.5),
                                                    child: Column(
                                                      children: [
                                                        SizedBox(height: 165),
                                                        buildNamazExtraTime(
                                                          text: sehri,
                                                          color: Color(
                                                            0xff8f2e43,
                                                          ),
                                                        ),
                                                        SizedBox(height: 18),
                                                        buildNamazExtraTime(
                                                          text: iftar,
                                                          color: Color(
                                                            0xff306d71,
                                                          ),
                                                        ),
                                                        SizedBox(height: 43),
                                                        buildNamazExtraTime(
                                                          text: ishrak,
                                                          color: Color(
                                                            0xff302c8e,
                                                          ),
                                                        ),
                                                        SizedBox(height: 22),
                                                        buildNamazExtraTime(
                                                          text: chast,
                                                          color: Color(
                                                            0xff377bb8,
                                                          ),
                                                        ),
                                                        SizedBox(height: 21),
                                                        buildNamazExtraTime(
                                                          text: zawal,
                                                          color: Color(
                                                            0xff448532,
                                                          ),
                                                        ),
                                                        SizedBox(height: 37),
                                                        buildNamazExtraTime(
                                                          text: gaftab,
                                                          color: Color(
                                                            0xff876b61,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      true
                                          ? Column(
                                              children: [
                                                SizedBox(height: 415),
                                                Row(
                                                  children: [
                                                    SizedBox(width: 10),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Container(
                                                        height:
                                                            58 /
                                                            564.3 *
                                                            564.3, // Proportional height
                                                        width: 210,
                                                        color: Colors.white,
                                                        child: Center(
                                                          child: AutoSizeText(
                                                            textAlign: TextAlign
                                                                .center,
                                                            data?.duaText ?? "",
                                                            style: TextStyle(
                                                              // fontSize: 24,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: SizedBox(
                                                        width: 10,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          : Positioned(
                                              top:
                                                  413 /
                                                  564.3 *
                                                  564.3, // Or simply keep as 413 if image size is fixed
                                              left:
                                                  10 /
                                                  400 *
                                                  400, // Or simply keep as 10 if image size is fixed
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        height:
                                                            58 /
                                                            564.3 *
                                                            564.3, // Proportional height
                                                        width:
                                                            (270 / 400) *
                                                            400, // Proportional width
                                                        color: Colors.white,
                                                        child: Center(
                                                          child: AutoSizeText(
                                                            textAlign: TextAlign
                                                                .center,
                                                            data?.duaText ?? "",
                                                            style: TextStyle(
                                                              // fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                      // Positioned(
                                      //   top: 413,
                                      //   left: 10,
                                      //   child: Column(
                                      //     // crossAxisAlignment: ,
                                      //     children: [
                                      //       Container(
                                      //         height: 58,
                                      //         width: 270,
                                      //         color: Colors.white,
                                      //         child: Center(
                                      //           child: AutoSizeText(
                                      //             textAlign: TextAlign.center,
                                      //             data?.duaText ?? "",
                                      //             style: TextStyle(
                                      //               fontSize: 14,
                                      //               fontWeight: FontWeight.bold,
                                      //             ),
                                      //           ),
                                      //         ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNamazText({required String text}) {
    return AutoSizeText(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 22,
        color: Color(0xff3b5c38),
        fontWeight: FontWeight.w600,
      ),
      maxLines: 1,
      minFontSize: 10,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget buildNamazEndText({required String text}) {
    return AutoSizeText(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 22,
        color: Color(0xff9d2a2a),
        fontWeight: FontWeight.w600,
      ),
      maxLines: 1,
      minFontSize: 10,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget buildNamazExtraTime({required String text, required Color color}) {
    return AutoSizeText(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.w600),
      maxLines: 1,
      minFontSize: 10,
      overflow: TextOverflow.ellipsis,
    );
  }
}





  // Positioned(
                  //   top: 18,
                  //   left: 10,
                  //   child: AutoSizeText(
                  //     '${data?.islamicDay}-${data?.islamicMonth}-${data?.islamicYear}-${data?.islamicDayName}',
                  //     style: GoogleFonts.roboto(
                  //       fontSize: 30,
                  //       fontWeight: FontWeight.w900,
                  //       color: green,
                  //     ),
                  //     maxLines: 1,
                  //     minFontSize: 10,
                  //   ),
                  // ),
                  // Positioned(
                  //   top: 18,
                  //   right: 10,
                  //   child: AutoSizeText(
                  //     formatEnglishDate(data!.englishDate),
                  //     style: GoogleFonts.roboto(
                  //       fontSize: 28,
                  //       fontWeight: FontWeight.w900,
                  //       color: Colors.pink,
                  //     ),
                  //   ),
                  // ),
                  // // Start Namaz times
                  // buildNamazText(
                  //   top: 485,
                  //   left: 245,
                  //   text: cleanTime(data.namazTime["Fajr"]?["start"] ?? ""),
                  // ),
                  // buildNamazText(
                  //   top: 570,
                  //   left: 245,
                  //   text: cleanTime(data.namazTime["Dhuhr"]?["start"] ?? ""),
                  // ),
                  // buildNamazText(
                  //   top: 655,
                  //   left: 245,
                  //   text: cleanTime(data.namazTime["Asr"]?["start"] ?? ""),
                  // ),
                  // buildNamazText(
                  //   top: 740,
                  //   left: 245,
                  //   text: cleanTime(
                  //     data.namazTime["Maghrib"]?["start"] ?? "",
                  //   ),
                  // ),
                  // buildNamazText(
                  //   top: 830,
                  //   left: 245,
                  //   text: cleanTime(data.namazTime["Isha"]?["start"] ?? ""),
                  // ),
                  // // End Namaz times
                  // buildNamazEndText(
                  //   top: 485,
                  //   left: 430,
                  //   text: cleanTime(data.namazTime["Fajr"]?["end"] ?? ""),
                  // ),
                  // buildNamazEndText(
                  //   top: 570,
                  //   left: 430,
                  //   text: cleanTime(data.namazTime["Dhuhr"]?["end"] ?? ""),
                  // ),
                  // buildNamazEndText(
                  //   top: 655,
                  //   left: 430,
                  //   text: cleanTime(data.namazTime["Asr"]?["end"] ?? ""),
                  // ),
                  // buildNamazEndText(
                  //   top: 740,
                  //   left: 430,
                  //   text: cleanTime(data.namazTime["Maghrib"]?["end"] ?? ""),
                  // ),
                  // buildNamazEndText(
                  //   top: 830,
                  //   left: 430,
                  //   text: cleanTime(data.namazTime["Isha"]?["end"] ?? ""),
                  // ),
                  // // Extra times
                  // buildNamazExtraTime(
                  //   top: 440,
                  //   right: 40,
                  //   text: sehri,
                  //   color: Color(0xff8f2e43),
                  // ),
                  // buildNamazExtraTime(
                  //   top: 530,
                  //   right: 40,
                  //   text: iftar,
                  //   color: Color(0xff306d71),
                  // ),
                  // buildNamazExtraTime(
                  //   top: 680,
                  //   right: 40,
                  //   text: ishrak,
                  //   color: Color(0xff302c8e),
                  // ),
                  // buildNamazExtraTime(
                  //   top: 780,
                  //   right: 40,
                  //   text: chast,
                  //   color: Color(0xff377bb8),
                  // ),
                  // buildNamazExtraTime(
                  //   top: 875,
                  //   right: 40,
                  //   text: zawal,
                  //   color: Color(0xff448532),
                  // ),
                  // buildNamazExtraTime(
                  //   top: 1008,
                  //   right: 40,
                  //   text: gaftab,
                  //   color: Color(0xff876b61),
                  // ),
// Widget _buildNamazTable(NamazTimeModel? data) {
  //   final times = [
  //     {"image": "assets/images/fzr.png", "name": "Fajr"},
  //     {"image": "assets/images/zhr.png", "name": "Dhuhr"},
  //     {"image": "assets/images/asr.png", "name": "Asr"},
  //     {"image": "assets/images/magrb.png", "name": "Maghrib"},
  //     {"image": "assets/images/isha.png", "name": "Isha"},
  //   ];

  //   return Column(
  //     children: [
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Image.asset("assets/images/nm.png", height: 33),
  //           Image.asset("assets/images/av1.png", height: 33),
  //           Image.asset("assets/images/ak1.png", height: 33),
  //         ],
  //       ),
  //       const SizedBox(height: 8),
  //       ...times.map((entry) {
  //         final name = entry["name"]!;
  //         final image = entry["image"]!;
  //         final firstTime = cleanTime(data?.namazTime[name]?["start"]);
  //         final lastTime = cleanTime(data?.namazTime[name]?["end"]);
  //         return Padding(
  //           padding: const EdgeInsets.symmetric(vertical: 4),
  //           child: Row(
  //             children: [
  //               Expanded(flex: 1, child: Image.asset(image, height: 35)),
  //               const SizedBox(width: 3),
  //               Expanded(
  //                 flex: 1,
  //                 child: _buildCustomTimeCell(
  //                   time: firstTime,
  //                   bgImage: "assets/images/image16.png",
  //                   textColor: const Color(0xff3b5c38),
  //                 ),
  //               ),
  //               const SizedBox(width: 4),
  //               Expanded(
  //                 flex: 1,
  //                 child: _buildCustomTimeCell(
  //                   time: lastTime,
  //                   bgImage: "assets/images/image17.png",
  //                   textColor: const Color(0xff9d2a2a),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         );
  //       }).toList(),
  //     ],
  //   );
  // }

 

  // Widget _buildCustomTimeCell({
  //   required String time,
  //   required String bgImage,
  //   required Color textColor,
  // }) {
  //   return Stack(
  //     alignment: Alignment.center,
  //     children: [
  //       Image.asset(bgImage, width: 80, fit: BoxFit.contain),
  //       Text(
  //         time,
  //         style: TextStyle(
  //           fontSize: 19,
  //           fontWeight: FontWeight.w700,
  //           color: textColor,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildSehriIftarCard(String sehri, String iftar) {
  //   return Stack(
  //     alignment: Alignment.center,
  //     children: [
  //       Image.asset(
  //         "assets/images/image19.png",
  //         height: 120,
  //         fit: BoxFit.contain,
  //       ),
  //       SizedBox(
  //         height: 120,
  //         width: 90,
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             AutoSizeText(
  //               "ખત્મે સેહરી",
  //               maxLines: 1,
  //               minFontSize: 8,
  //               textAlign: TextAlign.center,
  //               style: const TextStyle(
  //                 fontSize: 13,
  //                 color: Color(0xff8f2e43),
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //             AutoSizeText(
  //               sehri,
  //               maxLines: 1,
  //               minFontSize: 10,
  //               textAlign: TextAlign.center,
  //               style: const TextStyle(
  //                 fontSize: 16,
  //                 color: Color(0xff8f2e43),
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //             const Divider(indent: 10, endIndent: 10),
  //             AutoSizeText(
  //               "વકતે ઇફતાર",
  //               maxLines: 1,
  //               minFontSize: 8,
  //               textAlign: TextAlign.center,
  //               style: const TextStyle(
  //                 fontSize: 13,
  //                 color: Color(0xff306d71),
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //             AutoSizeText(
  //               iftar,
  //               maxLines: 1,
  //               minFontSize: 10,
  //               textAlign: TextAlign.center,
  //               style: const TextStyle(
  //                 fontSize: 16,
  //                 color: Color(0xff306d71),
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildIshrakCard(
  //   String ishrak,
  //   String chast,
  //   String zawal,
  //   String gaftab,
  // ) {
  //   return Stack(
  //     alignment: Alignment.center,
  //     children: [
  //       Image.asset(
  //         "assets/images/image7.png",
  //         height: 250,
  //         fit: BoxFit.contain,
  //       ),
  //       SizedBox(
  //         width: 40,
  //         height: 250,
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           // crossAxisAlignment: CrossAxisAlignment.center,
  //           // mainAxisSize: MainAxisSize.min,
  //           children: [
  //             _ishrakText("ઇશરાક", ishrak, const Color(0xff302c8e)),
  //             const Divider(),
  //             _ishrakText("ચાશ્ત", chast, const Color(0xff377bb8)),
  //             const Divider(),
  //             _ishrakText("ઝવાલ", zawal, const Color(0xff448532)),
  //             const Divider(),
  //             _ishrakText("ગુરૂબે\nઆફતાબ", gaftab, const Color(0xff876b61)),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _ishrakText(String label, String time, Color color) {
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       AutoSizeText(
  //         label,
  //         maxLines: 2,
  //         minFontSize: 8,
  //         maxFontSize: 14,
  //         textAlign: TextAlign.center,
  //         style: TextStyle(
  //           fontSize: 12,
  //           color: color,
  //           fontWeight: FontWeight.w700,
  //         ),
  //       ),
  //       AutoSizeText(
  //         time,
  //         maxLines: 1,
  //         minFontSize: 10,
  //         maxFontSize: 19,
  //         textAlign: TextAlign.center,
  //         style: TextStyle(
  //           fontSize: 19,
  //           color: color,
  //           fontWeight: FontWeight.w700,
  //         ),
  //       ),
  //     ],
  //   );
  // }
