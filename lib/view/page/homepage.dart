// import 'package:flutter/material.dart';

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Text("Jamiah_Riyazul_Namaz_TimeTable"),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jamiah_namaz_timetable/controller/homecntrl.dart'; // import controller
import 'package:jamiah_namaz_timetable/model/settingmodel.dart'; // import model

class NamazTimePage extends StatefulWidget {
  const NamazTimePage({super.key});

  @override
  State<NamazTimePage> createState() => _NamazTimePageState();
}

class _NamazTimePageState extends State<NamazTimePage> {
  static const Color paleYellow = Color(0xFFFFF2CD);
  static const Color deepIndigo = Color(0xFF2C326F);
  static const Color pureWhite = Colors.white;

  final TextEditingController islamicDateController = TextEditingController();
  final List<String> namazOrder = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"];
  final List<String> extraOrder = [
    "Sehri",
    "Iftar",
    "Ishrak",
    "Chast",
    "Zawal",
    "Gurebe Aftab",
  ];

  DateTime englishDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // fetch data when page opens
    Future.delayed(Duration.zero, () {
      Get.find<Homecntrl>().fetchData();
    });
  }

  Future<TimeOfDay?> _show12HourTimePicker(TimeOfDay initial) {
    return showTimePicker(
      context: context,
      initialTime: initial,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }

  Future<void> pickTime(Homecntrl controller, String namaz, String type) async {
    final TimeOfDay initial = TimeOfDay.now();
    final TimeOfDay? picked = await _show12HourTimePicker(initial);
    if (picked != null) {
      final formatted = picked.format(context);
      final updated = Map<String, dynamic>.from(
        controller.namazData!.namazTime,
      );
      updated[namaz][type] = formatted;
      controller.namazData = controller.namazData!.copyWith(namazTime: updated);
      controller.update();
    }
  }

  Future<void> pickExtraTime(Homecntrl controller, String key) async {
    final TimeOfDay initial = TimeOfDay.now();
    final TimeOfDay? picked = await _show12HourTimePicker(initial);
    if (picked != null) {
      final formatted = picked.format(context);
      final updated = Map<String, dynamic>.from(
        controller.namazData!.extraTime,
      );
      updated[key] = formatted;
      controller.namazData = controller.namazData!.copyWith(extraTime: updated);
      controller.update();
    }
  }

  Future<void> pickEnglishDate(Homecntrl controller) async {
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: englishDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: deepIndigo)),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (d != null) {
      controller.namazData = controller.namazData!.copyWith(englishDate: d);
      controller.update();
    }
  }

  Widget _tableCell(
    Widget child, {
    EdgeInsets padding = const EdgeInsets.all(8),
  }) {
    return Padding(padding: padding, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Homecntrl>(
      builder: (controller) {
        if (controller.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (controller.namazData == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "Namaz Time Entry",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: deepIndigo,
            ),
            body: const Center(child: Text("No data found")),
          );
        }

        islamicDateController.text = controller.namazData!.islamicDate;
        englishDate = controller.namazData!.englishDate;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Namaz Time Entry",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: deepIndigo,
            actions: [
              IconButton(
                onPressed: () {
                  islamicDateController.clear();
                  final clearedNamaz = Map<String, dynamic>.from(
                    controller.namazData!.namazTime,
                  );
                  clearedNamaz.forEach((k, v) {
                    v['start'] = '';
                    v['end'] = '';
                  });
                  final clearedExtra = Map<String, dynamic>.from(
                    controller.namazData!.extraTime,
                  );
                  clearedExtra.updateAll((key, value) => '');
                  controller.namazData = controller.namazData!.copyWith(
                    islamicDate: '',
                    englishDate: DateTime.now(),
                    namazTime: clearedNamaz,
                    extraTime: clearedExtra,
                  );
                  controller.update();
                },
                icon: const Icon(Icons.refresh),
                tooltip: 'Reset',
              ),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// DATES CARD
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        color: paleYellow.withOpacity(0.2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Dates",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: islamicDateController,
                              decoration: const InputDecoration(
                                labelText: "Islamic Date (string)",
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (val) {
                                controller.namazData = controller.namazData!
                                    .copyWith(islamicDate: val);
                              },
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: pureWhite,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: deepIndigo.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "English Date",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "${controller.namazData!.englishDate.toLocal().toString().split(' ').first}",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  pickEnglishDate(controller),
                                              child: const Text("Change"),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    /// NAMAZ TIMES
                    Text(
                      "Five Times Namaz",
                      style: TextStyle(
                        color: deepIndigo,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: Table(
                        border: TableBorder.all(
                          color: deepIndigo.withOpacity(0.15),
                        ),
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(2),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(color: paleYellow),
                            children: [
                              _tableCell(
                                const Text(
                                  "Namaz",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              _tableCell(
                                const Text(
                                  "Start Time",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              _tableCell(
                                const Text(
                                  "End Time",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          ...namazOrder.map((namaz) {
                            final start =
                                controller
                                    .namazData!
                                    .namazTime[namaz]?['start'] ??
                                '';
                            final end =
                                controller
                                    .namazData!
                                    .namazTime[namaz]?['end'] ??
                                '';
                            return TableRow(
                              children: [
                                _tableCell(
                                  Text(
                                    namaz,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                _tableCell(
                                  TextButton(
                                    onPressed: () =>
                                        pickTime(controller, namaz, "start"),
                                    child: Text(start.isEmpty ? "Pick" : start),
                                  ),
                                ),
                                _tableCell(
                                  TextButton(
                                    onPressed: () =>
                                        pickTime(controller, namaz, "end"),
                                    child: Text(end.isEmpty ? "Pick" : end),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    /// EXTRA TIMES
                    Text(
                      "Extra Times",
                      style: TextStyle(
                        color: deepIndigo,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: Table(
                        border: TableBorder.all(
                          color: deepIndigo.withOpacity(0.15),
                        ),
                        columnWidths: const {
                          0: FlexColumnWidth(3),
                          1: FlexColumnWidth(2),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(color: paleYellow),
                            children: [
                              _tableCell(
                                const Text(
                                  "Name",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              _tableCell(
                                const Text(
                                  "Time",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          ...extraOrder.map((key) {
                            final t =
                                controller.namazData!.extraTime[key] ?? '';
                            return TableRow(
                              children: [
                                _tableCell(
                                  Text(
                                    key,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                _tableCell(
                                  TextButton(
                                    onPressed: () =>
                                        pickExtraTime(controller, key),
                                    child: Text(t.isEmpty ? "Pick" : t),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    /// BUTTONS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: controller.isLoading
                              ? null
                              : () =>
                                    controller.saveData(controller.namazData!),
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text(
                            "Save",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: deepIndigo,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),

              if (controller.isLoading)
                Container(
                  color: Colors.black45,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFFFF2CD),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Saving...",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
