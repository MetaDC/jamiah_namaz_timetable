import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jamiah_namaz_timetable/controller/homecntrl.dart';
import 'package:jamiah_namaz_timetable/view/page/cardpage.dart';

class NamazTimePage extends StatefulWidget {
  const NamazTimePage({super.key});

  @override
  State<NamazTimePage> createState() => _NamazTimePageState();
}

class _NamazTimePageState extends State<NamazTimePage> {
  static const Color paleYellow = Color(0xFFFFF2CD);
  static const Color deepIndigo = Color(0xFF2C326F);
  static const Color pureWhite = Colors.white;

  final List<String> namazOrder = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"];
  final List<String> extraOrder = [
    "Sehri",
    "Iftar",
    "Ishrak",
    "Chast",
    "Zawal",
    "Gurebe Aftab",
  ];

  final islamicMonths = [
    "મોહર્રમ",
    "સફર",
    "ર.અવ્વલ",
    "ર.સાની",
    "જ.અવ્વલ",
    "જ.સાની",
    "રજબ",
    "શાબાન",
    "રમઝાન",
    "શવ્વાલ",
    "ઝીલ્કદ",
    "ઝીલ્હજ્જ",
  ];

  final islamicDayNames = [
    "સનીચર",
    "ઇતવાર",
    "પીર",
    "મંગલ",
    "બુધ",
    "જુમેરાત",
    "જુમ્મા",
  ];

  late List<int> islamicYears;
  late List<String> islamicYearsGujarati;
  final List<String> islamicDaysGujarati = List.generate(30, (i) {
    final number = i + 1;

    final gujaratiNumber = number
        .toString()
        .split('')
        .map((d) => String.fromCharCode(0x0AE6 + int.parse(d)))
        .join();
    return gujaratiNumber;
  });
  DateTime englishDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    final currentYear = DateTime.now().year - 578;
    islamicYears = [currentYear - 1, currentYear, currentYear + 1];

    Future.delayed(Duration.zero, () async {
      final ctrl = Get.find<Homecntrl>();
      await ctrl.fetchData();

      if (ctrl.namazData != null) {
        final savedYear = ctrl.namazData!.islamicYear;
        if (savedYear != null && !islamicYears.contains(savedYear)) {
          islamicYears.add(savedYear);
          islamicYears.sort();
        }
      }

      islamicYearsGujarati = islamicYears
          .map(
            (y) => y
                .toString()
                .split('')
                .map((d) => String.fromCharCode(0x0AE6 + int.parse(d)))
                .join(),
          )
          .toList();

      setState(() {});
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

        englishDate = controller.namazData!.englishDate;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Namaz Time Entry",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: deepIndigo,
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                              "Islamic Date",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),

                            DropdownButtonFormField<String>(
                              value: controller.namazData!.islamicDay != null
                                  ? islamicDaysGujarati[controller
                                            .namazData!
                                            .islamicDay! -
                                        1]
                                  : null,
                              items: islamicDaysGujarati
                                  .map(
                                    (d) => DropdownMenuItem(
                                      value: d,
                                      child: Text(d),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                final index =
                                    islamicDaysGujarati.indexOf(val!) + 1;
                                controller.namazData = controller.namazData!
                                    .copyWith(islamicDay: index);
                                controller.update();
                              },
                              decoration: const InputDecoration(
                                labelText: "Day",
                                border: OutlineInputBorder(),
                              ),
                            ),

                            SizedBox(height: 10),

                            DropdownButtonFormField<String>(
                              value:
                                  islamicMonths.contains(
                                    controller.namazData!.islamicMonth,
                                  )
                                  ? controller.namazData!.islamicMonth
                                  : null,
                              items: islamicMonths
                                  .map(
                                    (m) => DropdownMenuItem(
                                      value: m,
                                      child: Text(m),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  controller.namazData = controller.namazData!
                                      .copyWith(islamicMonth: val);
                                  controller.update();
                                }
                              },
                              decoration: const InputDecoration(
                                labelText: "Month",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 10),

                            DropdownButtonFormField<int>(
                              value: controller.namazData!.islamicYear,
                              items: List.generate(islamicYears.length, (
                                index,
                              ) {
                                return DropdownMenuItem(
                                  value: islamicYears[index],
                                  child: Text(islamicYearsGujarati[index]),
                                );
                              }),
                              onChanged: (val) {
                                if (val != null) {
                                  controller.namazData = controller.namazData!
                                      .copyWith(islamicYear: val);
                                  controller.update();
                                }
                              },
                              decoration: const InputDecoration(
                                labelText: "Year",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 10),

                            DropdownButtonFormField<String>(
                              value:
                                  islamicDayNames.contains(
                                    controller.namazData!.islamicDayName,
                                  )
                                  ? controller.namazData!.islamicDayName
                                  : null,
                              items: islamicDayNames
                                  .map(
                                    (dn) => DropdownMenuItem(
                                      value: dn,
                                      child: Text(dn),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  controller.namazData = controller.namazData!
                                      .copyWith(islamicDayName: val);
                                  controller.update();
                                }
                              },
                              decoration: const InputDecoration(
                                labelText: "Day Name",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),
                    SizedBox(height: 10),

                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        color: paleYellow.withOpacity(0.2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${controller.namazData!.englishDate.toLocal().toString().split(' ').first}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextButton(
                              onPressed: () => pickEnglishDate(controller),
                              child: const Text("Change"),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                        SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Cardpage(),
                              ),
                            );
                          },
                          // icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text(
                            "Show",
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
