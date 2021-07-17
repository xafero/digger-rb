class Input
  attr_accessor :dig, :leftpressed, :rightpressed, :uppressed, :downpressed, :f1pressed, :firepressed, :minuspressed, :pluspressed, :f10pressed, :escape, :keypressed, :akeypressed, :dynamicdir, :staticdir, :joyx, :joyy, :joybut1, :joybut2, :keydir, :jleftthresh, :jupthresh, :jrightthresh, :jdownthresh, :joyanax, :joyanay, :firepflag, :joyflag

  def initialize(d)
    @dig = d
    @leftpressed = false
    @rightpressed = false
    @uppressed = false
    @downpressed = false
    @f1pressed = false
    @firepressed = false
    @minuspressed = false
    @pluspressed = false
    @f10pressed = false
    @escape = false
    @keypressed = 0
    @akeypressed = 0
    @dynamicdir = -1
    @staticdir = -1
    @joyx = 0
    @joyy = 0
    @joybut1 = false
    @joybut2 = false
    @keydir = 0
    @jleftthresh = 0
    @jupthresh = 0
    @jrightthresh = 0
    @jdownthresh = 0
    @joyanax = 0
    @joyanay = 0
    @firepflag = false
    @joyflag = false
  end

  def checkkeyb()
    if @pluspressed
      if @dig.frametime > @Digger.MIN_RATE
        @dig.frametime -= 5
      end
    end

    if @minuspressed
      if @dig.frametime < @Digger.MAX_RATE
        @dig.frametime += 5
      end
    end

    if @f10pressed
      @escape = true
    end
  end

  def detectjoy()
    @joyflag = false
    @staticdir = -1
    @dynamicdir = -1
  end

  def getasciikey(make)
    if (make == " ".ord) || ((make >= "a".ord) && (make <= "z".ord)) || ((make >= "0".ord) && (make <= "9".ord))
      make
    else
      0
    end
  end

  def getdir()
    bp2 = @keydir

    bp2
  end

  def initkeyb() end

  def Key_downpressed()
    @downpressed = true
    @dynamicdir = 6
    @staticdir = 6
  end

  def Key_downreleased()
    @downpressed = false
    if @dynamicdir == 6
      self.setdirec()
    end
  end

  def Key_f1pressed()
    @firepressed = true
    @f1pressed = true
  end

  def Key_f1released()
    @f1pressed = false
  end

  def Key_leftpressed()
    @leftpressed = true
    @dynamicdir = 4
    @staticdir = 4
  end

  def Key_leftreleased()
    @leftpressed = false
    if @dynamicdir == 4
      self.setdirec()
    end
  end

  def Key_rightpressed()
    @rightpressed = true
    @dynamicdir = 0
    @staticdir = 0
  end

  def Key_rightreleased()
    @rightpressed = false
    if @dynamicdir == 0
      self.setdirec()
    end
  end

  def Key_uppressed()
    @uppressed = true
    @dynamicdir = 2
    @staticdir = 2
  end

  def Key_upreleased()
    @uppressed = false
    if @dynamicdir == 2
      self.setdirec()
    end
  end

  def processkey(key)
    @keypressed = key
    if key > 0x80
      @akeypressed = key & 0x7f
    end

    case key
    when 0x4b
      self.Key_leftpressed()
    when 0xcb
      self.Key_leftreleased()
    when 0x4d
      self.Key_rightpressed()
    when 0xcd
      self.Key_rightreleased()
    when 0x48
      self.Key_uppressed()
    when 0xc8
      self.Key_upreleased()
    when 0x50
      self.Key_downpressed()
    when 0xd0
      self.Key_downreleased()
    when 0x3b
      self.Key_f1pressed()
    when 0xbb
      self.Key_f1released()
    when 0x78
      @f10pressed = true
    when 0xf8
      @f10pressed = false
    when 0x2b
      @pluspressed = true
    when 0xab
      @pluspressed = false
    when 0x2d
      @minuspressed = true
    when 0xad
      @minuspressed = false
    end
  end

  def readdir()
    @keydir = @staticdir
    if @dynamicdir != -1
      @keydir = @dynamicdir
    end

    @staticdir = -1
    if @f1pressed || @firepressed
      @firepflag = true
    else
      @firepflag = false
    end

    @firepressed = false
  end

  def readjoy() end

  def setdirec()
    @dynamicdir = -1
    if @uppressed
      @dynamicdir = 2
      @staticdir = 2
    end

    if @downpressed
      @dynamicdir = 6
      @staticdir = 6
    end

    if @leftpressed
      @dynamicdir = 4
      @staticdir = 4
    end

    if @rightpressed
      @dynamicdir = 0
      @staticdir = 0
    end
  end

  def teststart()
    startf = false

    if @keypressed != 0 && (@keypressed & 0x80) == 0 && @keypressed != 27
      startf = true
      @joyflag = false
      @keypressed = 0
    end

    if !startf
      return false
    end

    true
  end
end
