# etrobo all-in-one installer/builder/launcher environment
[ETロボコン](https://etrobo.jp/)のEV3/シミュレータ双方に対応する開発環境です。

注：ここでは、`startetrobo`によってインストールされるファイル群を「**etroboパッケージ**」、`startetrobo`によって起動する開発環境を「**etrobo環境**」と呼びます。

etrobo環境は、以下のソフトウェアおよび成果物の一部を利用し構成され、etroboパッケージはこれらを自動的に取得しインストールします。
- [ETロボコンシミュレータ](https://etrobo.jp/)
- [TOPPERS/EV3RT](https://dev.toppers.jp/trac_user/ev3pf/wiki/WhatsEV3RT)
- [TOPPERS/箱庭](https://toppers.github.io/hakoniwa/)
- [GNU Arm Embedded Toolchain](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm)

インストールがうまくいかなかった場合は、ターミナルのログを添えて [「やばい」ラベルで問題を報告](https://github.com/ETrobocon/etrobo/issues)してください。

## 主な特徴

- Visual Studio Code（VSCode）以外のインストールを完全自動化
- Windows/Mac/Linuxで同一の操作による開発を実現
- Mindstorms EV3実機向けのEV3RT/HRP3と、ETロボコンシミュレータ向けのAthrill/ASP3が、単一のソースで一度にビルド可能
- USB接続のEV3RT App Loader向けユーティリティを搭載、ビルド時に自動でプロジェクト名をファイル名として転送可能
- ビルドからシミュレータの実行まで１コマンドで自動処理
- サンプルコースとサンプルコードを同梱
- Coming soon（シミュレータ向けアプリの実行時にシミュレータの設定を変更可能）

 注：**ここに同梱されているシミュレータは、一般配布用の評価版です**。大会で実際に使用するコースデータやシミュレータには、参加者限定で配布されるものを使用し開発してください。シミュレータの性能や走行体の挙動が異なります。

 同梱されている評価版シミュレータのご利用は、以下の用途に限らせていただきます。

 * ETロボコンへの参加のため
 * ETロボコンへの参加を検討するため
 * ETロボコンの広報
 * ETロボコンに参加、協力していることを広報するため

(ご不明な点は、[ETロボコン 本部事務局](https://www.etrobo.jp/)までお問合せください)

Copyright(C) 2020 ETロボコン実行委員会, All rights reserved.


## 動作環境

### Windows

- x86-64アーキテクチャのCPU
- Windows 10 version 1709 (Fall Creators Update)以降
    - これより前のWindows 10や、Windows 7などでは動作しません。
- Windows Services for Linux (WSL1)のインストール
    - インストールにWindowsの管理者権限が必要です。
    - Virtual Machine Platform (WSL2)には対応していません
- WSL向けUbuntu 18.04のインストール
    - 環境の利用にはsudoers権限が必要です。
    - 16.04でも動作する可能性はありますが、未検証です。
    - 20.04へは近日中に対応します。
- Visual Studio Code(「Remote - WSL」拡張機能）のインストール

### Mac
- x86-64アーキテクチャのCPU
    - 動作確認は、以下のMacで行っています：
        - MacBook Pro (Retina, Mid 2012)
        - macOS Mojave 10.14.6
        - Xcode 11.0
- macOS Mojave(10.14)以降
    - 環境のインストールに管理者権限が必要です。
    - High Sierra(10.13)には今後対応させたいですが、実現可能性も含め未確定です。
- Xcode(Command Line Tools)のインストール
- Visual Studio Codeのインストール

### Linux
- x86-64アーキテクチャのCPU
- Debian GNU/Linux 10 または Ubuntu 18.04
    - 環境のインストールにsudoers権限が必要です。
    - Debian 9/Ubuntu 16.04でも動作する可能性はありますが、未検証です。
    - Ubuntu 20.04へは近日中に対応します。
- Visual Studio Codeのインストール

## etroboパッケージのインストール

各プラットフォームとも、インストールにはsudoers権限が必要です。インストール中にパスワードを聞かれましたら、ログインパスワードを入力してください。

### Windows

[etroboパッケージインストール前の動作環境構築手順](https://github.com/ETrobocon/etroboEV3/wiki/sim_win)で準備します。

`Windows`+`R`キーに続いて`cmd`と入力するなどしてコマンドプロンプトを開き、以下のコマンドをコピー＆ペーストして実行してください。

```
cd Desktop & echo wsl if [ ! -f ~/startetrobo ]; then wget https://raw.githubusercontent.com/ETrobocon/etrobo/master/scripts/startetrobo -O ~/startetrobo; chmod +x ~/startetrobo; fi; ~/startetrobo > "Start ETrobo.cmd"
```

デスクトップに`Start ETrobo.cmd`が作成されるので、それをダブルクリックすると、インストールを開始します。
所要時間は10分程度です。
インストールが完了すると、自動的にetrobo環境を備えたVSCodeが起動します。

インストール後は、同じく`Start ETrobo.cmd`をダブルクリックすることによってetrobo環境を起動できます。

>**非推奨：WSLの動作に不具合がある場合**
>
>上記はWSL上のホームディレクトリにインストーラーが作成されます。ただし、一部のWSL環境では、WSLからWindows実行ファイルを起動できないトラブルが報告されています。
その症状が出た方は以下のコマンドを採用してください。
>
>```
>cd Desktop & echo cd %userprofile%^&wsl if [ ! -f ./startetrobo ]; then wget https://raw.githubusercontent.com/ETrobocon/etrobo/master/scripts/startetrobo -O ./startetrobo; fi; ./startetrobo > "Start ETrobo.cmd"
>```
>ただし、この環境では以下のような制約があります：
>- Athrill仮想Bluetoothを利用できません
>- 今後実装されるシミュレータのコントロールやサーバへの接続など、ネットワークを用いた機能は利用できません

### Mac

[etroboパッケージインストール前の動作環境構築手順](https://github.com/ETrobocon/etroboEV3/wiki/sim_mac)で準備します。

`Finder`の`アプリケーション`から`ユーティリティ`の中にある`ターミナル`を開き、以下のコマンドをコピー＆ペーストして実行してください。

```
cd Desktop; echo 'name=startetrobo_mac.command; if [ ! -f $name ]; then curl -O https://raw.githubusercontent.com/ETrobocon/etrobo/master/scripts/$name; chmod +x ~/$name; fi; ~/$name' > "Start ETrobo.command"; chmod +x "Start ETrobo.command"

```
デスクトップに`Start ETrobo.command`が作成されるので、それをダブルクリックすると、インストールを開始します。
所要時間は1時間程度です。
インストールが完了すると、自動的にetrobo環境を備えたVSCodeが起動します。

インストール後は、同じく`Start ETrobo.command`をダブルクリックすることによってetrobo環境を起動できます。

### Linux

まず、VSCodeがインストールされている必要があります。

その後、`Ctrl`+`Alt`+`T`キーでターミナルを開き、以下のコマンドをコピペして実行してください。

```
wget https://raw.githubusercontent.com/ETrobocon/etrobo/master/scripts/startetrobo -O ~/startetrobo; chmod +x ~/startetrobo; ~/startetrobo

```

ターミナル上でインストールが開始されます。
所要時間は10分程度です。
インストールが完了すると、自動的にetrobo環境を備えたVSCodeが起動します。

インストール後は、ターミナルから`./startetrobo`でetrobo環境を起動できます。

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

Athrill/ASP3（シミュレータ環境）向けビルドは、同じく`~/etrobo`から動かず`make app=sample_c4 sim up`とすると、起動までしてくれます。これも2回目以降は`make sim up`だけで構いません。

Athrill/ASP3向けも、あえてEV3RT/HRP3向けのビルドも行っています。そもそも自分のソースに問題があるのか、シミュレーション環境が対応していないのか切り分けるためです。EV3RT/HRP3向けのビルドが失敗した場合、Athrill/ASP3向けビルドと実行は行いません。

シミュレータとアプリを別々に起動する場合、`sim`でシミュレータのみ起動、`make sim start`でビルド後にアプリの起動のみを行います。
- 現在Linux版には不具合があり、ターミナルを分割して上記の手法で起動する必要があります。

このように、`~/etrobo`から使用する`make`コマンドには特殊な仕様が仕込まれていますが、それ以外のディレクトリで叩く`make`は通常通り動作します。

## etroboパッケージのバージョンアップ

etrobo環境のターミナルで、etrobo環境ディレクトリから`update`コマンドを実行します。

大抵これで大丈夫ですが、アップデートされていないと思った場合は再度`update`コマンドを実行してから、etrobo環境（VSCode）を閉じ、再度etrobo環境を起動してください。

## etroboパッケージのアンインストール/再インストール

### Windows/Linux

etrobo環境（VSCode）を閉じ、（Ubuntu）ターミナルを開いて`./startetrobo clean`を実行します。

再インストールは、アンインストールしてから、再び上記のインストールコマンドを実行します。

### Mac

Macでは、etroboパッケージのみ再インストールする場合と、BeerHallツールチェーンサンドボックスも含めた全体をアンインストール/再インストールする場合で操作が異なります。

#### etroboパッケージのみを再インストール
まず、上記「etroboパッケージのバージョンアップ」の手順に従い`update`します。

etrobo環境を（VSCode）を閉じ、ターミナルを開いて、以下のコマンドを順に実行します。
```
cd "$BEERHALL"
./BeerHall "./startetrobo clean"
exit
```
その後、`Command`+`W`キーで一度ターミナルを閉じ、再度新規ターミナルウィンドウを開いて、以下のコマンドを実行します。
```
cd "$BEERHALL"
./BeerHall "./startetrobo"
```

#### BeerHallも含めた全体のアンインストール/再インストール
etrobo環境を（VSCode）を閉じ、ターミナルを開いて、以下のコマンドを順に実行します。
```
.startetrobo_mac.command clean
exit
```
その後、`Command`+`W`キーでターミナルを閉じます。

再インストールするには、再び上記のインストールコマンドを実行します。

## etrobo環境の詳細説明(整備中)

### etrobo環境の無効化/有効化
etrobo環境はログインシェルで起動すると自動的に読み込まれます。しかし、他の用途で利用する時には不都合が生じる可能性も高いので、そのような場合には無効化してください。

$ETROBO_ROOT（通常`~/etrobo`）内に`disable`という名前のファイルがあると、ログインシェル起動時にetrobo環境を読み込みません。`touch $ETROBO_ROOT/disable`などで設定してください。ログインシェルを開きなおす必要があります。

再度有効化するには`rm $ETROBO_ROOT/disable`などしてファイルを削除してください。`startetrobo`の起動でも自動的に有効化されます。

### startetrobo
インストーラー兼開発環境起動スクリプトです。`Start ETrobo.*`をダブルクリックすることにより呼び出されます。ターミナルから直接実行する際には、必ずインストールディレクトリの親（通常`~`または`/mnt/c/Users/ユーザ名`)から実行してください（`update`オプションを除く）。

- **startetrobo**

    環境がインストールされていない場合は、インストールします。インストールされている場合は、VSCodeが起動します。

    このスクリプトが置かれているディレクトリに`etrobo`ディレクトリを作成してそこにインストールします。既に`etrobo`ディレクトリがある場合は対処してからインストールしてください。

- **startetrobo shell**
    
    上記と同じですが、VSCodeは起動せず、呼び出したターミナルでそのまま利用します。VSCodeが嫌いな方向け。

- **startetrobo update**

    etroboパッケージ内にある`startetrobo`で、ユーザーホームディレクトリの`startetrobo`を更新します。これだけはetrobo環境で実行してください。

- **. startetrobo unset**

    実行中のシェルインスタンスでetrobo環境を一次的に無効化します。

- **. startetrobo shell**

    実行中のシェルインスタンスで一次的に無効化したetrobo環境を有効化します。

- **startetrobo clean**

    インストールされているetroboパッケージを削除します。
    ネイティブUbuntuの場合は再起動する必要があります。

- **startetrobo deep clean**

    etroboパッケージによってインストールされたファイルを完全に削除します。
    これにはEV3RTの公式インストーラの内容も含まれますので、十分注意してください。
    ネイティブUbuntuの場合は再起動する必要があります。
