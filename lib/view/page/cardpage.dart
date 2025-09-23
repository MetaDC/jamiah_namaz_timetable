import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jamiah_namaz_timetable/model/settingmodel.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../../controller/homecntrl.dart';

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

  Future<void> _shareCard() async {
    try {
      final image = await screenshotController.capture();
      if (image != null) {
        final tempDir = await getTemporaryDirectory();
        final file = await File(
          '${tempDir.path}/namaz_card_${DateTime.now().millisecondsSinceEpoch}.png',
        ).create();
        await file.writeAsBytes(image);

        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'Namaz Timetable - Jamiah Riyazul Uloom Baroda');
      }
    } catch (e) {
      print('Error sharing: $e');
    }
  }

  String cleanTime(String? raw) {
    if (raw == null) return "--";
    return raw.replaceAll(RegExp(r'(am|pm)', caseSensitive: false), '').trim();
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Screenshot(
                controller: screenshotController,
                child: Container(
                  width: 400,
                  color: Colors.white,
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset("assets/images/hedar-1.png"),
                          Positioned(
                            top: 7,
                            left: 10,
                            child: Text(
                              '${data?.islamicDay}-${data?.islamicMonth}-${data?.islamicYear}',
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: green,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 7,
                            right: 10,
                            child: Text(
                              '${data?.englishDate.day}-${data?.englishDate.month}-${data?.englishDate.year}',
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink,
                              ),
                            ),
                          ),
                        ],
                      ),

                      Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                _buildNamazTable(data),
                                Image.asset(
                                  "assets/images/subfooter.1.png",
                                  height: 72,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              _buildSehriIftarCard(sehri, iftar),
                              _buildIshrakCard(ishrak, chast, zawal, gaftab),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      Image.asset("assets/images/footer-1.png", height: 30),
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
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom header row
          Row(
            children: [
              Image.asset("assets/images/nm.png", height: 27),
              Image.asset("assets/images/av1.png", height: 27),
              Image.asset("assets/images/ak1.png", height: 26),
              // _buildHeaderCell("નમાઝ", Colors.blue),
            ],
          ),
          const SizedBox(height: 8),
          // Rows
          ...times.map((entry) {
            final name = entry["name"]!;
            final image = entry["image"]!;

            final firstTime = cleanTime(data?.namazTime[name]?["start"]);
            final lastTime = cleanTime(data?.namazTime[name]?["end"]);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  // Namaz image
                  Expanded(flex: 3, child: Image.asset(image, height: 30)),
                  // First time
                  Expanded(
                    flex: 3,
                    child: _buildCustomTimeCell(
                      time: firstTime,
                      bgImage: "assets/images/image16.png",
                      textColor: const Color(0xff3b5c38),
                    ),
                  ),
                  // Last time
                  Expanded(
                    flex: 3,
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
        Image.asset(bgImage, height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            time,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  // 🔹 Header Cell
  // Widget _buildHeaderCell(String text, Color bgColor) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(vertical: 8),
  //     color: bgColor,
  //     alignment: Alignment.center,
  //     child: Text(
  //       text,
  //       style: const TextStyle(
  //         color: Colors.white,
  //         fontWeight: FontWeight.bold,
  //         fontSize: 16,
  //       ),
  //     ),
  //   );
  // }

  // 🔹 Row for Namaz times
  // TableRow _buildRow(String namaz, String firstTime, String lastTime) {
  //   return TableRow(
  //     children: [
  //       Image.asset(namaz),
  //       // _buildTextCell(namaz, Colors.white, Colors.black, bold: true),
  //       Stack(
  //         children: [
  //           Image.asset("assets/images/image16.png"),
  //           Align(
  //             child: Text(
  //               firstTime,
  //               style: TextStyle(color: Color(0xff3b5c38)),
  //             ),
  //           ),
  //         ],
  //       ),
  //       // _buildTextCell(firstTime, Colors.green.shade100, Colors.green),
  //       Stack(
  //         children: [
  //           Image.asset("assets/images/image17.png"),
  //           Align(child: Text(lastTime)),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  // 🔹 Generic Cell
  // Widget _buildTextCell(
  //   String text,
  //   Color bgColor,
  //   Color textColor, {
  //   bool bold = false,
  // }) {
  //   return Container(
  //     margin: const EdgeInsets.all(4),
  //     padding: const EdgeInsets.symmetric(vertical: 6),
  //     decoration: BoxDecoration(
  //       color: bgColor,
  //       borderRadius: BorderRadius.circular(6),
  //     ),
  //     alignment: Alignment.center,
  //     child: Text(
  //       text,
  //       style: TextStyle(
  //         color: textColor,
  //         fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
  //         fontSize: 16,
  //       ),
  //     ),
  //   );
  // }

  // 🔹 Sehri/Iftar card (right side)
  Widget _buildSehriIftarCard(String sehri, String iftar) {
    return Stack(
      children: [
        Image.asset("assets/images/image19.png", height: 120),
        Positioned(
          top: 10,
          left: 6,
          child: Column(
            children: [
              Text(
                "ખત્ને સેહરી",
                style: TextStyle(
                  color: Color(0xff8f2e43),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                sehri,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xff8f2e43),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "વકતે ઇફતાર",
                style: TextStyle(
                  color: Color(0xff306d71),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                iftar,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xff306d71),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 🔹 Ishrak/Chast/Zawal/Gaftab card
  Widget _buildIshrakCard(
    String ishrak,
    String chast,
    String zawal,
    String gaftab,
  ) {
    return Stack(
      children: [
        Image.asset("assets/images/image7.png", height: 280),
        Positioned(
          top: 18,
          left: 15,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ઇશરાક",
                style: TextStyle(
                  color: Color(0xff302c8e),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                ishrak,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xff302c8e),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                "ચાશ્ત",
                style: TextStyle(
                  color: Color(0xff377bb8),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                chast,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xff377bb8),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                "ઝવાલ",
                style: TextStyle(
                  color: Color(0xff448532),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                zawal,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xff448532),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                "ગુરૂબે \nઆફતાબ",
                style: TextStyle(
                  color: Color(0xff876b61),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                gaftab,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xff876b61),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomHeader(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        color: Colors.indigo.shade100,
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.indigo,
          ),
        ),
      ),
    );
  }
}

 // Widget _buildNamazCard() {
  //   final data = controller.namazData;
  //   if (data == null) {
  //     return const Center(child: Text('No data available'));
  //   }

  //   return Container(
  //     width: 400,
  //     decoration: BoxDecoration(
  //       color: pureWhite,
  //       borderRadius: BorderRadius.circular(20),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.1),
  //           blurRadius: 10,
  //           offset: const Offset(0, 5),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       children: [
  //         _buildHeader(data),
  //         _buildPrayerTable(data),
  //         _buildExtraTimings(data),
  //         _buildFooter(),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildHeader(NamazTimeModel data) {
  //   return Container(
  //     decoration: const BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [lightBlue, gold],
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       ),
  //       borderRadius: BorderRadius.only(
  //         topLeft: Radius.circular(20),
  //         topRight: Radius.circular(20),
  //       ),
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.all(20),
  //       child: Column(
  //         children: [
  //           // Date and Islamic date
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text(
  //                 '${data.islamicDay}-${data.islamicMonth}-${data.islamicYear}',
  //                 style: GoogleFonts.roboto(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.bold,
  //                   color: deepIndigo,
  //                 ),
  //               ),
  //               Text(
  //                 '${data.englishDate.day}-${data.englishDate.month}-${data.englishDate.year}-${data.islamicDayName}',
  //                 style: GoogleFonts.roboto(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.bold,
  //                   color: deepIndigo,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 20),

  //           // Logo and title
  //           Container(
  //             padding: const EdgeInsets.all(15),
  //             decoration: BoxDecoration(
  //               color: Color(0xffcccccc),
  //               borderRadius: BorderRadius.circular(15),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.black.withOpacity(0.1),
  //                   blurRadius: 5,
  //                   offset: const Offset(0, 2),
  //                 ),
  //               ],
  //             ),
  //             child: Column(
  //               children: [
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Icon(Icons.mosque, color: green, size: 30),
  //                     const SizedBox(width: 10),
  //                     Text(
  //                       'JAMIAH RIYAZUL ULOOM BARODA',
  //                       style: GoogleFonts.roboto(
  //                         fontSize: 18,
  //                         fontWeight: FontWeight.bold,
  //                         color: deepIndigo,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 8),
  //                 Text(
  //                   'جامعة ياض العلوم برودة الجرات الهند',
  //                   style: GoogleFonts.roboto(
  //                     fontSize: 16,
  //                     fontWeight: FontWeight.bold,
  //                     color: deepIndigo,
  //                   ),
  //                   textAlign: TextAlign.center,
  //                 ),
  //                 const SizedBox(height: 5),
  //                 Text(
  //                   'Managed by: Rahmat - E - Aalam Charitable trust',
  //                   style: GoogleFonts.roboto(fontSize: 12, color: deepIndigo),
  //                 ),
  //               ],
  //             ),
  //           ),

  //           const SizedBox(height: 15),
  //           Text(
  //             'આજ કી તારીખ,ચાંદ,ઔર તકવીમ શહર બરોડા વ અતરાફ કે લીયે',
  //             style: GoogleFonts.roboto(
  //               fontSize: 14,
  //               color: deepIndigo,
  //               fontWeight: FontWeight.w500,
  //             ),
  //             textAlign: TextAlign.center,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildPrayerTable(NamazTimeModel data) {
  //   return Padding(
  //     padding: const EdgeInsets.all(20),
  //     child: Column(
  //       children: [
  //         // Table header
  //         Container(
  //           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
  //           decoration: BoxDecoration(
  //             color: deepIndigo,
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           child: Row(
  //             children: [
  //               Expanded(
  //                 flex: 2,
  //                 child: Text(
  //                   'નમાઝ',
  //                   style: GoogleFonts.roboto(
  //                     color: pureWhite,
  //                     fontWeight: FontWeight.bold,
  //                     fontSize: 16,
  //                   ),
  //                 ),
  //               ),
  //               Expanded(
  //                 child: Container(
  //                   padding: const EdgeInsets.symmetric(
  //                     vertical: 8,
  //                     horizontal: 12,
  //                   ),
  //                   decoration: BoxDecoration(
  //                     color: green,
  //                     borderRadius: BorderRadius.circular(6),
  //                   ),
  //                   child: Text(
  //                     'અવ્વલ વકત',
  //                     style: GoogleFonts.roboto(
  //                       color: pureWhite,
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: 12,
  //                     ),
  //                     textAlign: TextAlign.center,
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(width: 8),
  //               Expanded(
  //                 child: Container(
  //                   padding: const EdgeInsets.symmetric(
  //                     vertical: 8,
  //                     horizontal: 12,
  //                   ),
  //                   decoration: BoxDecoration(
  //                     color: red,
  //                     borderRadius: BorderRadius.circular(6),
  //                   ),
  //                   child: Text(
  //                     'આખીર વકત',
  //                     style: GoogleFonts.roboto(
  //                       color: pureWhite,
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: 12,
  //                     ),
  //                     textAlign: TextAlign.center,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         const SizedBox(height: 8),

  //         // Prayer rows
  //         ...data.namazTime.entries.map((entry) {
  //           final prayerName = entry.key;
  //           final times = entry.value as Map<String, dynamic>;
  //           final startTime = times['start'] ?? '';
  //           final endTime = times['end'] ?? '';

  //           return Container(
  //             margin: const EdgeInsets.only(bottom: 8),
  //             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
  //             decoration: BoxDecoration(
  //               color: paleYellow,
  //               borderRadius: BorderRadius.circular(8),
  //               border: Border.all(color: deepIndigo.withOpacity(0.2)),
  //             ),
  //             child: Row(
  //               children: [
  //                 Expanded(
  //                   flex: 2,
  //                   child: Text(
  //                     _getPrayerNameInGujarati(prayerName),
  //                     style: GoogleFonts.roboto(
  //                       color: deepIndigo,
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: 16,
  //                     ),
  //                   ),
  //                 ),
  //                 Expanded(
  //                   child: Container(
  //                     padding: const EdgeInsets.symmetric(
  //                       vertical: 6,
  //                       horizontal: 8,
  //                     ),
  //                     decoration: BoxDecoration(
  //                       color: green,
  //                       borderRadius: BorderRadius.circular(4),
  //                     ),
  //                     child: Text(
  //                       startTime,
  //                       style: GoogleFonts.roboto(
  //                         color: pureWhite,
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 14,
  //                       ),
  //                       textAlign: TextAlign.center,
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(width: 8),
  //                 Expanded(
  //                   child: Container(
  //                     padding: const EdgeInsets.symmetric(
  //                       vertical: 6,
  //                       horizontal: 8,
  //                     ),
  //                     decoration: BoxDecoration(
  //                       color: red,
  //                       borderRadius: BorderRadius.circular(4),
  //                     ),
  //                     child: Text(
  //                       endTime,
  //                       style: GoogleFonts.roboto(
  //                         color: pureWhite,
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 14,
  //                       ),
  //                       textAlign: TextAlign.center,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           );
  //         }).toList(),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildExtraTimings(NamazTimeModel data) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 20),
  //     child: Column(
  //       children: [
  //         Text(
  //           'Additional Timings',
  //           style: GoogleFonts.roboto(
  //             fontSize: 16,
  //             fontWeight: FontWeight.bold,
  //             color: deepIndigo,
  //           ),
  //         ),
  //         const SizedBox(height: 10),
  //         Wrap(
  //           spacing: 10,
  //           runSpacing: 10,
  //           children: data.extraTime.entries.map((entry) {
  //             return Container(
  //               padding: const EdgeInsets.symmetric(
  //                 vertical: 8,
  //                 horizontal: 12,
  //               ),
  //               decoration: BoxDecoration(
  //                 color: lightBlue,
  //                 borderRadius: BorderRadius.circular(8),
  //                 border: Border.all(color: deepIndigo.withOpacity(0.3)),
  //               ),
  //               child: Column(
  //                 children: [
  //                   Text(
  //                     _getExtraTimeNameInGujarati(entry.key),
  //                     style: GoogleFonts.roboto(
  //                       fontSize: 12,
  //                       fontWeight: FontWeight.bold,
  //                       color: deepIndigo,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 2),
  //                   Text(
  //                     entry.value ?? '',
  //                     style: GoogleFonts.roboto(
  //                       fontSize: 14,
  //                       fontWeight: FontWeight.bold,
  //                       color: deepIndigo,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             );
  //           }).toList(),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildFooter() {
  //   return Container(
  //     margin: const EdgeInsets.all(20),
  //     padding: const EdgeInsets.all(15),
  //     decoration: BoxDecoration(
  //       color: lightBlue,
  //       borderRadius: BorderRadius.circular(10),
  //     ),
  //     child: Column(
  //       children: [
  //         Text(
  //           'નમાઝ કાયમ કરો વકત કી પાંબદી કે સાથ',
  //           style: GoogleFonts.roboto(
  //             fontSize: 14,
  //             fontWeight: FontWeight.bold,
  //             color: deepIndigo,
  //           ),
  //           textAlign: TextAlign.center,
  //         ),
  //         const SizedBox(height: 10),
  //         Text(
  //           'કડુ ની પાગા, જાફર કોમ્પ્લેક્ષ કે પાસ, મચ્છીપીઠ, બરોડા મો.',
  //           style: GoogleFonts.roboto(fontSize: 12, color: deepIndigo),
  //           textAlign: TextAlign.center,
  //         ),
  //         const SizedBox(height: 5),
  //         Text(
  //           '+91 9898610513 / +91 9104024313',
  //           style: GoogleFonts.roboto(
  //             fontSize: 12,
  //             fontWeight: FontWeight.bold,
  //             color: deepIndigo,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // String _getPrayerNameInGujarati(String prayerName) {
  //   switch (prayerName.toLowerCase()) {
  //     case 'fajr':
  //       return 'ફજર';
  //     case 'dhuhr':
  //       return 'ઝોહર';
  //     case 'asr':
  //       return 'અસર';
  //     case 'maghrib':
  //       return 'મગરીબ';
  //     case 'isha':
  //       return 'ઇશાં';
  //     default:
  //       return prayerName;
  //   }
  // }

  // String _getExtraTimeNameInGujarati(String timeName) {
  //   switch (timeName.toLowerCase()) {
  //     case 'sehri':
  //       return 'ખત્ને સેહરી';
  //     case 'iftar':
  //       return 'વકતે ઇફતાર';
  //     case 'ishrak':
  //       return 'ઇશરાક';
  //     case 'chast':
  //       return 'ચાશ્ત';
  //     case 'zawal':
  //       return 'ઝવાલ';
  //     case 'gurebe aftab':
  //       return 'ગુરૂબે આફતાબ';
  //     default:
  //       return timeName;
  //   }
  // }
