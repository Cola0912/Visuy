import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _affiliationController = TextEditingController();
  final _introductionController = TextEditingController();
  final _linkController = TextEditingController();
  final _friendsController = TextEditingController();
  final _teamsController = TextEditingController();
  final _idController = TextEditingController(); // 管理番号用のコントローラー
  int _selectedFatigueLevel = 0; // 初期値を0%に設定
  Color _selectedColor = Colors.blue; // デフォルト色

  @override
  void initState() {
    super.initState();
    _loadProfileData(); // プロフィールデータをロード
  }

  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _idController.text = prefs.getString('userId') ?? '';
      _nameController.text = prefs.getString('name') ?? '';
      _affiliationController.text = prefs.getString('affiliation') ?? '';
      _introductionController.text = prefs.getString('introduction') ?? '';
      _linkController.text = prefs.getString('link') ?? '';
      _friendsController.text = prefs.getString('friends') ?? '';
      _teamsController.text = prefs.getString('teams') ?? '';
      _selectedFatigueLevel = prefs.getInt('fatigueLevel') ?? 0;
      _selectedColor = Color(prefs.getInt('color') ?? Colors.blue.value);
    });
  }

  Future<void> _saveProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', _idController.text);
    await prefs.setString('name', _nameController.text);
    await prefs.setString('affiliation', _affiliationController.text);
    await prefs.setString('introduction', _introductionController.text);
    await prefs.setString('link', _linkController.text);
    await prefs.setString('friends', _friendsController.text);
    await prefs.setString('teams', _teamsController.text);
    await prefs.setInt('fatigueLevel', _selectedFatigueLevel);
    await prefs.setInt('color', _selectedColor.value);

    // サーバーのJSONファイルにデータを保存
    _saveToJsonFile();
  }

  Future<void> _saveToJsonFile() async {
    if (_idController.text.isEmpty) return;

    final newProfileData = {
      'name': _nameController.text,
      'affiliation': _affiliationController.text,
      'introduction': _introductionController.text,
      'link': _linkController.text,
      'friends': _friendsController.text,
      'teams': _teamsController.text,
      'fatigueLevel': _selectedFatigueLevel.toString(),
      'color': _selectedColor.value.toString(),
    };

    final url =
        Uri.parse('http://192.168.0.43:5000/add_profile'); // エンドポイントを適宜修正
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': _idController.text,
        'profile': newProfileData,
      }),
    );

    if (response.statusCode == 200) {
      print('プロフィールが正常に保存されました');
    } else {
      print('プロフィールの保存に失敗しました');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール設定'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '管理番号',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _idController,
                decoration: const InputDecoration(hintText: '管理番号を入力してください'),
              ),
              const SizedBox(height: 16),
              const Text(
                '名前',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: '名前を入力してください'),
              ),
              const SizedBox(height: 16),
              const Text(
                '所属',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _affiliationController,
                decoration: const InputDecoration(hintText: '所属を入力してください'),
              ),
              const SizedBox(height: 16),
              const Text(
                '自己紹介',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _introductionController,
                decoration: const InputDecoration(hintText: '自己紹介を入力してください'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              const Text(
                'リンク',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _linkController,
                decoration: const InputDecoration(hintText: 'リンクを入力してください'),
              ),
              const SizedBox(height: 16),
              const Text(
                'フレンドの数',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _friendsController,
                decoration: const InputDecoration(hintText: 'フレンドの数を入力してください'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text(
                'チームの数',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _teamsController,
                decoration: const InputDecoration(hintText: 'チームの数を入力してください'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text(
                'プロフィール画像の色',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8.0,
                children: [
                  _buildColorButton(Colors.red),
                  _buildColorButton(Colors.orange),
                  _buildColorButton(Colors.yellow),
                  _buildColorButton(Colors.green),
                  _buildColorButton(Colors.blue),
                  _buildColorButton(Colors.purple),
                  _buildColorButton(Colors.black),
                  _buildColorButton(Colors.white),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _saveProfileData();
                },
                child: const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _selectedColor == color ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
}
