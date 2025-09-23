import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../../controller/homecntrl.dart';
import '../../model/settingmodel.dart';

class Cardpage extends StatefulWidget {
  const Cardpage({super.key});

  @override
  State<Cardpage> createState() => _CardpageState();
}

class _CardpageState extends State<Cardpage> {
  static const Color paleYellow = Color(0xFFFFF2CD);
  static const Color deepIndigo = Color(0xFF2C326F);
  static const Color pureWhite = Colors.white;
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color green = Color(0xFF4CAF50);
  static const Color red = Color(0xFFF44336);
  static const Color gold = Color(0xFFFFD700);

  final Homecntrl controller = Get.find<Homecntrl>();
  final ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    controller.fetchData();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Namaz Timetable",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: deepIndigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareCard,
          ),
        ],
      ),
      body: GetBuilder<Homecntrl>(
        builder: (controller) {
          // if (controller.isLoading) {
          //   return const Center(child: CircularProgressIndicator());
          // }
          final data = controller.namazData;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Screenshot(
                controller: screenshotController,
                child: Container(
                  height: 600,
                  // color: gold,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            '${data?.islamicDay}-${data?.islamicMonth}-${data?.islamicYear}-${data?.islamicDayName}',
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: green,
                            ),
                          ),
                          Spacer(),
                          Text(
                            '${data?.englishDate.day}-${data?.englishDate.month}-${data?.englishDate.year}',
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 560,
                        width: 400,
                        // color: const Color.fromARGB(255, 17, 84, 135),
                        child: true
                            ? Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Positioned(
                                        child: Image.asset(
                                          "assets/images/hedar-1.png",
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    top: 100,
                                    // bottom: 50,
                                    child: Image.asset(
                                      "assets/images/footer-1.png",
                                      height: 30,
                                    ),
                                  ),
                                ],
                              )
                            : Stack(
                                alignment: Alignment.center,
                                children: [
                                  // First image - center

                                  // Second image - top left
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Positioned(
                                        top: 0,
                                        // left: 20,
                                        child: Image.asset(
                                          "assets/images/image1.png",
                                          width: 400,
                                        ),
                                      ),
                                      Positioned(
                                        top: 30,
                                        child: Image.asset(
                                          "assets/images/image3.png",
                                          width: 40,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      Positioned(
                                        top: 100,
                                        // bottom: 50,
                                        // right: 50,
                                        child: Image.asset(
                                          "assets/images/image2.png",
                                          width: 120,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Third image - bottom right
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
                // _buildNamazCard()
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNamazCard() {
    final data = controller.namazData;
    if (data == null) {
      return const Center(child: Text('No data available'));
    }

    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(data),
          _buildPrayerTable(data),
          _buildExtraTimings(data),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader(NamazTimeModel data) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [lightBlue, gold],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Date and Islamic date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${data.islamicDay}-${data.islamicMonth}-${data.islamicYear}',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: deepIndigo,
                  ),
                ),
                Text(
                  '${data.englishDate.day}-${data.englishDate.month}-${data.englishDate.year}-${data.islamicDayName}',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: deepIndigo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Logo and title
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: pureWhite,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mosque, color: green, size: 30),
                      const SizedBox(width: 10),
                      Text(
                        'JAMIAH RIYAZUL ULOOM BARODA',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: deepIndigo,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'جامعة ياض العلوم برودة الجرات الهند',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: deepIndigo,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Managed by: Rahmat - E - Aalam Charitable trust',
                    style: GoogleFonts.roboto(fontSize: 12, color: deepIndigo),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),
            Text(
              'આજ કી તારીખ,ચાંદ,ઔર તકવીમ શહર બરોડા વ અતરાફ કે લીયે',
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: deepIndigo,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTable(NamazTimeModel data) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: deepIndigo,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'નમાઝ',
                    style: GoogleFonts.roboto(
                      color: pureWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: green,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'અવ્વલ વકત',
                      style: GoogleFonts.roboto(
                        color: pureWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'આખીર વકત',
                      style: GoogleFonts.roboto(
                        color: pureWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Prayer rows
          ...data.namazTime.entries.map((entry) {
            final prayerName = entry.key;
            final times = entry.value as Map<String, dynamic>;
            final startTime = times['start'] ?? '';
            final endTime = times['end'] ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: paleYellow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: deepIndigo.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      _getPrayerNameInGujarati(prayerName),
                      style: GoogleFonts.roboto(
                        color: deepIndigo,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        startTime,
                        style: GoogleFonts.roboto(
                          color: pureWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        endTime,
                        style: GoogleFonts.roboto(
                          color: pureWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
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

  Widget _buildExtraTimings(NamazTimeModel data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            'Additional Timings',
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: deepIndigo,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: data.extraTime.entries.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: deepIndigo.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      _getExtraTimeNameInGujarati(entry.key),
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: deepIndigo,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.value ?? '',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: deepIndigo,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            'નમાઝ કાયમ કરો વકત કી પાંબદી કે સાથ',
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: deepIndigo,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'કડુ ની પાગા, જાફર કોમ્પ્લેક્ષ કે પાસ, મચ્છીપીઠ, બરોડા મો.',
            style: GoogleFonts.roboto(fontSize: 12, color: deepIndigo),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            '+91 9898610513 / +91 9104024313',
            style: GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: deepIndigo,
            ),
          ),
        ],
      ),
    );
  }

  String _getPrayerNameInGujarati(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return 'ફજર';
      case 'dhuhr':
        return 'ઝોહર';
      case 'asr':
        return 'અસર';
      case 'maghrib':
        return 'મગરીબ';
      case 'isha':
        return 'ઇશાં';
      default:
        return prayerName;
    }
  }

  String _getExtraTimeNameInGujarati(String timeName) {
    switch (timeName.toLowerCase()) {
      case 'sehri':
        return 'ખત્ને સેહરી';
      case 'iftar':
        return 'વકતે ઇફતાર';
      case 'ishrak':
        return 'ઇશરાક';
      case 'chast':
        return 'ચાશ્ત';
      case 'zawal':
        return 'ઝવાલ';
      case 'gurebe aftab':
        return 'ગુરૂબે આફતાબ';
      default:
        return timeName;
    }
  }
}
