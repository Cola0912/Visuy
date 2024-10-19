import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomCalendarScreen extends StatefulWidget {
  @override
  _CustomCalendarScreenState createState() => _CustomCalendarScreenState();
}

class _CustomCalendarScreenState extends State<CustomCalendarScreen> {
  Map<DateTime, List<Map<String, String>>> _events = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  // ラズパイサーバから予定を取得する関数
  Future<void> _fetchEvents() async {
    final url = Uri.parse('http://192.168.0.43:5000/events');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _events = _parseEvents(data);
        });
      } else {
        print('Error: Failed to load events');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // サーバから取得したデータをカレンダー形式に変換
  Map<DateTime, List<Map<String, String>>> _parseEvents(
      Map<String, dynamic> data) {
    Map<DateTime, List<Map<String, String>>> events = {};
    data.forEach((dateString, eventList) {
      final DateTime date = DateTime.parse(dateString);
      final List<Map<String, String>> eventsForDate =
          (eventList as List).map((event) {
        return {
          'title': event['title'],
          'priority': event['priority'],
          'damage': event['damage']
        };
      }).toList();
      events[date] = eventsForDate;
    });
    return events;
  }

  // 特定の日付に予定があるか確認する関数
  List<Map<String, String>> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Custom Calendar'),
      ),
      body: Column(
        children: [
          _buildCalendar(),
          const SizedBox(height: 10),
          _buildEventList(),
        ],
      ),
    );
  }

  // カレンダーウィジェット
  Widget _buildCalendar() {
    return TableCalendar(
      focusedDay: _focusedDay,
      firstDay: DateTime(2020),
      lastDay: DateTime(2030),
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      eventLoader: _getEventsForDay,
    );
  }

  // 予定リストのウィジェット
  Widget _buildEventList() {
    final events = _getEventsForDay(_selectedDay ?? _focusedDay);
    return Expanded(
      child: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return ListTile(
            title: Text(event['title'] ?? 'No Title'),
            subtitle: Text(
                'Priority: ${event['priority']}, Damage: ${event['damage']}'),
          );
        },
      ),
    );
  }
}
