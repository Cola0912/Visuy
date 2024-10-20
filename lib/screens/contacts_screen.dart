import 'dart:async'; // タイマーを使用するために追加
import 'package:flutter/material.dart';
import 'profile_screen.dart'; // ProfileScreen をインポート
import 'dart:convert';
import 'package:http/http.dart' as http; // httpパッケージをインポート
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferencesをインポート

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  String _name = "Spanyan"; // デフォルトの名前
  String _affiliation = "東京工科大学"; // デフォルトの所属
  String _introduction = "自己紹介"; // デフォルトの自己紹介
  String _link = "https://x.com/home"; // デフォルトのリンク
  int _fatigueLevel = 0; // 初期値を0に設定
  int _friends = 20; // デフォルトのフレンド数
  int _teams = 3; // デフォルトのチーム数
  String _profileNumber = '01'; // 初期値として管理番号01を使用
  Timer? _timer; // タイマーを保持する変数

  @override
  void initState() {
    super.initState();
    _loadProfileNumber(); // 保存された管理番号をロード
    _startAutoRefresh(); // 1秒おきにデータを自動取得
  }

  @override
  void dispose() {
    _timer?.cancel(); // ウィジェットが破棄される際にタイマーを停止
    super.dispose();
  }

  // 1秒おきにデータを自動取得するタイマーを開始
  void _startAutoRefresh() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      _fetchProfile(); // プロフィールを取得
      _fetchCalendarData(); // カレンダーデータを取得
    });
  }

  // プロフィール設定画面から戻ってきた際に再度データを更新し、疲労度を再計算
  Future<void> _updateFromProfile(Map<String, String>? result) async {
    if (result != null) {
      setState(() {
        _name = result['name'] ?? _name;
        _affiliation = result['affiliation'] ?? _affiliation;
        _introduction = result['introduction'] ?? _introduction;
        _link = result['link'] ?? _link;
        _friends = int.tryParse(result['friends'] ?? '20') ?? 20;
        _teams = int.tryParse(result['teams'] ?? '3') ?? 3;
      });
      _fetchCalendarData(); // プロフィールが更新されたら疲労度も更新
    }
  }

  // SharedPreferencesから管理番号を読み込み、プロフィールとカレンダーのデータを取得し疲労度も再計算
  Future<void> _loadProfileNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedProfileNumber = prefs.getString('profile_number');
    if (savedProfileNumber != null && savedProfileNumber != _profileNumber) {
      setState(() {
        _profileNumber = savedProfileNumber; // 管理番号を設定
      });
      _fetchProfile(); // プロフィールをサーバーから取得
      _fetchCalendarData(); // カレンダーデータを取得し、疲労度を計算
    }
  }

  // プロファイルをサーバーから取得する関数
  Future<void> _fetchProfile() async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.0.43:5000/u$_profileNumber.json'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _name = data['name'] ?? _name;
          _affiliation = data['affiliation'] ?? _affiliation;
          _introduction = data['introduction'] ?? _introduction;
          _link = data['link'] ?? _link;
          _friends = int.tryParse(data['friends'] ?? '20') ?? 20;
          _teams = int.tryParse(data['teams'] ?? '3') ?? 3;
        });
        print('Profile loaded successfully');
      } else {
        print('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  // カレンダーのデータを取得し、疲労度を計算する
  Future<void> _fetchCalendarData() async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.0.43:5000/$_profileNumber.json'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> calendarData = json.decode(response.body);
        setState(() {
          _fatigueLevel = _calculateFatigueLevel(calendarData); // 疲労度を計算
        });
      } else {
        throw Exception('Failed to load calendar data');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  // カレンダーデータに基づいて疲労度を計算する関数
  int _calculateFatigueLevel(Map<String, dynamic> data) {
    int totalImportance = 0;
    int totalImpact = 0;

    DateTime now = DateTime.now();
    DateTime startOfWeek =
        now.subtract(Duration(days: now.weekday - 1)); // 今週の月曜日
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6)); // 今週の日曜日

    // 今週のイベントをループして重要度とメンタル影響を集計
    data.forEach((dateStr, events) {
      DateTime eventDate = DateTime.parse(dateStr);
      if (eventDate.isAfter(startOfWeek) &&
          eventDate.isBefore(endOfWeek.add(Duration(days: 1)))) {
        for (var event in events) {
          int importance = int.tryParse(event['importance'] ?? '0') ?? 0;
          int impact = int.tryParse(event['impact'] ?? '0') ?? 0;

          totalImportance += importance;
          totalImpact += impact;
        }
      }
    });

    // 合計が0なら疲労度は0に設定
    int totalEventParameters = totalImportance + totalImpact;
    if (totalEventParameters == 0) {
      return 0;
    }

    return (totalEventParameters / 70 * 100).round(); // パーセンテージに変換
  }

  // プロファイルセーブ時に管理番号を保存し、それに基づいてデータを取得
  Future<void> _saveProfile(String newProfileNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_number', newProfileNumber); // 新しい管理番号を保存
    setState(() {
      _profileNumber = newProfileNumber; // プロフィール番号を更新
    });
    await _fetchProfile(); // 更新された番号でプロフィールを取得
    await _fetchCalendarData(); // 更新された番号でカレンダーデータを取得
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[50],
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(Icons.person, color: Colors.black),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.more_vert, color: Colors.black),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.pink[50],
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size(150, 150),
                      painter: RingPainter(_fatigueLevel),
                    ),
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/spanyan.png'),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  _name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _affiliation,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "疲労度: $_fatigueLevel%", // 疲労度の表示
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          "$_friends",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("friends"),
                      ],
                    ),
                    SizedBox(width: 40),
                    Column(
                      children: [
                        Text(
                          "$_teams",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("teams"),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(),
                          ),
                        );
                        _updateFromProfile(result); // プロフィール画面からの結果を反映
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text("プロフィールを編集"),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.link, color: Colors.blue),
                    SizedBox(width: 5),
                    Text(
                      _link,
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  buildSelfIntroductionSection("自己紹介", _introduction),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSelfIntroductionSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}

class RingPainter extends CustomPainter {
  final int fatigueLevel;

  RingPainter(this.fatigueLevel);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    final double startAngle = -3.14 / 2;
    final double sweepAngle = 3.14 * 2 * (fatigueLevel / 100);

    if (fatigueLevel <= 10) {
      paint.color = Colors.blue;
    } else if (fatigueLevel <= 25) {
      paint.color = Colors.green;
    } else if (fatigueLevel <= 50) {
      paint.color = Colors.yellow;
    } else if (fatigueLevel <= 75) {
      paint.color = Colors.orange;
    } else {
      paint.color = Colors.red;
    }

    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: size.width / 2 - 4),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
