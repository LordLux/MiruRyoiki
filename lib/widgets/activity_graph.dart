import 'package:flutter/material.dart';
import 'package:miruryoiki/enums.dart';
import 'package:miruryoiki/manager.dart';
import 'package:miruryoiki/utils/screen_utils.dart';
import '../models/anilist/user_data.dart';
import 'package:intl/intl.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

import '../utils/logging.dart';
import '../utils/time_utils.dart';

class ActivityGraph extends StatelessWidget {
  final List<AnilistActivityHistory> activityHistory;
  final List<Color> colorScale;

  const ActivityGraph({
    super.key,
    required this.activityHistory,
    this.colorScale = const [
      Color.fromARGB(255, 42, 43, 44), // Level 0 (empty)
      Color.fromARGB(255, 44, 67, 48), // Level 1 (light)
      Color.fromARGB(255, 36, 111, 56), // Level 2 (medium)
      Color.fromARGB(255, 48, 162, 79), // Level 3 (dark)
      Color.fromARGB(255, 60, 197, 104), // Level 4 (darkest)
    ],
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // Placeholder for now, as this widget is not used in the current context
    
    // log('Building ActivityGraph with ${activityHistory.length} activities');
    // Create a map of date to activity
    final Map<DateTime, AnilistActivityHistory> activityMap = {};
    final DateTime nowDate = DateTime(now.year, now.month, now.day);
    final DateTime earliest = nowDate.subtract(const Duration(days: 365 ~/ 2));

    DateTime dateCounter = earliest;
    // Add entries for all days in the past year
    while (dateCounter.isBefore(nowDate) || dateCounter.isAtSameMomentAs(nowDate)) {
      // Find activity for this date
      AnilistActivityHistory? activityForDate;

      for (final activity in activityHistory) {
        final DateTime activityDate = DateTime.fromMillisecondsSinceEpoch(activity.date * 1000);

        if (activityDate.year == dateCounter.year && activityDate.month == dateCounter.month && activityDate.day == dateCounter.day) {
          activityForDate = activity;
          break;
        }
      }

      activityMap[dateCounter] = activityForDate ?? AnilistActivityHistory(date: dateCounter.millisecondsSinceEpoch ~/ 1000, level: 0, amount: 0);
      dateCounter = dateCounter.add(const Duration(days: 1));
    }
    // log('Activity map created with ${activityMap.length} entries:\n ${activityMap.entries.toList().reversed.map((e) => '${e.key.pretty()}: ${e.value.amount}').join('\n')}');

    // log('Start date: ${startDate.pretty()}, End date: ${now.pretty()}');
    // log('rows: $rows, columns: $columns, cellSize: $cellSize, cellSpacing: $cellSpacing');

    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        width: constraints.maxWidth,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: HeatMap(
                startDate: earliest,
                endDate: nowDate,
                colorsets: {
                  0: colorScale[0], // Level 0 (empty)
                  1: colorScale[1], // Level 1 (light)
                  2: colorScale[2], // Level 2 (medium)
                  5: colorScale[3], // Level 3 (dark)
                  10: colorScale[4], // Level 4 (darkest)
                },
                datasets: activityMap.map((date, activity) => MapEntry(date, activity.amount)),
                borderRadius: 2,
                colorTipSize: 15,
                fontSize: 0,
                colorMode: ColorMode.color,
                defaultColor: colorScale[0],
                size: (constraints.maxWidth - 600) / (51 / 2), // 7 days per week
                showColorTip: false,
                onClick: (p0) => log(
                  'Clicked on date: ${DateFormat('yyyy-MM-dd').format(p0)} with activity: ${activityMap[p0]?.amount ?? 0}',
                ),
              ),
            ),
            HDiv(20),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < colorScale.length; i++)
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: colorScale[i],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        HDiv(5),
                        Text(
                          'Amount ${i + 1}',
                          style: Manager.bodyStyle,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

DateTime getDateFromRowColumn(int row, int column, DateTime startDate) {
  // Calculate the date based on the row and column indices
  final int daysOffset = (row * 7) + column; // 7 days per week
  return startDate.add(Duration(days: daysOffset));
}
