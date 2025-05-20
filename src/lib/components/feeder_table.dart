import 'package:flutter/material.dart';
import '../views/schedule_feeding.dart';

class FeederTable extends StatelessWidget {
  final List<Map<String, String>> feedingTimes = [
    {"Day": "Monday", "Time": "08:00 AM"},
    {"Day": "Wednesday", "Time": "06:00 PM"},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Scheduled Feeding Times',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          itemCount: feedingTimes.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                  '${feedingTimes[index]["Day"]} - ${feedingTimes[index]["Time"]}'),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  // Delete feeding time
                },
              ),
            );
          },
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ScheduleFeedingPage()),
            );
          },
          child: Text('Schedule Feeding'),
        ),
      ],
    );
  }
}
