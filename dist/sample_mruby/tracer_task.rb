class TracerTask

  LEFT_COURCE = 1
  RIGHT_COURCE = -1

  def log(msg)
    @logger.write(msg)
  end

  def initialize
    @touch_sensor = EV3RT::TouchSensor.new(EV3RT::PORT_1)
    @color_sensor = EV3RT::ColorSensor.new(EV3RT::PORT_2)
    @left_motor = EV3RT::Motor.new(EV3RT::PORT_C, EV3RT::LARGE_MOTOR)
    @right_motor = EV3RT::Motor.new(EV3RT::PORT_B, EV3RT::LARGE_MOTOR)
    @logger = EV3RT::Serial.new(EV3RT::SIO_PORT_UART)
    log("tracer task new")
  end

  def execute

    #走行モータエンコーダリセット
    @left_motor.reset
    @right_motor.reset
    edge = LEFT_COURCE  # 左右どちらのコースを走行するかの指定
    EV3RT::Task.sleep

    while true
      # 物体の「前進量」と「回転量」の関係で各モーターの出力量が決まる
      #   Motor#power=に与える値が-100~100の範囲である必要があります
      forward = 25    # 前進量(-100~100で指定)
      turn = 8        # 回転量(-100~100で指定)
      threshold = 40  # ライン上かどうか判定する閾値
#      color = @color_sensor.brightness # （参考）こちらを使う方法もあります
      color = @color_sensor.rgb_part(EV3RT::ColorSensor::R) # 赤色成分で黒線を判断している
      if color >= threshold
        left_power = forward - turn * edge
        right_power = forward + turn * edge
      else
        left_power = forward + turn * edge
        right_power = forward - turn * edge
      end
    
      # 左右モータでロボットのステアリング操作を行う
      @left_motor.power = left_power
      @right_motor.power = right_power

      # カラーセンサーで取得した値をターミナルに出力
      # 操作に悪影響しないように、ステアリング操作が終了してからログを出すようにした
      # 実機と違い、ログを出すと走行に影響を及ぼす可能性が高い為コメントアウトしている
      # log("color:#{color.to_s}, left:#{left_power.to_s}, right:#{right_power.to_s}")
      # log("c:#{color.to_s}, l:#{left_power.to_s}")
      # log("c:#{color.to_s}")

      # 周期ハンドラからwakeupされるのを待つ
      EV3RT::Task.sleep
    end
  end
end

TracerTask.new.execute
