import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<DateTime, List<dynamic>> _events = {};
  List<dynamic> _selectedEvents = [];
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _fetchEvents(); // ラズパイからのデータ取得
  }

  Future<void> _fetchEvents() async {
    final response =
        await http.get(Uri.parse('http://192.168.0.43:5000/get_file/01'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      List events = jsonData['events'];

      Map<DateTime, List<dynamic>> fetchedEvents = {};
      for (var event in events) {
        DateTime date = DateTime.parse(event['date']);
        if (fetchedEvents[date] == null) {
          fetchedEvents[date] = [];
        }
        fetchedEvents[date]?.add(event['title']);
      }

      setState(() {
        _events = fetchedEvents;
      });
    } else {
      print('Failed to load events');
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('カレンダー'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _selectedEvents = _getEventsForDay(selectedDay);
              });
            },
            eventLoader: _getEventsForDay,
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedEvents.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_selectedEvents[index].toString()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
