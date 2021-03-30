# 二輪差動型ライントレースロボットのTOPPERS/HRP3用mrubyサンプルプログラム

class MainTask
  # TODO
  # Bluetoothが有効かどうかの設定（現状：無効）
  # シミュレーターかどうかの設定（現状：yes）
  # コースの左右の設定（現状：左、右エッジをトレース）

  CMD_START = 1           # スタートコマンド

  def log(msg)
    @logger.write(msg)
  end

  def initialize
    @leftMotor = EV3RT::Motor.new(EV3RT::PORT_C, EV3RT::LARGE_MOTOR)
    @rightMotor = EV3RT::Motor.new(EV3RT::PORT_B, EV3RT::LARGE_MOTOR)

    @logger = EV3RT::Serial.new(EV3RT::SIO_PORT_UART)
    msg = "main task new\r\n"
    log(msg)
  end

  def execute
    # 初期処理だけして寝かす
    EV3RT::Task.active(EV3RT::TRACER_TASK)
    EV3RT::Task.start_cyclic(EV3RT::CYC_TRACER)

    # back ボタンで終了指示があるまでおやすみ
    EV3RT::Task.sleep

    @leftMotor.stop
    @rightMotor.stop
  end
end

MainTask.new.execute
