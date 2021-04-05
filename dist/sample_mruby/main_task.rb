# 二輪差動型ライントレースロボットのTOPPERS/HRP3用mrubyサンプルプログラム

class MainTask
  def log(msg)
    @logger.write(msg)
  end

  def initialize
    @leftMotor = EV3RT::Motor.new(EV3RT::PORT_C, EV3RT::LARGE_MOTOR)
    @rightMotor = EV3RT::Motor.new(EV3RT::PORT_B, EV3RT::LARGE_MOTOR)
    @touchSensor = EV3RT::TouchSensor.new(EV3RT::PORT_1)
    @logger = EV3RT::Serial.new(EV3RT::SIO_PORT_UART)
    log("main task new")
  end

  def execute
    # 初期処理だけして寝かす
    EV3RT::Task.active(EV3RT::TRACER_TASK)

    # スタート待機
    while true
      if @touchSensor.pressed?
        log("-- pressed! --")
        break
      end

      EV3RT::Task.sleep(10)
    end	# loop end

    # 周期タスクを開始する
    EV3RT::Task.start_cyclic(EV3RT::CYC_TRACER)

    # 終了指示があるまでおやすみ(終了指示は未実装)
    EV3RT::Task.sleep

    @leftMotor.stop
    @rightMotor.stop
  end
end

MainTask.new.execute
