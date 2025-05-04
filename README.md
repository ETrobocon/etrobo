# etrobo all-in-one installer/builder/launcher environment
基本的には、[ETロボコン](https://etrobo.jp/)のシミュレータ競技向け開発環境です。

see INSTALL that is written by english language

注：ここでは、`startetrobo`によってインストールされるファイル群を「**etroboパッケージ**」、`startetrobo`によって起動する開発環境を「**etrobo環境**」と呼びます。

etrobo環境は、以下のソフトウェアおよび成果物の一部を利用し構成され、etroboパッケージはこれらを自動的に取得しインストールします。
- [ETロボコンシミュレータ](https://etrobo.jp/)
- [TOPPERS/EV3RT for Athrill SPIKE APIバージョン](https://github.com/ETrobocon/raspike-athrill-v850e2m)
- [TOPPERS/EV3RT](https://dev.toppers.jp/trac_user/ev3pf/wiki/WhatsEV3RT)
- [TOPPERS/箱庭](https://toppers.github.io/hakoniwa/)
- [GNU Arm Embedded Toolchain](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm)

インストール方法や環境の解説は[**etroboパッケージのWiki**](https://github.com/ETrobocon/etrobo/wiki)をご覧ください。

インストールがうまくいかなかった場合は、ターミナルのログを添えて [「やばい」ラベルで問題を報告](https://github.com/ETrobocon/etrobo/issues)してください。
特にMac版は環境による差が大きく、あまり広範なテストができていません。お気づきの点があればお気軽にIssueを立ててください。

## 主な特徴

- Visual Studio Code（VSCode）以外のインストールを完全自動化
- Windows/Mac/Linux/ChromeOSで同一の操作による開発を実現
- SPIKEモード（デフォルト）では、RasPike-ART向けETロボコンSPIKE APIのコードをETロボコンシミュレータ向けのAthrill/ASP3にビルド可能
- EV3モードでは、Mindstorms EV3実機向けのEV3RT/HRP3と、ETロボコンシミュレータ向けのAthrill/ASP3が、単一のソースで一度にビルド可能
- NXTモードでは、Mindstorms NXT実機向けnxtOSEKアプリをビルド可能
- USB接続のEV3RT App Loader向けユーティリティおよびNXT拡張ファーム向けアップローダを搭載、ビルド時に自動でプロジェクト名をファイル名として転送可能
- ビルドからシミュレータの実行まで１コマンドで自動処理
- サンプルコースとサンプルコードを同梱

 注：**ここに同梱されているシミュレータは、一般配布用の評価版です**。大会で実際に使用するコースデータやシミュレータには、参加者限定で配布されるものを使用し開発してください。シミュレータの性能や走行体の挙動が異なります。

 同梱されている評価版シミュレータのご利用は、以下の用途に限らせていただきます。

 * ETロボコンへの参加のため
 * ETロボコンへの参加を検討するため
 * ETロボコンの広報
 * ETロボコンに参加、協力していることを広報するため

(ご不明な点は、[ETロボコン 本部事務局](https://www.etrobo.jp/)までお問合せください)

Copyright(C) 2020-2025 ETロボコン実行委員会, All rights reserved.

## 動作環境

### Windows

- x86-64アーキテクチャのCPU
- Windows 11
    - OSビルド26100.2605（December 2024 Update）以降のversion 24H2、または23H2。
        - 2024年12月アップデートより前に手動インストールした24H2ではWSLが破壊され修復不可能であるとの報告もありますのでご注意ください。 
    - Windows 10 Enterprise LTSC 2021での動作確認も行なっていますが、サポート対象外です。
- `wsl --install`によりインストールされたUbuntuまたはUbuntu-24.04(WSL2)
    - インストールにWindowsの管理者権限が必要です。
    - Ubuntu-22.04・20.04・18.04・16.04、Debian(9/10/11/12)でも動作するようですが、サポート対象外です。
    - WSL1での動作も引き続き問題ないと思われますが、サポート対象外です。
- Visual Studio Code(「WSL」拡張機能）のインストール

### Mac
- x86-64アーキテクチャのCPU、またはApple Silicon
    - 動作確認は、以下のMacで行っています：
        - MacBook Air (M1, 2020) 8GB-7GPU / macOS Sequoia 15.4.1 / Xcode CLT 16.3
- macOS Ventura(13.0)以降
    - HomeBrewの動作環境に準じます。これ以前のmacOSでも動作する可能性は高いですが、サポート対象外です。
    - 環境のインストールに管理者権限が必要です。
- Apple Silicon機の場合、Rossetaのインストール
- Xcode(Command Line Tools)のインストール
- Visual Studio Codeのインストール

### Linux
- x86-64アーキテクチャのCPU
- Debian GNU/Linux 12 (bookworm) または Ubuntu 24.04
    - 環境のインストールにsudoers権限が必要です。
    - Debian 11/Ubuntu 22.04以前でも引き続き動作するものと考えていますが、サポート対象外です。
- Visual Studio Codeのインストール

### ChromeOS
- x86-64アーキテクチャのCPU
    - Chrome OSでの動作確認は以下の環境で行っています：
        - ASUS Chromebook C223NA
        - Chrome OS 126.0.6478.222 (Official Build)
        - Debian GNU/Linux 12 (bookworm)
- ChromeOS 102以降
    - 80以降のChromeOS/ChromiumOS/ChromeOS Flexでも動作するものと考えていますがサポート対象外です。
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

デフォルトではSPIKE(RasPike)モードにて動作します。初期ディレクトリで`touch NXT`すると、NXT(nxtOSEK)モードで動作し、`touch EV3`すると、EV3(EV3RT)モードで動作します。
初期ディレクトリ直下の`workspace`シンボリックリンクは、それぞれのモードに応じて適切なworkspaceにリンクを張ります。

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

`make nxt app=helloworld up`とすると、nxtOSEK上でビルドを行い、Mindstorms NXTにバイナリを転送します。

### etrobo環境の無効化/有効化
etrobo環境はログインシェルで起動すると自動的に読み込まれます。しかし、サンドボックスを組んでいるMac版は大丈夫ですが、Windows(WSL)/Linux版では他の用途で利用する時に不都合が生じる可能性も高いので、そのような場合には無効化してください。

$ETROBO_ROOT（通常`~/etrobo`）内に`disable`という名前のファイルがあると、ログインシェル起動時にetrobo環境を読み込みません。`touch $ETROBO_ROOT/disable`などで設定してください。ログインシェルを開きなおす必要があります。

再度有効化するには`rm $ETROBO_ROOT/disable`などしてファイルを削除してください。`startetrobo`の起動でも自動的に有効化されます。

