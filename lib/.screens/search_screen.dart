import 'package:flutter/material.dart';
import 'dart:convert'; // JSON処理
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart'; // カレンダーライブラリ

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  Map<DateTime, List<Map<String, String>>> _events = {}; // 型の修正
  bool isLoading = false;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
  }

  // ファイル内容を取得してカレンダーに反映
  Future<void> fetchFileContent(String fileName) async {
    setState(() {
      isLoading = true;
      _events.clear();
    });

    try {
      final response = await http
          .get(Uri.parse('http://192.168.0.43:5000/get_file/$fileName'));

      if (response.statusCode == 200) {
        // テキストデータをパースしてイベントを作成
        String content = response.body;
        List<String> lines = content.split('\n');
        Map<DateTime, List<Map<String, String>>> parsedEvents = {}; // ここも修正

        for (String line in lines) {
          if (line.trim().isEmpty) continue;
          List<String> parts = line.split(',');
          if (parts.length < 4) continue;

          DateTime date = DateTime.parse(parts[0].trim());
          String eventName = parts[1].trim();
          String importance = parts[2].trim();
          String mentalImpact = parts[3].trim();

          // イベントを追加
          parsedEvents.putIfAbsent(date, () => []);
          parsedEvents[date]?.add({
            "event": eventName,
            "importance": importance,
            "mentalImpact": mentalImpact,
          });
        }

        setState(() {
          _events = parsedEvents;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load file content');
      }
    } catch (error) {
      print(error);
      setState(() {
        isLoading = false;
      });
    }
  }

  // 各日のイベントを取得
  List<Map<String, String>> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  // イベントを表示するウィジェット
  Widget _buildEventsList(List<Map<String, String>> events) {
    return Column(
      children: events.map((event) {
        // イベント名が長すぎる場合の処理
        String eventName = event['event']!;
        if (eventName.length > 10) {
          eventName = '${eventName.substring(0, 10)}...'; // 10文字でカットして「...」を追加
        }
        return ListTile(
          title: Text(eventName), // イベント名のみ表示
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Calendar'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Enter file name',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    fetchFileContent(searchController.text); // 検索ボタン押下時にファイル取得
                  },
                ),
              ),
            ),
          ),
          if (isLoading)
            Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: DateTime.now(),
                calendarFormat: _calendarFormat,
                eventLoader: _getEventsForDay, // イベントローダー
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                calendarStyle: CalendarStyle(
                  markersAlignment: Alignment.bottomCenter,
                  markersMaxCount: 3,
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                ),
              ),
            ),
          Expanded(
            child: ListView(
              children: _getEventsForDay(DateTime.now()).map((event) {
                return _buildEventsList([event]); // イベントリストの表示
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
