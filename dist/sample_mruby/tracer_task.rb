class TracerTask

  # 変更不要なパラメーター
  LEFT_COURCE = 1
  RIGHT_COURCE = -1
      
  # 調整が必要なパラメーター
  LIGHT_WHITE = 23        # 白色の光センサ値
  LIGHT_LINE = 0         # ラインの光センサ値
  EDGE = LEFT_COURCE

  def log(msg)
    @logger.write(msg)
  end

  def initialize
    @touch_sensor = EV3RT::TouchSensor.new(EV3RT::PORT_1)
    @color_sensor = EV3RT::ColorSensor.new(EV3RT::PORT_2)
    @sonar_sensor = EV3RT::SonarSensor.new(EV3RT::PORT_3)
      
    @left_motor = EV3RT::Motor.new(EV3RT::PORT_C, EV3RT::LARGE_MOTOR)
    @right_motor = EV3RT::Motor.new(EV3RT::PORT_B, EV3RT::LARGE_MOTOR)
    @steering = EV3RT::Steering.new(@left_motor, @right_motor)

    @logger = EV3RT::Serial.new(EV3RT::SIO_PORT_UART)
    log("tracer task new\r\n")
  end

  def execute

    #走行モータエンコーダリセット
    @steering.reset_motors
    EV3RT::Task.sleep

    while true
  #TODO
  #    if back_button.pressed?
  #        EV3RT::Task.wakeup(EV3RT::MAIN_TASK)
  #        break
  #    end

      # TODO:障害物を検知したら停止
      forward = 30 # 前進命令(実際の走行では状況によって変えるのでここにある)
#      color = @color_sensor.brightness
      color = @color_sensor.rgb_part(EV3RT::ColorSensor::R)
      if color >= (LIGHT_WHITE + LIGHT_LINE) /2
        turn = -80 * EDGE	# 右旋回命令　(右コースは逆)
      else
          turn = 80 * EDGE	# 左旋回命令　(左コースは逆)
      end
    
      # 左右モータでロボットのステアリング操作を行う
      @steering.steer(forward, turn)

      # カラーセンサーで取得した値をターミナルに出力
      # 操作に悪影響しないように、ステアリング操作が終了してからログを出すようにした
      log("color:#{color.to_s}")

      EV3RT::Task.sleep

    end
  end
end

TracerTask.new.execute
