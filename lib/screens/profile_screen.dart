import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferencesを使用
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _affiliationController = TextEditingController();
  final _introductionController = TextEditingController();
  final _friendsController = TextEditingController();
  final _teamsController = TextEditingController();
  final _profileNumberController = TextEditingController(); // 管理番号用コントローラ

  int _selectedFatigueLevel = 0;
  Color _selectedColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _loadSavedProfileNumber(); // 保存された管理番号をロード
  }

  // 管理番号をローカルに保存
  Future<void> _saveProfileNumber(String profileNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_number', profileNumber); // 管理番号を保存
  }

  // ローカルから管理番号を読み込む
  Future<void> _loadSavedProfileNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedProfileNumber = prefs.getString('profile_number'); // 管理番号を取得
    if (savedProfileNumber != null) {
      setState(() {
        _profileNumberController.text = savedProfileNumber; // テキストフィールドに表示
        _loadProfileFromServer(savedProfileNumber); // 保存された管理番号に基づいてプロファイルをロード
      });
    }
  }

  // プロファイルをサーバーから取得する関数
  Future<void> _loadProfileFromServer(String profileNumber) async {
    try {
      final url = Uri.parse('http://192.168.0.43:5000/u$profileNumber.json');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final profileData = json.decode(response.body);
        setState(() {
          _nameController.text = profileData['name'] ?? '';
          _affiliationController.text = profileData['affiliation'] ?? '';
          _introductionController.text = profileData['introduction'] ?? '';
          _friendsController.text = profileData['friends'] ?? '';
          _teamsController.text = profileData['teams'] ?? '';
          _selectedColor =
              Color(int.parse(profileData['color'] ?? '0xff000000'));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('プロファイルがロードされました')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('プロファイルのロードに失敗しました: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print("Error occurred while loading profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('プロファイルのロード中にエラーが発生しました')),
      );
    }
  }

  // プロファイルを保存する関数
  Future<void> _saveProfile() async {
    if (_profileNumberController.text.isEmpty) {
      print("管理番号が入力されていません");
      return;
    }

    // 管理番号をローカルに保存
    await _saveProfileNumber(_profileNumberController.text);

    try {
      final url = Uri.parse('http://192.168.0.43:5000/save_profile');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': _profileNumberController.text,
          'profile': {
            'name': _nameController.text,
            'affiliation': _affiliationController.text,
            'introduction': _introductionController.text,
            'friends': _friendsController.text,
            'teams': _teamsController.text,
            'color': _selectedColor.value.toString(),
          },
        }),
      );

      if (response.statusCode == 200) {
        print("Profile saved successfully");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('プロファイルが保存されました')),
        );
      } else {
        print("Failed to save profile: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('プロファイルの保存に失敗しました: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print("Error occurred: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('プロファイルの保存中にエラーが発生しました')),
      );
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
                '管理番号 (例: 01)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _profileNumberController,
                decoration: const InputDecoration(hintText: '管理番号を入力してください'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_profileNumberController.text.isNotEmpty) {
                    _loadProfileFromServer(
                        _profileNumberController.text); // プロファイルをロード
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('管理番号を入力してください')),
                    );
                  }
                },
                child: const Text('プロファイルを取得'),
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
                onPressed: _saveProfile,
                child: const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 色選択ボタンのウィジェット
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
