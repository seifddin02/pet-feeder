// lib/main.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'database/database_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PetFeederApp());
}

class PetFeederApp extends StatelessWidget {
  const PetFeederApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Feeder Control',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String deviceIp = "192.168.212.76";
  List<FeedingSchedule> schedules = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkScheduledTimes();
    });
  }

  Future<void> _loadSchedules() async {
    final schedules = await DatabaseHelper.instance.getAllSchedules();
    setState(() {
      this.schedules = schedules;
    });
  }

  void _checkScheduledTimes() {
    final now = TimeOfDay.now();
    for (var schedule in schedules) {
      if (schedule.isActive &&
          schedule.hour == now.hour &&
          schedule.minute == now.minute) {
        _dispenseFood();
      }
    }
  }

  Future<void> _editSchedule(FeedingSchedule schedule) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: schedule.hour, minute: schedule.minute),
    );

    if (time != null) {
      try {
        await DatabaseHelper.instance.update(
          FeedingSchedule(
            id: schedule.id,
            hour: time.hour,
            minute: time.minute,
            isActive: schedule.isActive,
          ),
        );
        await _loadSchedules();
      } catch (e) {
        _showSnackBar(e.toString());
      }
    }
  }

  Future<void> _addSchedule() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      try {
        await DatabaseHelper.instance.create(
          FeedingSchedule(
            hour: time.hour,
            minute: time.minute,
          ),
        );
        await _loadSchedules();
      } catch (e) {
        _showSnackBar(e.toString());
      }
    }
  }

  Future<void> _dispenseFood() async {
    try {
      final response = await http.post(
        Uri.parse('http://$deviceIp:6053/stepper_control'),
        body: {'target': '1500'},
      );
      if (response.statusCode == 200) {
        _showSnackBar('Food dispensed successfully');
      } else {
        _showSnackBar('Error dispensing food');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  Future<void> _activateBuzzer() async {
    try {
      final response = await http.post(
        Uri.parse('http://$deviceIp:6053/start_buzzer'),
        body: {'delay_time': '3000'},
      );
      if (response.statusCode == 200) {
        _showSnackBar('Buzzer activated');
      } else {
        _showSnackBar('Error activating buzzer');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Feeder Control'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _dispenseFood,
              child: const Text('Dispense Food Now'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _activateBuzzer,
              child: const Text('Activate Buzzer (3s)'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Scheduled Feeding Times:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  final schedule = schedules[index];
                  return ListTile(
                    title: Text(
                        TimeOfDay(hour: schedule.hour, minute: schedule.minute)
                            .format(context)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: schedule.isActive,
                          onChanged: (bool value) async {
                            await DatabaseHelper.instance.update(
                              FeedingSchedule(
                                id: schedule.id,
                                hour: schedule.hour,
                                minute: schedule.minute,
                                isActive: value,
                              ),
                            );
                            await _loadSchedules();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editSchedule(schedule),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await DatabaseHelper.instance.delete(schedule.id!);
                            await _loadSchedules();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSchedule,
        child: const Icon(Icons.add),
      ),
    );
  }
}
