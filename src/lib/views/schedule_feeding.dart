import 'package:flutter/material.dart';

class ScheduleFeedingPage extends StatefulWidget {
  @override
  _ScheduleFeedingPageState createState() => _ScheduleFeedingPageState();
}

class _ScheduleFeedingPageState extends State<ScheduleFeedingPage> {
  final TextEditingController _dayController = TextEditingController();
  TimeOfDay? _selectedTime; // Use nullable TimeOfDay

  // A list to store existing schedules
  List<Map<String, String>> existingSchedules = [];

  // Days of the week
  List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  // Function to check if the schedule already exists
  bool _scheduleExists(String day, String time) {
    for (var schedule in existingSchedules) {
      if (schedule['day'] == day && schedule['time'] == time) {
        return true;
      }
    }
    return false;
  }

  // Method to handle scheduling
  void _scheduleFeeding() {
    String day = _dayController.text.trim();
    String time = _selectedTime != null ? _selectedTime!.format(context) : '';

    if (day.isEmpty || time.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select both day and time')),
      );
    } else if (_scheduleExists(day, time)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This feeding time already exists')),
      );
    } else {
      setState(() {
        existingSchedules.add({'day': day, 'time': time});
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Feeding time scheduled successfully!')),
      );
    }
  }

  // Function to open a time picker
  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule Feeding'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              items: days.map((String day) {
                return DropdownMenuItem(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _dayController.text = value ?? '';
                });
              },
              decoration: InputDecoration(labelText: 'Select Day'),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                _selectTime(context);
              },
              child: AbsorbPointer(
                child: TextField(
                  controller: TextEditingController(
                    text: _selectedTime != null
                        ? _selectedTime!.format(context)
                        : '',
                  ),
                  decoration: InputDecoration(
                    labelText: 'Select Time',
                    suffixIcon: Icon(Icons.access_time),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _scheduleFeeding,
              child: Text('Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}
