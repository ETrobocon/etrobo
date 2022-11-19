# etrobo all-in-one installer/builder/launcher environment
[ETロボコン](https://etrobo.jp/)のEV3/シミュレータ双方に対応する開発環境です。

see INSTALL that is written by english language

注：ここでは、`startetrobo`によってインストールされるファイル群を「**etroboパッケージ**」、`startetrobo`によって起動する開発環境を「**etrobo環境**」と呼びます。

etrobo環境は、以下のソフトウェアおよび成果物の一部を利用し構成され、etroboパッケージはこれらを自動的に取得しインストールします。
- [ETロボコンシミュレータ](https://etrobo.jp/)
- [TOPPERS/EV3RT](https://dev.toppers.jp/trac_user/ev3pf/wiki/WhatsEV3RT)
- [TOPPERS/箱庭](https://toppers.github.io/hakoniwa/)
- [GNU Arm Embedded Toolchain](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm)

インストール方法や環境の解説は[**etroboパッケージのWiki**](https://github.com/ETrobocon/etrobo/wiki)をご覧ください。

インストールがうまくいかなかった場合は、ターミナルのログを添えて [「やばい」ラベルで問題を報告](https://github.com/ETrobocon/etrobo/issues)してください。
特にMac版は環境による差が大きく、あまり広範なテストができていません。お気づきの点があればお気軽にIssueを立ててください。

## 主な特徴

- Visual Studio Code（VSCode）以外のインストールを完全自動化
- Windows/Mac/Linuxで同一の操作による開発を実現
- Mindstorms EV3実機向けのEV3RT/HRP3と、ETロボコンシミュレータ向けのAthrill/ASP3が、単一のソースで一度にビルド可能
- USB接続のEV3RT App Loader向けユーティリティを搭載、ビルド時に自動でプロジェクト名をファイル名として転送可能
- ビルドからシミュレータの実行まで１コマンドで自動処理
- サンプルコースとサンプルコードを同梱

 注：**ここに同梱されているシミュレータは、一般配布用の評価版です**。大会で実際に使用するコースデータやシミュレータには、参加者限定で配布されるものを使用し開発してください。シミュレータの性能や走行体の挙動が異なります。

 同梱されている評価版シミュレータのご利用は、以下の用途に限らせていただきます。

 * ETロボコンへの参加のため
 * ETロボコンへの参加を検討するため
 * ETロボコンの広報
 * ETロボコンに参加、協力していることを広報するため

(ご不明な点は、[ETロボコン 本部事務局](https://www.etrobo.jp/)までお問合せください)

Copyright(C) 2020-2022 ETロボコン実行委員会, All rights reserved.

## 動作環境

### Windows

- x86-64アーキテクチャのCPU
- Windows 11、またはWindows 10 version 2004以降、またはWindows 10 Enterprise LTSC 2021
    - version 21H2以降の利用を推奨します。 
    - version 1709未満のWindows 10や、Windows 7などでは動作しません。
    - version 1903/1909のWindows 10でもWSL2で動作しますが、サポート対象外です。
    - version 1809(LTSC 2019)はWSL1でのみ動作します。
- `wsl --install`によりインストールされたUbuntuまたはUbuntu-20.04(WSL2)
    - インストールにWindowsの管理者権限が必要です。
    - Ubuntu-22.04でも動くようになった、はずです。トラブルありましたらご連絡ください。
    - Ubuntu-18.04、Ubuntu-16.04、Debian(9/10/11)でも動作するようですが、サポート対象外です。
    - Windows Services for Linux (WSL1)のサポートも引き続き行いますが、LTSC 2019に限ります。
- Visual Studio Code(「Remote - WSL」拡張機能）のインストール

### Mac
- x86-64アーキテクチャのCPU、またはApple Silicon
    - 動作確認は、以下のMacで行っています：
        - MacBook Pro (Retina, Mid 2012) / macOS Mojave 10.14.6 / Xcode 11.0
        - MacBook Air (M1, 2020) 8GB-7GPU / macOS Venture 13.0.1
- macOS Mojave(10.14)以降
    - 環境のインストールに管理者権限が必要です。
- Apple Silicon機の場合、Rossetaのインストール
- Xcode(Command Line Tools)のインストール
- Visual Studio Codeのインストール

### Linux
- x86-64アーキテクチャのCPU
- Debian GNU/Linux 10 または Ubuntu 20.04（または18.04）
    - 環境のインストールにsudoers権限が必要です。
    - Debian 11/Ubuntu 22.04でも動くようになった、はずです。トラブルありましたらご連絡ください。
        - Debian 11にインストールする場合は、wgetが必要です `sudo apt -y install wget`
    - Debian 9/Ubuntu 16.04でも動作する可能性はありますが、サポート対象外です。
    - Ubuntu 18.04でも引き続き動作すると考えていますが、今後広範な動作確認は行われません。
- Visual Studio Codeのインストール

### Chrome OS/Chromium OS
- x86-64アーキテクチャのCPU
    - Chrome OSでの動作確認は以下の環境で行っています：
        - ASUS Chromebook C223NA
        - Chrome OS 102.0.5005.75 (Official Build)
        - Debian GNU/Linux 11 (bullseye)
    - Chromium OSでの動作確認は以下の環境で行っています：
        - ASUS TAICHI21
        - CloudReady:Home Edition 80.4.1 Stableチャンネル
- Chrome/Chromium OS 80以降
    - 79でも、Debian 10にアップグレードすると動作する可能性はありますが、未検証です。
    - 78以前では、localhostのポート制限により動作しない可能性が高いものと認識していますが、未確認です。
- 「Linux開発環境」のインストール
    - etroboパッケージのインストール手順等はLinux版をご覧ください。
- Visual Studio Codeのインストール
    - ダウンロードファイルを2本指タップし、「Linux(ベータ版)でのインストール」を選択します。
- 制限事項：ChromeOS 101以前のDebian 10向けLinuxコンテナにて、
`Crostini GPU Support`有効の状態ではETロボコンシミュレータが起動しません。
ChromeOS 102以降のDebian 11向けLinuxコンテナでは有効にできますが、それでも実用的なパフォーマンスは期待できません。
EV3実機向けの開発環境としては充分です。

## 動作確認＆主なコマンドの説明

etrobo環境が起動しましたら、ターミナルを開いて（Windows:`Ctrl`+`@`・Mac/Linux:`Ctrl`+`Shift`+`@`）、とりあえず `make sample` と叩いてください。未来が見えます。

etrobo環境は様々なコマンドを提供していますが、これらは原則としてetrobo環境の初期ディレクトリ（`~/etrobo`）上で発給してください。
もしも迷子になった場合は、`cd "$ETROBO_ROOT"`でどこからでも戻ることができます。

HackEVの実機をお持ちの方は、USBポートにさして電源を入れ、`make app=helloev3 up`と入力してみてください。これだけで`app=`の値をファイル名としたモジュールのビルドと転送ができます。この時、Windowsではマウントにsudoers権限が必要であるため、たまにパスワードを聞かれます。その時はログインパスワードを入力してください。

一度`app=`を指定してビルドすると、2回目以降はこれを省略し、`make up`だけでビルドと転送が可能です。

- このEV3オートマウント機能は、**EV3（SDカード）のボリューム名が「EV3RT」から始まるものでなければ動作しません**。
    - Windows - エクスプローラの`PC`からドライブを選択し、ボリューム名部分をクリックして変更
    - Mac - デスクトップのドライブアイコン下のボリューム名部分をクリックして変更
    - Linux - `mlabel`コマンドで変更できますが、Windows/Mac上で行った方が速いと思われます

- EV3に挿入されているSDカードに、[EV3RTのアプリケーションローダがインストールされている](https://dev.toppers.jp/trac_user/ev3pf/wiki/SampleProgram#PC%E3%81%8B%E3%82%89EV3%E3%81%B8%E3%81%AE%E3%82%A2%E3%83%97%E3%83%AA%E3%82%B1%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3%E3%81%AE%E3%83%AD%E3%83%BC%E3%83%89%E6%96%B9%E6%B3%95%E3%81%AE%E9%81%B8%E6%8A%9E)必要があります。

Athrill/ASP3（シミュレータ環境）向けビルドは、同じく`~/etrobo`から動かず`make app=sample_c4 sim up`とすると、起動までしてくれます。これも2回目以降は`make sim up`だけで構いません。

Athrill/ASP3向けも、あえてEV3RT/HRP3向けのビルドも行っています。そもそも自分のソースに問題があるのか、シミュレーション環境が対応していないのか切り分けるためです。EV3RT/HRP3向けのビルドが失敗した場合、Athrill/ASP3向けビルドと実行は行いません。

シミュレータとアプリを別々に起動する場合、`sim`でシミュレータのみ起動、`make sim start`でビルド後にアプリの起動のみを行います。

このように、`~/etrobo`から使用する`make`コマンドには特殊な仕様が仕込まれていますが、それ以外のディレクトリで叩く`make`は通常通り動作します。

## etrobo環境の詳細説明(整備中)

### etrobo環境の無効化/有効化
etrobo環境はログインシェルで起動すると自動的に読み込まれます。しかし、サンドボックスを組んでいるMac版は大丈夫ですが、Windows(WSL)/Linux版では他の用途で利用する時に不都合が生じる可能性も高いので、そのような場合には無効化してください。

$ETROBO_ROOT（通常`~/etrobo`）内に`disable`という名前のファイルがあると、ログインシェル起動時にetrobo環境を読み込みません。`touch $ETROBO_ROOT/disable`などで設定してください。ログインシェルを開きなおす必要があります。

再度有効化するには`rm $ETROBO_ROOT/disable`などしてファイルを削除してください。`startetrobo`の起動でも自動的に有効化されます。

