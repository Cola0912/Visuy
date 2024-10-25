
# Visuy!

## プロジェクト概要

CalenhubはFlutterを使用して開発されたアプリケーションです。このプロジェクトは、ユーザーがプロフィール設定、検索、データの追加、連絡先管理などを行うことができるシンプルなモバイル/デスクトップアプリケーションを提供します。アプリの各画面は、BottomNavigationBarを使用して簡単に切り替えることができます。

## 機能

- **プロフィール設定**: ユーザーは自身のプロフィール情報（名前、自己紹介など）を入力し、保存することができます。
- **検索**: データの検索機能を提供します。
- **データ追加**: 新しいデータを追加する画面を提供します。
- **連絡先管理**: 連絡先情報を管理する機能を提供します。

## 使用技術

- **Flutter**: モバイルアプリケーションフレームワーク
- **Dart**: プログラミング言語
- **Material Design**: ユーザーインターフェースのデザイン

## インストールと実行

1. Flutter SDKをインストールしてください（[公式サイト](https://flutter.dev/docs/get-started/install)）。
2. このリポジトリをクローンします。
   ```
   git clone https://github.com/yourusername/calenhub.git
   ```
3. 依存関係をインストールします。
   ```
   flutter pub get
   ```
4. アプリケーションを実行します。
   ```
   flutter run
   ```

## ファイル構成

```
lib/
├── main.dart              # アプリのエントリーポイント
└── screens/               # 各画面のディレクトリ
    ├── profile_screen.dart   # プロフィール画面
    ├── search_screen.dart    # 検索画面
    ├── add_screen.dart       # データ追加画面
    └── contacts_screen.dart  # 連絡先画面
```

## ライセンス

このプロジェクトはMITライセンスのもとで公開されています。詳細は[LICENSE](LICENSE)ファイルをご確認ください。
