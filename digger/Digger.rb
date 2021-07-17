require "./Bags"
require "./Main"
require "./Sound"
require "./Monster"
require "./Scores"
require "./Sprite"
require "./Drawing"
require "./Input"
require "./Pc"
require "./Compat"
require "./ColorModel"
require "./SystemX"

class Digger
  @@MAX_RATE = 200
  @@MIN_RATE = 40

  attr_accessor :width, :height, :frametime, :gamethread, :subaddr, :pic, :picg, :Bags, :Main, :Sound, :Monster, :Scores, :Sprite, :Drawing, :Input, :Pc, :diggerx, :diggery, :diggerh, :diggerv, :diggerrx, :diggerry, :digmdir, :digdir, :digtime, :rechargetime, :firex, :firey, :firedir, :expsn, :deathstage, :deathbag, :deathani, :deathtime, :startbonustimeleft, :bonustimeleft, :eatmsc, :emocttime, :emmask, :emfield, :digonscr, :notfiring, :bonusvisible, :bonusmode, :diggervisible, :time, :ftime, :embox, :deatharc

  def initialize(ui_dig)
    @UiDig = ui_dig
    @width = 320
    @height = 200
    @frametime = 66
    @gamethread
    @subaddr = ""
    @Bags = Bags.new(self)
    @Main = Main.new(self)
    @Sound = Sound.new(self)
    @Monster = Monster.new(self)
    @Scores = Scores.new(self)
    @Sprite = Sprite.new(self)
    @Drawing = Drawing.new(self)
    @Input = Input.new(self)
    @Pc = Pc.new(self)
    @diggerx = 0
    @diggery = 0
    @diggerh = 0
    @diggerv = 0
    @diggerrx = 0
    @diggerry = 0
    @digmdir = 0
    @digdir = 0
    @digtime = 0
    @rechargetime = 0
    @firex = 0
    @firey = 0
    @firedir = 0
    @expsn = 0
    @deathstage = 0
    @deathbag = 0
    @deathani = 0
    @deathtime = 0
    @startbonustimeleft = 0
    @bonustimeleft = 0
    @eatmsc = 0
    @emocttime = 0
    @emmask = 0
    @emfield = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    @digonscr = false
    @notfiring = false
    @bonusvisible = false
    @bonusmode = false
    @diggervisible = false
    @time = 0
    @ftime = 50
    @embox = [8, 12, 12, 9, 16, 12, 6, 9]
    @deatharc = [3, 5, 6, 6, 5, 3, 0]
  end

  def checkdiggerunderbag(h, v)
    if @digmdir == 2 || @digmdir == 6
      if (@diggerx - 12) / 20 == h
        if (@diggery - 18) / 18 == v || (@diggery - 18) / 18 + 1 == v
          return true
        end
      end
    end

    false
  end

  def countem
    n = 0

    x = 0
    while x < 15
      y = 0
      while y < 10
        if (@emfield[y * 15 + x] & @emmask) != 0
          n += 1
        end

        y += 1
      end

      x += 1
    end

    n
  end

  def createbonus
    @bonusvisible = true
    @Drawing.drawbonus(292, 18)
  end

  def destroy
    @gamethread&.stop()
  end

  def diggerdie
    case @deathstage
    when 1
      if @Bags.bagy(@deathbag) + 6 > @diggery
        @diggery = @Bags.bagy(@deathbag) + 6
      end

      @Drawing.drawdigger(15, @diggerx, @diggery, false)
      @Main.incpenalty
      if @Bags.getbagdir(@deathbag) + 1 == 0
        @Sound.soundddie
        @deathtime = 5
        @deathstage = 2
        @deathani = 0
        @diggery -= 6
      end
    when 2
      if @deathtime != 0
        @deathtime -= 1
      else
        if @deathani == 0
          @Sound.music(2)
        end

        clbits = @Drawing.drawdigger(14 - @deathani, @diggerx, @diggery, false)
        @Main.incpenalty
        if @deathani == 0 && ((clbits & 0x3f00) != 0)
          @Monster.killmonsters(clbits)
        end

        if @deathani < 4
          @deathani += 1
          @deathtime = 2
        else
          @deathstage = 4
          if @Sound.musicflag
            @deathtime = 60
          else
            @deathtime = 10
          end
        end
      end
    when 3
      @deathstage = 5
      @deathani = 0
      @deathtime = 0
    when 5
      if @deathani >= 0 && @deathani <= 6
        @Drawing.drawdigger(15, @diggerx, @diggery - @deatharc[deathani], false)
        if @deathani == 6
          @Sound.musicoff
        end

        @Main.incpenalty
        @deathani += 1
        if @deathani == 1
          @Sound.soundddie
        end

        if @deathani == 7
          @deathtime = 5
          @deathani = 0
          @deathstage = 2
        end
      end
    when 4
      if @deathtime != 0
        @deathtime -= 1
      else
        @Main.setdead(true)
      end
    end
  end

  def dodigger
    newframe
    if @expsn != 0
      drawexplosion
    else
      updatefire
    end

    if @diggervisible
      if @digonscr
        if @digtime != 0
          @Drawing.drawdigger(@digmdir, @diggerx, @diggery, @notfiring && @rechargetime == 0)
          @Main.incpenalty
          @digtime -= 1
        else
          updatedigger
        end
      else
        diggerdie
      end
    end

    if @bonusmode && @digonscr
      if @bonustimeleft != 0
        @bonustimeleft -= 1
        if @startbonustimeleft != 0 || @bonustimeleft < 20
          @startbonustimeleft -= 1
          if (@bonustimeleft & 1) != 0
            @Pc.ginten(0)
            @Sound.soundbonus
          else
            @Pc.ginten(1)
            @Sound.soundbonus
          end

          if @startbonustimeleft == 0
            @Sound.music(0)
            @Sound.soundbonusoff
            @Pc.ginten(1)
          end
        end
      else
        endbonusmode
        @Sound.soundbonusoff
        @Sound.music(1)
      end
    end

    if @bonusmode && !digonscr
      endbonusmode
      @Sound.soundbonusoff
      @Sound.music(1)
    end

    if @emocttime > 0
      @emocttime -= 1
    end
  end

  def drawemeralds
    @emmask = 1 << @Main.getcplayer
    x = 0
    while x < 15
      y = 0
      while y < 10
        if (@emfield[y * 15 + x] & @emmask) != 0
          @Drawing.drawemerald(x * 20 + 12, y * 18 + 21)
        end

        y += 1
      end

      x += 1
    end
  end

  def drawexplosion
    case @expsn
    when 1, 2, 3
      if expsn == 1
        @Sound.soundexplode
      end
      @Drawing.drawfire(@firex, @firey, @expsn)
      @Main.incpenalty
      @expsn += 1
    else
      killfire
      @expsn = 0
    end
  end

  def endbonusmode
    @bonusmode = false
    @Pc.ginten(0)
  end

  def erasebonus
    if @bonusvisible
      @bonusvisible = false
      @Sprite.erasespr(14)
    end

    @Pc.ginten(0)
  end

  def erasedigger
    @Sprite.erasespr(0)
    @diggervisible = false
  end

  def getAppletInfo
    "The Digger Remastered -- http://www.digger.org, Copyright (c) Andrew Jenner & Marek Futrega / MAF"
  end

  def getfirepflag
    @Input.firepflag
  end

  def hitemerald(x, y, rx, ry, dir)
    hit = false

    if dir < 0 || dir > 6 || ((dir & 1) != 0)
      return hit
    end

    if dir == 0 && rx != 0
      x += 1
    end

    if dir == 6 && ry != 0
      y += 1
    end

    if dir == 0 || dir == 4
      r = rx
    else
      r = ry
    end

    if (@emfield[y * 15 + x] & @emmask) != 0
      if r == @embox[dir]
        @Drawing.drawemerald(x * 20 + 12, y * 18 + 21)
        @Main.incpenalty
      end

      if r == @embox[dir + 1]
        @Drawing.eraseemerald(x * 20 + 12, y * 18 + 21)
        @Main.incpenalty
        hit = true
        @emfield[y * 15 + x] &= ~emmask
      end
    end

    hit
  end

  def init
    @gamethread&.stop()

    @subaddr = Compat.get_submit_parameter
    @frametime = Compat.get_speed_parameter
    if @frametime > @@MAX_RATE
      @frametime = @@MAX_RATE
    elsif @frametime < @@MIN_RATE
      @frametime = @@MIN_RATE
    end

    @Pc.pixels = Array.new(65536) { |i| 0 }
    i = 0

    while i < 2
      model = ColorModel.new(8, 4, @Pc.pal[i][0], @Pc.pal[i][1], @Pc.pal[i][2])
      @Pc.source[i] = @UiDig.create_refresher(model)
      @Pc.source[i].set_animated(true)
      @Pc.source[i].new_pixels_all

      i += 1
    end

    @Pc.currentSource = @Pc.source[0]

    @gamethread = Thread.new { run }
  end

  def initbonusmode
    @bonusmode = true
    erasebonus
    @Pc.ginten(1)
    @bonustimeleft = 250 - @Main.levof10 * 20
    @startbonustimeleft = 20
    @eatmsc = 1
  end

  def initdigger
    @diggerv = 9
    @digmdir = 4
    @diggerh = 7
    @diggerx = @diggerh * 20 + 12
    @digdir = 0
    @diggerrx = 0
    @diggerry = 0
    @digtime = 0
    @digonscr = true
    @deathstage = 1
    @diggervisible = true
    @diggery = @diggerv * 18 + 18
    @Sprite.movedrawspr(0, @diggerx, @diggery)
    @notfiring = true
    @emocttime = 0
    @bonusvisible = false
    @bonusmode = false
    @Input.firepressed = false
    @expsn = 0
    @rechargetime = 0
  end

  def key_down(key)
    case key
    when 1006
      @Input.processkey(0x4b)
    when 1007
      @Input.processkey(0x4d)
    when 1004
      @Input.processkey(0x48)
    when 1005
      @Input.processkey(0x50)
    when 1008
      @Input.processkey(0x3b)
    else
      key &= 0x7f
      if (key >= 65) && (key <= 90)
        key += (97 - 65)
      end

      @Input.processkey(key)
    end

    true
  end

  def key_up(key)
    case key
    when 1006
      @Input.processkey(0xcb)
    when 1007
      @Input.processkey(0xcd)
    when 1004
      @Input.processkey(0xc8)
    when 1005
      @Input.processkey(0xd0)
    when 1008
      @Input.processkey(0xbb)
    else
      key &= 0x7f
      if (key >= 65) && (key <= 90)
        key += (97 - 65)
      end

      @Input.processkey(0x80 | key)
    end

    true
  end

  def killdigger(stage, bag)
    if @deathstage < 2 || @deathstage > 4
      @digonscr = false
      @deathstage = stage
      @deathbag = bag
    end
  end

  def killemerald(x, y)
    if (@emfield[y * 15 + x + 15] & @emmask) != 0
      @emfield[y * 15 + x + 15] &= ~emmask
      @Drawing.eraseemerald(x * 20 + 12, (y + 1) * 18 + 21)
    end
  end

  def killfire
    unless notfiring
      @notfiring = true
      @Sprite.erasespr(15)
      @Sound.soundfireoff
    end
  end

  def makeemfield
    @emmask = 1 << @Main.getcplayer
    x = 0
    while x < 15
      y = 0
      while y < 10
        if @Main.getlevch(x, y, @Main.levplan) == "C"
          @emfield[y * 15 + x] |= @emmask
        else
          @emfield[y * 15 + x] &= ~emmask
        end

        y += 1
      end

      x += 1
    end
  end

  def newframe
    @Input.checkkeyb
    @time += @frametime
    l = @time - @Pc.gethrt

    if l > 0
      SystemX.sleep_ms(l)
    end

    @Pc.currentSource.new_pixels_all
  end

  def paint(g)
    update(g)
  end

  def reversedir(dir)
    case dir
    when 0
      return 4
    when 4
      return 0
    when 2
      return 6
    when 6
      return 2
    end

    dir
  end

  def run
    @Main.main
  end

  def start
    # self.requestFocus()
  end

  def update(g)
    g.drawImage(@Pc.currentImage, 0, 0, self)
  end

  def updatedigger
    push = false

    @Input.readdir
    dir = @Input.getdir
    if dir == 0 || dir == 2 || dir == 4 || dir == 6
      ddir = dir
    else
      ddir = -1
    end

    if @diggerrx == 0 && (ddir == 2 || ddir == 6)
      @digdir = ddir
      @digmdir = ddir
    end

    if @diggerry == 0 && (ddir == 4 || ddir == 0)
      @digdir = ddir
      @digmdir = ddir
    end

    if dir == -1
      @digmdir = -1
    else
      @digmdir = @digdir
    end

    if (@diggerx == 292 && @digmdir == 0) || (@diggerx == 12 && @digmdir == 4) || (@diggery == 180 && @digmdir == 6) || (@diggery == 18 && @digmdir == 2)
      @digmdir = -1
    end

    diggerox = @diggerx
    diggeroy = @diggery
    if @digmdir != -1
      @Drawing.eatfield(diggerox, diggeroy, @digmdir)
    end

    case @digmdir
    when 0
      @Drawing.drawrightblob(@diggerx, @diggery)
      @diggerx += 4
    when 4
      @Drawing.drawleftblob(@diggerx, @diggery)
      @diggerx -= 4
    when 2
      @Drawing.drawtopblob(@diggerx, @diggery)
      @diggery -= 3
    when 6
      @Drawing.drawbottomblob(@diggerx, @diggery)
      @diggery += 3
    end

    if hitemerald((@diggerx - 12) / 20, (@diggery - 18) / 18, (@diggerx - 12) % 20, (@diggery - 18) % 18, @digmdir)
      @Scores.scoreemerald
      @Sound.soundem
      @Sound.soundemerald(@emocttime)
      @emocttime = 9
    end

    clbits = @Drawing.drawdigger(@digdir, @diggerx, @diggery, @notfiring && @rechargetime == 0)
    @Main.incpenalty
    if (@Bags.bagbits & clbits) != 0
      if @digmdir == 0 || @digmdir == 4
        push = @Bags.pushbags(@digmdir, clbits)
        @digtime += 1
      elsif !@Bags.pushudbags(clbits)
        push = false
      end

      if !push
        @diggerx = diggerox
        @diggery = diggeroy
        @Drawing.drawdigger(@digmdir, @diggerx, @diggery, @notfiring && @rechargetime == 0)
        @Main.incpenalty
        @digdir = reversedir(@digmdir)
      end
    end

    if ((clbits & 0x3f00) != 0) && @bonusmode
      nmon = @Monster.killmonsters(clbits)
      while nmon != 0
        @Sound.soundeatm
        @Scores.scoreeatm

        nmon -= 1
      end
    end

    if (clbits & 0x4000) != 0
      @Scores.scorebonus
      initbonusmode
    end

    @diggerh = (@diggerx - 12) / 20
    @diggerrx = (@diggerx - 12) % 20
    @diggerv = (@diggery - 18) / 18
    @diggerry = (@diggery - 18) % 18
  end

  def updatefire
    pix = 0

    if @notfiring
      if @rechargetime != 0
        @rechargetime -= 1
      elsif getfirepflag
        if @digonscr
          @rechargetime = @Main.levof10 * 3 + 60
          @notfiring = false
          case @digdir
          when 0
            @firex = @diggerx + 8
            @firey = @diggery + 4
          when 4
            @firex = @diggerx
            @firey = @diggery + 4
          when 2
            @firex = @diggerx + 4
            @firey = @diggery
          when 6
            @firex = @diggerx + 4
            @firey = @diggery + 8
          end

          @firedir = @digdir
          @Sprite.movedrawspr(15, @firex, @firey)
          @Sound.soundfire
        end
      end
    else
      case @firedir
      when 0
        @firex += 8
        pix = @Pc.ggetpix(@firex, @firey + 4) | @Pc.ggetpix(@firex + 4, @firey + 4)
      when 4
        @firex -= 8
        pix = @Pc.ggetpix(@firex, @firey + 4) | @Pc.ggetpix(@firex + 4, @firey + 4)
      when 2
        @firey -= 7
        pix = (@Pc.ggetpix(@firex + 4, @firey) | @Pc.ggetpix(@firex + 4, @firey + 1) | @Pc.ggetpix(@firex + 4, @firey + 2) | @Pc.ggetpix(@firex + 4, @firey + 3) | @Pc.ggetpix(@firex + 4, @firey + 4) | @Pc.ggetpix(@firex + 4, @firey + 5) | @Pc.ggetpix(@firex + 4, @firey + 6)) & 0xc0
      when 6
        @firey += 7
        pix = (@Pc.ggetpix(@firex, @firey) | @Pc.ggetpix(@firex, @firey + 1) | @Pc.ggetpix(@firex, @firey + 2) | @Pc.ggetpix(@firex, @firey + 3) | @Pc.ggetpix(@firex, @firey + 4) | @Pc.ggetpix(@firex, @firey + 5) | @Pc.ggetpix(@firex, @firey + 6)) & 3
      end

      clbits = @Drawing.drawfire(@firex, @firey, 0)
      @Main.incpenalty
      if (clbits & 0x3f00) != 0
        mon = 0
        b = 256
        while mon < 6
          if (clbits & b) != 0
            @Monster.killmon(mon)
            @Scores.scorekill
            @expsn = 1
          end

          mon += 1
          b <<= 1
        end
      end

      if (clbits & 0x40fe) != 0
        @expsn = 1
      end

      case @firedir
      when 0
        if @firex > 296
          @expsn = 1
        elsif pix != 0 && clbits == 0
          @expsn = 1
          @firex -= 8
          @Drawing.drawfire(@firex, @firey, 0)
        end
      when 4
        if @firex < 16
          @expsn = 1
        elsif pix != 0 && clbits == 0
          @expsn = 1
          @firex += 8
          @Drawing.drawfire(@firex, @firey, 0)
        end
      when 2
        if @firey < 15
          @expsn = 1
        elsif pix != 0 && clbits == 0
          @expsn = 1
          @firey += 7
          @Drawing.drawfire(@firex, @firey, 0)
        end
      when 6
        if @firey > 183
          @expsn = 1
        elsif pix != 0 && clbits == 0
          @expsn = 1
          @firey -= 7
          @Drawing.drawfire(@firex, @firey, 0)
        end
      end
    end
  end
end
