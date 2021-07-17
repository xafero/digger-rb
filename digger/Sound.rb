class Sound
  attr_accessor :dig, :wavetype, :t2val, :t0val, :musvol, :spkrmode, :timerrate, :timercount, :pulsewidth, :volume, :timerclock, :soundflag, :musicflag, :sndflag, :soundpausedflag, :soundlevdoneflag, :nljpointer, :nljnoteduration, :newlevjingle, :soundfallflag, :soundfallf, :soundfallvalue, :soundfalln, :soundbreakflag, :soundbreakduration, :soundbreakvalue, :soundwobbleflag, :soundwobblen, :soundfireflag, :soundfirevalue, :soundfiren, :soundexplodeflag, :soundexplodevalue, :soundexplodeduration, :soundbonusflag, :soundbonusn, :soundemflag, :soundemeraldflag, :soundemeraldduration, :emerfreq, :soundemeraldn, :soundgoldflag, :soundgoldf, :soundgoldvalue1, :soundgoldvalue2, :soundgoldduration, :soundeatmflag, :soundeatmvalue, :soundeatmduration, :soundeatmn, :soundddieflag, :soundddien, :soundddievalue, :sound1upflag, :sound1upduration, :musicplaying, :musicp, :tuneno, :noteduration, :notevalue, :musicmaxvol, :musicattackrate, :musicsustainlevel, :musicdecayrate, :musicnotewidth, :musicreleaserate, :musicstage, :musicn, :soundt0flag, :int8flag

  def initialize(d)
    @dig = d
    @wavetype = 0
    @t2val = 0
    @t0val = 0
    @musvol = 0
    @spkrmode = 0
    @timerrate = 0x7d0
    @timercount = 0
    @pulsewidth = 1
    @volume = 0
    @timerclock = 0
    @soundflag = true
    @musicflag = true
    @sndflag = false
    @soundpausedflag = false
    @soundlevdoneflag = false
    @nljpointer = 0
    @nljnoteduration = 0
    @newlevjingle = [0x8e8, 0x712, 0x5f2, 0x7f0, 0x6ac, 0x54c, 0x712, 0x5f2, 0x4b8, 0x474, 0x474]
    @soundfallflag = false
    @soundfallf = false
    @soundfallvalue = 0
    @soundfalln = 0
    @soundbreakflag = false
    @soundbreakduration = 0
    @soundbreakvalue = 0
    @soundwobbleflag = false
    @soundwobblen = 0
    @soundfireflag = false
    @soundfirevalue = 0
    @soundfiren = 0
    @soundexplodeflag = false
    @soundexplodevalue = 0
    @soundexplodeduration = 0
    @soundbonusflag = false
    @soundbonusn = 0
    @soundemflag = false
    @soundemeraldflag = false
    @soundemeraldduration = 0
    @emerfreq = 0
    @soundemeraldn = 0
    @soundgoldflag = false
    @soundgoldf = false
    @soundgoldvalue1 = 0
    @soundgoldvalue2 = 0
    @soundgoldduration = 0
    @soundeatmflag = false
    @soundeatmvalue = 0
    @soundeatmduration = 0
    @soundeatmn = 0
    @soundddieflag = false
    @soundddien = 0
    @soundddievalue = 0
    @sound1upflag = false
    @sound1upduration = 0
    @musicplaying = false
    @musicp = 0
    @tuneno = 0
    @noteduration = 0
    @notevalue = 0
    @musicmaxvol = 0
    @musicattackrate = 0
    @musicsustainlevel = 0
    @musicdecayrate = 0
    @musicnotewidth = 0
    @musicreleaserate = 0
    @musicstage = 0
    @musicn = 0
    @soundt0flag = false
    @int8flag = false
  end

  def initsound
    @wavetype = 2
    @t0val = 12000
    @musvol = 8
    @t2val = 40
    @soundt0flag = true
    @sndflag = true
    @spkrmode = 0
    @int8flag = false
    setsoundt2
    soundstop
    startint8
    @timerrate = 0x4000
  end

  def killsound
  end

  def music(tune)
    @tuneno = tune
    @musicp = 0
    @noteduration = 0
    case tune
    when 0
      @musicmaxvol = 50
      @musicattackrate = 20
      @musicsustainlevel = 20
      @musicdecayrate = 10
      @musicreleaserate = 4
    when 1
      @musicmaxvol = 50
      @musicattackrate = 50
      @musicsustainlevel = 8
      @musicdecayrate = 15
      @musicreleaserate = 1
    when 2
      @musicmaxvol = 50
      @musicattackrate = 50
      @musicsustainlevel = 25
      @musicdecayrate = 5
      @musicreleaserate = 1
    end

    @musicplaying = true
    if tune == 2
      soundddieoff
    end
  end

  def musicoff
    @musicplaying = false
    @musicp = 0
  end

  def musicupdate
    if !musicplaying
      return
    end

    if @noteduration != 0
      @noteduration -= 1
    else
      @musicstage = 0
      @musicn = 0
      case @tuneno
      when 0
        @musicnotewidth = @noteduration - 3
        @musicp += 2
      when 1
        @musicnotewidth = 12
        @musicp += 2
      when 2
        @musicnotewidth = @noteduration - 10
        @musicp += 2
      end
    end

    @musicn += 1
    @wavetype = 1
    @t0val = @notevalue
    if @musicn >= @musicnotewidth
      @musicstage = 2
    end

    case @musicstage
    when 0
      if @musvol + @musicattackrate >= @musicmaxvol
        @musicstage = 1
        @musvol = @musicmaxvol
      else
        @musvol += @musicattackrate
      end
    when 1
      if @musvol - @musicdecayrate <= @musicsustainlevel
        @musvol = @musicsustainlevel
      else
        @musvol -= @musicdecayrate
      end
    when 2
      if @musvol - @musicreleaserate <= 1
        @musvol = 1
      else
        @musvol -= @musicreleaserate
      end
    end

    if @musvol == 1
      @t0val = 0x7d00
    end
  end

  def s0fillbuffer
  end

  def s0killsound
    setsoundt2
    stopint8
  end

  def s0setupsound
    startint8
  end

  def setsoundmode
    @spkrmode = @wavetype
    if !soundt0flag && @sndflag
      @soundt0flag = true
    end
  end

  def setsoundt2
    if @soundt0flag
      @spkrmode = 0
      @soundt0flag = false
    end
  end

  def sett0
    if @sndflag
      if @t0val < 1000 && (@wavetype == 1 || @wavetype == 2)
        @t0val = 1000
      end

      @timerrate = @t0val
      if @musvol < 1
        @musvol = 1
      end

      if @musvol > 50
        @musvol = 50
      end

      @pulsewidth = @musvol * @volume
      setsoundmode
    end
  end

  def sett2val(t2v) end

  def setupsound
  end

  def sound1up
    @sound1upduration = 96
    @sound1upflag = true
  end

  def sound1upoff
    @sound1upflag = false
  end

  def sound1upupdate
    if @sound1upflag
      if (@sound1upduration / 3) % 2 != 0
        @t2val = (@sound1upduration << 2) + 600
      end

      @sound1upduration -= 1
      if @sound1upduration < 1
        @sound1upflag = false
      end
    end
  end

  def soundbonus
    @soundbonusflag = true
  end

  def soundbonusoff
    @soundbonusflag = false
    @soundbonusn = 0
  end

  def soundbonusupdate
    if @soundbonusflag
      @soundbonusn += 1
      if @soundbonusn > 15
        @soundbonusn = 0
      end

      if @soundbonusn >= 0 && @soundbonusn < 6
        @t2val = 0x4ce
      end

      if @soundbonusn >= 8 && @soundbonusn < 14
        @t2val = 0x5e9
      end
    end
  end

  def soundbreak
    @soundbreakduration = 3
    if @soundbreakvalue < 15000
      @soundbreakvalue = 15000
    end

    @soundbreakflag = true
  end

  def soundbreakoff
    @soundbreakflag = false
  end

  def soundbreakupdate
    if @soundbreakflag
      if @soundbreakduration != 0
        @soundbreakduration -= 1
        @t2val = @soundbreakvalue
      else
        @soundbreakflag = false
      end
    end
  end

  def soundddie
    @soundddien = 0
    @soundddievalue = 20000
    @soundddieflag = true
  end

  def soundddieoff
    @soundddieflag = false
  end

  def soundddieupdate
    if @soundddieflag
      @soundddien += 1
      if @soundddien == 1
        musicoff
      end

      if @soundddien >= 1 && @soundddien <= 10
        @soundddievalue = 20000 - @soundddien * 1000
      end

      if @soundddien > 10
        @soundddievalue += 500
      end

      if @soundddievalue > 30000
        soundddieoff
      end

      @t2val = @soundddievalue
    end
  end

  def soundeatm
    @soundeatmduration = 20
    @soundeatmn = 3
    @soundeatmvalue = 2000
    @soundeatmflag = true
  end

  def soundeatmoff
    @soundeatmflag = false
  end

  def soundeatmupdate
    if @soundeatmflag
      if @soundeatmn != 0
        if @soundeatmduration != 0
          if (@soundeatmduration % 4) == 1
            @t2val = @soundeatmvalue
          end

          if (@soundeatmduration % 4) == 3
            @t2val = @soundeatmvalue - (@soundeatmvalue >> 4)
          end

          @soundeatmduration -= 1
          @soundeatmvalue -= (@soundeatmvalue >> 4)
        else
          @soundeatmduration = 20
          @soundeatmn -= 1
          @soundeatmvalue = 2000
        end
      else
        @soundeatmflag = false
      end
    end
  end

  def soundem
    @soundemflag = true
  end

  def soundemerald(emocttime)
    if emocttime != 0
      case @emerfreq
      when 0x8e8
        @emerfreq = 0x7f0
      when 0x7f0
        @emerfreq = 0x712
      when 0x712
        @emerfreq = 0x6ac
      when 0x6ac
        @emerfreq = 0x5f2
      when 0x5f2
        @emerfreq = 0x54c
      when 0x54c
        @emerfreq = 0x4b8
      when 0x4b8
        @emerfreq = 0x474
        @dig.Scores.scoreoctave
      when 0x474
        @emerfreq = 0x8e8
      end
    else
      @emerfreq = 0x8e8
    end

    @soundemeraldduration = 7
    @soundemeraldn = 0
    @soundemeraldflag = true
  end

  def soundemeraldoff
    @soundemeraldflag = false
  end

  def soundemeraldupdate
    if @soundemeraldflag
      if @soundemeraldduration != 0
        if @soundemeraldn == 0 || @soundemeraldn == 1
          @t2val = @emerfreq
        end

        @soundemeraldn += 1
        if @soundemeraldn > 7
          @soundemeraldn = 0
          @soundemeraldduration -= 1
        end
      else
        soundemeraldoff
      end
    end
  end

  def soundemoff
    @soundemflag = false
  end

  def soundemupdate
    if @soundemflag
      @t2val = 1000
      soundemoff
    end
  end

  def soundexplode
    @soundexplodevalue = 1500
    @soundexplodeduration = 10
    @soundexplodeflag = true
    soundfireoff
  end

  def soundexplodeoff
    @soundexplodeflag = false
  end

  def soundexplodeupdate
    if @soundexplodeflag
      if @soundexplodeduration != 0
        @soundexplodevalue = @soundexplodevalue - (@soundexplodevalue >> 3)
        @t2val = @soundexplodevalue - (@soundexplodevalue >> 3)
        @soundexplodeduration -= 1
      else
        @soundexplodeflag = false
      end
    end
  end

  def soundfall
    @soundfallvalue = 1000
    @soundfallflag = true
  end

  def soundfalloff
    @soundfallflag = false
    @soundfalln = 0
  end

  def soundfallupdate
    if @soundfallflag
      if @soundfalln < 1
        @soundfalln += 1
        if @soundfallf
          @t2val = @soundfallvalue
        end
      else
        @soundfalln = 0
        if @soundfallf
          @soundfallvalue += 50
          @soundfallf = false
        else
          @soundfallf = true
        end
      end
    end
  end

  def soundfire
    @soundfirevalue = 500
    @soundfireflag = true
  end

  def soundfireoff
    @soundfireflag = false
    @soundfiren = 0
  end

  def soundfireupdate
    if @soundfireflag
      if @soundfiren == 1
        @soundfiren = 0
        @soundfirevalue += @soundfirevalue / 55
        @t2val = @soundfirevalue + @dig.Main.randno(@soundfirevalue >> 3)
        if @soundfirevalue > 30000
          soundfireoff
        end
      else
        @soundfiren += 1
      end
    end
  end

  def soundgold
    @soundgoldvalue1 = 500
    @soundgoldvalue2 = 4000
    @soundgoldduration = 30
    @soundgoldf = false
    @soundgoldflag = true
  end

  def soundgoldoff
    @soundgoldflag = false
  end

  def soundgoldupdate
    if @soundgoldflag
      if @soundgoldduration != 0
        @soundgoldduration -= 1
      else
        @soundgoldflag = false
      end

      if @soundgoldf
        @soundgoldf = false
        @t2val = @soundgoldvalue1
      else
        @soundgoldf = true
        @t2val = @soundgoldvalue2
      end

      @soundgoldvalue1 += (@soundgoldvalue1 >> 4)
      @soundgoldvalue2 -= (@soundgoldvalue2 >> 4)
    end
  end

  def soundint
    @timerclock += 1
    if @soundflag && !sndflag
      @sndflag = true
      @musicflag = true
    end

    if !soundflag && @sndflag
      @sndflag = false
      setsoundt2
    end

    if @sndflag && !soundpausedflag
      @t0val = 0x7d00
      @t2val = 40
      if @musicflag
        musicupdate
      end

      soundemeraldupdate
      soundwobbleupdate
      soundddieupdate
      soundbreakupdate
      soundgoldupdate
      soundemupdate
      soundexplodeupdate
      soundfireupdate
      soundeatmupdate
      soundfallupdate
      sound1upupdate
      soundbonusupdate
      if @t0val == 0x7d00 || @t2val != 40
        setsoundt2
      else
        setsoundmode
        sett0
      end

      sett2val(@t2val)
    end
  end

  def soundlevdone
    SystemX.sleep_ms(1000)
  end

  def soundlevdoneoff
    @soundlevdoneflag = false
    @soundpausedflag = false
  end

  def soundlevdoneupdate
    if @sndflag
      if @nljpointer < 11
        @t2val = @newlevjingle[nljpointer]
      end

      @t0val = @t2val + 35
      @musvol = 50
      setsoundmode
      sett0
      sett2val(@t2val)
      if @nljnoteduration > 0
        @nljnoteduration -= 1
      else
        @nljnoteduration = 20
        @nljpointer += 1
        if @nljpointer > 10
          soundlevdoneoff
        end
      end
    else
      @soundlevdoneflag = false
    end
  end

  def soundoff
  end

  def soundpause
    @soundpausedflag = true
  end

  def soundpauseoff
    @soundpausedflag = false
  end

  def soundstop
    soundfalloff
    soundwobbleoff
    soundfireoff
    musicoff
    soundbonusoff
    soundexplodeoff
    soundbreakoff
    soundemoff
    soundemeraldoff
    soundgoldoff
    soundeatmoff
    soundddieoff
    sound1upoff
  end

  def soundwobble
    @soundwobbleflag = true
  end

  def soundwobbleoff
    @soundwobbleflag = false
    @soundwobblen = 0
  end

  def soundwobbleupdate
    if @soundwobbleflag
      @soundwobblen += 1
      if @soundwobblen > 63
        @soundwobblen = 0
      end

      case @soundwobblen
      when 0
        @t2val = 0x7d0
      when 16, 48
        @t2val = 0x9c4
      when 32
        @t2val = 0xbb8
      end
    end
  end

  def startint8
    if !int8flag
      @timerrate = 0x4000
      @int8flag = true
    end
  end

  def stopint8
    if @int8flag
      @int8flag = false
    end

    sett2val(40)
  end
end
