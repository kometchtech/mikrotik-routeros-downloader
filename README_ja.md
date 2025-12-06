# MikroTik RouterOS Downloader

aria2cを使用した高速並列ダウンロードでMikroTik RouterOSパッケージをダウンロードするスクリプトです。

**対応環境:** Windows (PowerShell) | Linux (Bash)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[English](README.md) | 日本語

## 特徴

- 🚀 **高速並列ダウンロード** - aria2cを使用した高速マルチコネクションダウンロード
- 📦 **包括的なパッケージ対応** - バージョンで利用可能なすべてのパッケージをダウンロード
  - x86およびARM64用のCHR（Cloud Hosted Router）イメージ
  - 全アーキテクチャ向けRouterOSパッケージ（x86、ARM、ARM64、MIPSBE、MMIPS、PowerPC、SMIPS、Tile）
  - ISOイメージ
  - Netinstallツール
  - 追加ユーティリティ（Dude、帯域幅テストなど）
- 🔄 **レジューム対応** - 中断されたダウンロードを自動的に再開
- ✅ **バージョン自動判別** - RouterOS v6またはv7を自動検出し、適切なファイルリストを使用
- 🎯 **シンプルな使い方** - バージョン番号を指定するだけ

## 必要要件

### Windows
- **Windows** PowerShell 7.5.4以降
- **aria2c** - [https://aria2.github.io/](https://aria2.github.io/)からダウンロードしてインストール

### Linux
- **Bash**
- **aria2c** - パッケージマネージャー経由でインストール

### aria2cのインストール

**Windows（wingetを使用）:**
```powershell
winget install aria2.aria2
```

インストール後、ターミナルまたはPowerShellウィンドウを再起動して、aria2cがPATHで利用可能になるようにしてください。

**Linux（Ubuntu/Debian）:**
```bash
sudo apt install aria2
```

## インストール

### 方法1: ファイルを直接ダウンロード

**Windows:**
1. このリポジトリから`download.ps1`をダウンロード
2. 任意のフォルダに配置

**Linux:**
1. このリポジトリから`download.sh`をダウンロード
2. 任意のフォルダに配置
3. 実行権限を付与: `chmod +x download.sh`

### 方法2: リポジトリをクローン

```bash
git clone https://github.com/kometchtech/mikrotik-routeros-downloader.git
cd mikrotik-routeros-downloader

# Linuxの場合、スクリプトに実行権限を付与
chmod +x download.sh
```

## 使い方

### Windows (PowerShell)

#### 方法1: 実行ポリシーをバイパス（1回のみ）
```powershell
powershell -ExecutionPolicy Bypass -File .\download.ps1 7.20.6
```

#### 方法2: ファイルのブロックを解除（1回のみ）
```powershell
Unblock-File .\download.ps1
.\download.ps1 7.20.6
```

#### 方法3: 実行ポリシーを設定（恒久的）
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\download.ps1 7.20.6
```

### Linux (Bash)

```bash
./download.sh 7.20.6
```

### 使用例

**RouterOS v7.20.6をダウンロード:**
```powershell
# Windows (PowerShell)
.\download.ps1 7.20.6

# Linux (Bash)
./download.sh 7.20.6
```

**RouterOS v6.49.19をダウンロード:**
```powershell
# Windows (PowerShell)
.\download.ps1 6.49.19

# Linux (Bash)
./download.sh 6.49.19
```

## 出力

ファイルは現在のディレクトリに`routeros-<バージョン>`という名前のディレクトリにダウンロードされます。

例:
```
./routeros-7.20.6/
├── chr-7.20.6.img.zip
├── chr-7.20.6.vdi.zip
├── routeros-7.20.6.npk
├── mikrotik-7.20.6.iso
├── all_packages-x86-7.20.6.zip
├── all_packages-arm64-7.20.6.zip
└── ... (他多数)
```

## 動作の仕組み

1. **バージョン判別**: RouterOS v6またはv7を自動的に検出
2. **URL生成**: バージョンに基づいてダウンロードURLの完全なリストを作成
3. **並列ダウンロード**: aria2cを使用して、ファイルごとに複数の接続で複数のファイルを同時にダウンロード
4. **エラー処理**: 一部のファイルは特定のバージョンでは存在しない場合があります（404エラーは正常です）

### 使用されるaria2cパラメータ

- `-c`: 部分的にダウンロードされたファイルを継続
- `-x6`: ファイルあたり最大6接続
- `-s6`: 各ファイルを6つに分割
- `-k 1M`: 最小分割サイズ1MB
- `-Z`: ランダムな順序でダウンロード
- `--auto-file-renaming=false`: 既存ファイルの自動リネームを無効化

## トラブルシューティング

### "読み込めません" エラー

次のようなエラーが表示される場合：
```
ファイルを読み込めません。ファイルがデジタル署名されていません。
```

**解決方法:** ファイルのブロックを解除
```powershell
Unblock-File .\download.ps1
```

または、バイパス方式を使用：
```powershell
powershell -ExecutionPolicy Bypass -File .\download.ps1 7.20.6
```

### "aria2cが見つかりません" エラー

aria2cがインストールされていないか、システムPATHに含まれていません。

**解決方法:** [必要要件](#必要要件)セクションの方法でaria2cをインストールしてください。

### ダウンロード中の404エラー

一部のファイルは特定のバージョンでは存在しない場合があります（例：アーキテクチャ固有のパッケージ）。これは正常で、スクリプトは利用可能なファイルのダウンロードを続行します。

## アーキテクチャサポート

### RouterOS v7
- x86（標準PC、仮想マシン）
- ARM64（RB5009、CCR2xxxシリーズ）
- ARM（旧RBxxxxARMデバイス）
- MIPSBE（旧デバイス）
- MMIPS（旧デバイス）
- PowerPC（旧デバイス）
- SMIPS（旧デバイス）
- Tile（CCR1xxxシリーズ）

### RouterOS v6
ARM64 ISOを除くすべてのアーキテクチャ

## このプロジェクトについて

このプロジェクトは[Routerboard User Group JP](https://rb-ug.jp/)のkometechtechにより作成、管理されています。

### クレジット

- [mikrotik-routeros-downloader](https://github.com/bajodel/mikrotik-routeros-downloader)（bajodelによる）をベースにしています
- より高速なダウンロードのためにaria2c統合を追加
- コマンドライン引数によるシンプルな使用方法

## ライセンス

MITライセンス

Original work Copyright (c) 2025 bajodel  
Modified work Copyright (c) 2025 Routerboard User Group JP

詳細は[LICENSE](LICENSE)ファイルをご覧ください。

## 貢献

貢献を歓迎します！プルリクエストをお気軽に送信してください。

## 変更履歴

変更履歴の詳細は[CHANGELOG.md](CHANGELOG.md)をご覧ください。

## リンク

- [MikroTik公式ダウンロードページ](https://mikrotik.com/download)
- [RouterOSドキュメント](https://help.mikrotik.com/docs/)
- [Routerboard User Group JP](https://rb-ug.jp/)
- [aria2公式サイト](https://aria2.github.io/)

## サポート

問題、質問、提案がある場合：
- 🐛 [Issueを開く](https://github.com/kometchtech/mikrotik-routeros-downloader/issues)
- 💬 [Routerboard User Group JP](https://rb-ug.jp/)を訪問

---

Routerboard User Group JPのkometechtechより ❤️ を込めて
