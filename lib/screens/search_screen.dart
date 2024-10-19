import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferencesをインポート

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Map<DateTime, List<Map<String, String>>> _events = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _profileNumber = '01'; // 初期設定は管理番号01
  String _searchQuery = '01'; // 初期設定は自分のカレンダー
  final List<String> _levels = ['1', '2', '3', '4', '5'];
  String _displayMode = 'メンタル影響';
  String _selectedTab = 'MyCalendar'; // 現在選択されているタブを保持
  List<String> _groupMembers =
      List.generate(99, (index) => (index + 2).toString().padLeft(2, '0'));
  String? _selectedMember; // 選択されたメンバー

  @override
  void initState() {
    super.initState();
    _loadProfileNumber(); // 保存された管理番号をロード
  }

  Future<void> _loadProfileNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedProfileNumber = prefs.getString('profile_number');
    if (savedProfileNumber != null) {
      setState(() {
        _profileNumber = savedProfileNumber;
        _searchQuery = _profileNumber; // 管理番号に基づいてカレンダーをロード
      });
      _loadFileContent(_searchQuery);
    }
  }

  Future<void> _loadFileContent(String filename) async {
    try {
      setState(() {
        _events = {};
      });

      final response =
          await http.get(Uri.parse('http://192.168.0.43:5000/$filename.json'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            _events = {
              for (var entry in data.entries)
                DateTime.parse(entry.key): List<Map<String, String>>.from(
                  entry.value.map<Map<String, String>>(
                    (item) => Map<String, String>.from(item),
                  ),
                ),
            };
          });
        } else {
          setState(() {
            _events = {};
          });
        }
      } else {
        throw Exception('Failed to load file content');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  List<Map<String, String>> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  Future<void> _addEvent(String filename, DateTime date, String title,
      String importance, String impact) async {
    final newEvent = {
      "title": title,
      "importance": importance,
      "impact": impact,
    };

    final url = Uri.parse('http://192.168.0.43:5000/add_event');
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'filename': filename,
          'date': date.toIso8601String(),
          'title': title,
          'importance': importance,
          'impact': impact,
        }));

    if (response.statusCode == 200) {
      setState(() {
        if (_events[date] != null) {
          _events[date]?.add(newEvent);
        } else {
          _events[date] = [newEvent];
        }
      });
    } else {
      throw Exception('Failed to add event');
    }
  }

  Color _getEventColor(Map<String, String> event) {
    String valueString =
        event[_displayMode == 'メンタル影響' ? 'impact' : 'importance'] ?? '1';

    int value;
    try {
      value = int.parse(valueString);
    } catch (e) {
      value = 1;
    }

    switch (value) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Color _calculateAverageColor(List<Map<String, String>> events) {
    if (events.isEmpty) return Colors.grey;

    int total = 0;
    for (var event in events) {
      String valueString =
          event[_displayMode == 'メンタル影響' ? 'impact' : 'importance'] ?? '1';
      total += int.tryParse(valueString) ?? 1;
    }
    int average = (total / events.length).round();

    switch (average) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  void _onDayLongPressed(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    _showAddEventDialog();
  }

  void _showAddEventDialog() {
    if (_selectedDay == null) return;

    showDialog(
      context: context,
      builder: (context) {
        final titleController = TextEditingController();
        String selectedImportance = _levels[0];
        String selectedImpact = _levels[0];

        return AlertDialog(
          title: Text('新しい予定を追加'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'タイトル'),
              ),
              DropdownButtonFormField<String>(
                value: selectedImportance,
                decoration: InputDecoration(labelText: '重要度'),
                items: _levels.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedImportance = newValue!;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedImpact,
                decoration: InputDecoration(labelText: 'メンタル影響'),
                items: _levels.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedImpact = newValue!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                _addEvent(_searchQuery, _selectedDay!, titleController.text,
                    selectedImportance, selectedImpact);
                Navigator.of(context).pop();
              },
              child: Text('追加'),
            ),
          ],
        );
      },
    );
  }

  void _onTabChanged(String tab) {
    setState(() {
      _selectedTab = tab;
      _searchQuery = tab == 'MyCalendar' ? _profileNumber : tab; // 管理番号を使用
      _loadFileContent(_searchQuery);
    });
  }

  void _onMemberSelected(String member) {
    setState(() {
      _selectedMember = member;
      _searchQuery = member;
      _loadFileContent(_searchQuery);
    });
  }

  void _searchFiles(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadFileContent(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedTab == 'MyCalendar'
            ? 'MyCalendar'
            : _selectedMember != null
                ? 'メンバー $_selectedMember'
                : 'グループ'), // メンバー名の表示
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () => _onTabChanged('MyCalendar'),
                child: Text(
                  'MyCalendar',
                  style: TextStyle(
                    color: _selectedTab == 'MyCalendar'
                        ? Colors.blue
                        : Colors.black, // ハイライト
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _onTabChanged('Group1'),
                child: Text(
                  'Group1',
                  style: TextStyle(
                    color:
                        _selectedTab == 'Group1' ? Colors.blue : Colors.black,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _onTabChanged('Group2'),
                child: Text(
                  'Group2',
                  style: TextStyle(
                    color:
                        _selectedTab == 'Group2' ? Colors.blue : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onDayLongPressed: _onDayLongPressed,
            eventLoader: _getEventsForDay,
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                if (_events[day] != null) {
                  final color = _calculateAverageColor(_getEventsForDay(day));
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDay = day;
                        _focusedDay = focusedDay;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.all(2.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: Text(
                        '${day.day}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                } else {
                  return Container(
                    margin: const EdgeInsets.all(2.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Text(
                      '${day.day}',
                      style: TextStyle(color: Colors.black),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 3.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                value: _displayMode,
                onChanged: (String? newValue) {
                  setState(() {
                    _displayMode = newValue!;
                  });
                },
                items: ['メンタル影響', '重要度'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(width: 10.0),
              ElevatedButton(
                onPressed: () {
                  _showAddEventDialog();
                },
                child: Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 0.0),
          if (_selectedTab != 'MyCalendar') // MyCalendar以外でメンバーリストと検索窓を表示
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'メンバーを検索',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  _searchFiles(value);
                },
              ),
            ),
          if (_selectedTab != 'MyCalendar')
            Expanded(
              child: Column(
                children: [
                  Text('メンバーリスト'),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _groupMembers.length,
                      itemBuilder: (context, index) {
                        final member = _groupMembers[index];
                        return ListTile(
                          title: Text('メンバー $member'),
                          onTap: () => _onMemberSelected(member),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _selectedDay != null
                ? ListView.builder(
                    itemCount: _getEventsForDay(_selectedDay!).length,
                    itemBuilder: (context, index) {
                      final event = _getEventsForDay(_selectedDay!)[index];
                      return Container(
                        color: _getEventColor(event),
                        child: ListTile(
                          title: Text(event['title'] ?? 'No Title'),
                          subtitle: Text(
                              '重要度: ${event['importance']} | メンタル影響: ${event['impact']}'),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text('日付を選んで予定を確認してください'),
                  ),
          ),
        ],
      ),
    );
  }
}
