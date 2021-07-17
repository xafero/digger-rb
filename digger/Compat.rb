class Compat
  def self.get_submit_parameter
    ''
  end

  def self.get_speed_parameter
    66
  end

  def create_image(param)
    ;
  end

  def request_focus; end

  def set_focusable(value)
    ;
  end

  def on_key_pressevent(e)
    num = convert_to_legacy(e.Key)
    if num >= 0
      on_key_pressevent(num)
    end
  end

  def on_key_releaseevent(e)
    num = convert_to_legacy(e.Key)
    if num >= 0
      on_key_releaseevent(num)
    end
  end

  def self.convert_to_legacy(net_code)
    switcher = {
      65_362 => 1004, # UP
      65_364 => 1005, # DOWN
      65_361 => 1006, # LEFT
      65_363 => 1007, # RIGHT
      65_470 => 1008, # F1
      65_479 => 1021, # F10
      65_451 => 1031, # PLUS
      65_453 => 1032 # MINUS
    }
    got = switcher[net_code]
    if got.nil?
      net_code
    else
      got
    end
  end
end
