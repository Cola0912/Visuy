import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _profileController = TextEditingController();

  String _savedName = '';
  String _savedProfile = '';

  void _saveProfile() {
    setState(() {
      _savedName = _nameController.text;
      _savedProfile = _profileController.text;
    });

    // ダイアログを表示して保存完了を通知
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('プロフィールを保存しました'),
          content: const Text('プロフィール情報が保存されました。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール設定'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              'プロフィール',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _profileController,
              decoration: const InputDecoration(hintText: 'プロフィールを入力してください'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('保存'),
            ),
            const SizedBox(height: 16),
            const Text(
              '保存されたプロフィール情報:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('名前: $_savedName'),
            Text('プロフィール: $_savedProfile'),
          ],
        ),
      ),
    );
  }
}
