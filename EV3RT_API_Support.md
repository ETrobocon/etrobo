# ETRoboシミュレータにおけるEV3RTのAPI対応

## Summary
2020/6/29時点でのetrobo環境におけるEV3RTのAPIサポートは以下のようになっています。

| 機能      | サブ機能  | 対応状況   | 備考     |
|:--------:|:--------:|:--------:|:--------|
| EV3本体機能| バッテリ  | ○        | 常に固定の値が返されます |
|           | 本体ボタン | ○       | シミュレータ上の本体ボタンクリックに対応しています|
|           | LEDライト| ○         | シミュレータ上の本体のLEDの色が変わります|
|           | スピーカー | △       | 呼んでも機能せず、ただE_OKを返します|
|           |ファイルシステム| ○     | 仮想のファイルシステムにアクセスできます。``ファイルシステム``に関する説明を参照してください|
|           | LCD      | △        | 呼んでも機能せず、ただE_OKを返します|
| シリアル    | BT       | △        | Bluetooth(R)での通信は対応していませんが、PIPEを使用したやりとりが可能です。詳細は``Bluetooth通信``を参照してください|
| モーター    | -        | ○ *      | ev3_motor_rotate()は機能しません（E_OKは返る)。ev3_motor_steer()の挙動も異なるため、使用は推奨されません|
| センサ      | 超音波センサ | ○      |            |
|            | タッチセンサ | ○      | 通信接続時に``Enterキー``がタッチセンサーの代わりとなります|
|            | ジャイロセンサ | ○     |            |
|            | カラーセンサ | ○      |             |

## バッテリ

- ev3_battery_current_mA()
- ev3_battery_voltage_mV()

シミュレータ上の走行体は電池の消耗という概念がないため、常に同じ値を返します。

## 本体ボタン

- ev3_button_is_pressed()
- ev3_button_set_on_clicked()

画面で表示されるロボットの本体ボタンをマウスでクリックすることで反応します。

## LCD

- ev3_font_get_size()
- ev3_image_free()
- ev3_image_load()
- ev3_lcd_draw_image()
- ev3_lcd_draw_line()
- ev3_lcd_draw_string()
- ev3_lcd_fill_rect()
- ev3_lcd_set_font()

APIとしては存在しますが、機能的には未実装です。常にE_OKを返します。


## LED

- ev3_led_set_color()

シミュレータ上のロボットの色が変わります。

## スピーカ

- ev3_speaker_play_file()
- ev3_speaker_play_tone()
- ev3_speaker_set_volume()
- ev3_speaker_stop()

APIとしては存在しますが、機能的には未実装です。常にE_OKを返します。

## ファイルシステム

EV3のファイルシステムはSDカードへの書き込みを提供しています。
シミュレータ環境ではホスト環境での仮想のファイルシステムを提供しています。

アプリケーションプログラムから``fopen("test.txt","rw")``とした場合、実機でSDカードのトップディレクトリに書き込まれますが、シミュレータの仮想システムではプログラムを実行したディレクトリに``__ev3rtfs``というディレクトリを作成し、そのディレクトリをトップディレクトリとしたファイルを作成します。つまり、``__ev3rtfs/test.txt``というファイルができることになります。
逆に``__ev3rtfs``の下にファイルを置くことで、EV3RTのプログラムからアクセスさせることもできます。
``__ev3rtfs``という名前は``sdk/common/device_config.txt``の``DEVICE_CONFIG_VIRTFS_TOP``に指定している値で変更できます。ただし、試走会や大会では標準の値（``__ev3rtfs``）を使用するため、変更しない方が良いでしょう。

libc(実際はnewlib)で提供している``open``,``read``,``write``,``close``、``scanf``,および``fopen``,``fread``,``fwrite``,``fclose``,``fprintf``,``fscanf``なども対応しています。

EV3固有で提供しているAPIの対応は以下です。

- ev3_bluetooth_is_connected() : 常にtrueを返します。
- ev3_memfile_load() : 仮想ファイルシステムへのアクセスを行います
- ev3_memfile_free() : 対応しています
- ev3_sdcard_opendir(): 対応しています。仮想ファイルシステムのディレクトリのオープンを行います。
- ev3_sdcard_readdir(): 対応しています。
- ev3_sdcard_closedir():対応しています。
- ev3_serial_open_file(): Bluetoothの章を参照してください
- ev3_spp_master_connect(): 対応していません
- ev3_spp_master_is_connected(): 対応していません
- ev3_spp_master_reset(): 対応していません

## Bluetooth

シミュレータ環境ではBluetooth自体の対応はしていませんが、API上Bluetooth APIを通じてホストコンピュータ側との通信が可能です。
``ev3_serial_open_file()``でBluetoothを指定した場合、その後の``fread()``,``fwrite()``はホスト側への仮想通信路として2つのPIPEを使用します。
``__ev3rt_bt_out``が出力用、``__ev3rt_bt_in``が入力用となります。

EV3RTのプログラム側で
```
  FILE *bt = ev3_serial_open_file(EV3_SERIAL_BT);
  int c;
  while(1) {
    c = fgetc(bt);
    tslp_tsk(1000000);
    fprintf(bt, "Input was=%d\n",c);
  }
```

のようにすると、実行したディレクトリで以下のように``__ev3rt_bt_in``PIPEに書き込みを行うと``fgetc()``などで読み込みを行うことができます。

``echo "test" > __ev3rt_bt_in``

逆に、出力に関しては

``cat __ev3rt_bt_out``

とすると``fwrite()``などで書き込んだデータが出力できます。
``asp``を起動した後で別なコマンドウィンドウから
``cat __ev3rt_bt_out &``
とすると、出力を常に出すことができます。

毎回上記のコマンドを実行するのが面倒な場合はプロジェクトのMakefile.inc内の``ADDITIONAL_PRE_APPL``に記述したコマンドを自動的に実行させることができます。
``ADDITIONAL_PRE_APPL=cat __ev3rt_bt_out &``
と書くと、make sim upなどで実行するとアプリケーションを起動する前に``cat``コマンドがバックグラウンドで実行されます。
この仕組みはログなどをとるために使用することを想定しています。
大会・試走会では実行委員会側で``cat``コマンドでのログをとることだけを想定していますので、事前のコマンドを実行することを前提とした走行にならない要注意してください。

## モーター

注釈のないものは対応しています。
- ev3_motor_config()
- ev3_motor_get_counts()
- ev3_motor_get_power()
- ev3_motor_get_type() :  ev3_motor_config()で設定したものが取得できます。
- ev3_motor_reset_counts()
- ev3_motor_rotate() : 対応していません。使用しないでください。
- ev3_motor_set_power()
- ev3_motor_steer() : 対応はしていますが、実機との実現方法が異なるのと、細かい制御ができないため、使用しない方が良いでしょう。
- ev3_motor_stop()

## センサ

## センサの設定

センサの設定には対応しています。使用する前に設定を行う必要があります（実機と同じ)
- ev3_sensor_config()
- ev3_sensor_get_type(): ev3_sensor_config()で設定した値が取れます。


### カラーセンサ

注釈のないものは対応しています。
- ev3_color_sensor_get_ambient() : 対応はしていますが、使用は推奨されません
- ev3_color_sensor_get_color()
- ev3_color_sensor_get_reflect
- ev3_color_sensor_get_rgb_raw

カラーセンサはシミュレータではUnity上のカメラを使用して取得した画像から返す値を判定しています。そのため、画像切り替えの解像度(fps)が低い場合には精度が低くなります。そのため、ETロボコンの正式な動作環境は60fps固定モード（つまりシミュレータ時間に対して実時間が長くなる）を使用し、大会や試走会も60fps固定で走行させます。fps可変モードではCPUの性能によってカラーセンサの性能が大きく異なる場合がありますので、注意してください。

### ジャイロセンサ

ジャイロのAPIには対応しています。
- ev3_gyro_sensor_get_angle()
- ev3_gyro_sensor_get_rate()
- ev3_gyro_sensor_reset()

### 赤外線センサ

ETロボコンでは使用しないため、赤外線センサには**対応していません**。
- ev3_infrared_sensor_get_distance():非対応
- ev3_infrared_sensor_get_remote():非対応
- ev3_infrared_sensor_seek():非対応


### タッチセンサ

タッチセンサに対応しています。キーボードの``enterキー``を押すことで、反応します。
- ev3_touch_sensor_is_pressed()

### 超音波センサ

- ev3_ultrasonic_sensor_get_distance():対応しています。
- ev3_ultrasonic_sensor_listen()：対応していません。

### その他センサ

ETロボコンでは使用しないため、下記のAPIには**対応していません**。
- ht_nxt_accel_sensor_measure
- ht_nxt_color_sensor_measure_color
- ht_nxt_color_sensor_measure_rgb
- nxt_temp_sensor_measure
