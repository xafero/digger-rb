require "./MonsterData"

class Monster
  attr_accessor :dig, :mondat, :nextmonster, :totalmonsters, :maxmononscr, :nextmontime, :mongaptime, :unbonusflag, :mongotgold

  def initialize(d)
    @dig = d
    @mondat = [MonsterData.new, MonsterData.new, MonsterData.new, MonsterData.new, MonsterData.new, MonsterData.new]
    @nextmonster = 0
    @totalmonsters = 0
    @maxmononscr = 0
    @nextmontime = 0
    @mongaptime = 0
    @unbonusflag = false
    @mongotgold = false
  end

  def checkcoincide(mon, bits)
    m = 0
    b = 256
    while m < 6
      if ((bits & b) != 0) && (@mondat[mon].dir == @mondat[m].dir) && (@mondat[m].stime == 0) && (@mondat[mon].stime == 0)
        @mondat[m].dir = @dig.reversedir(@mondat[m].dir)
      end

      m += 1
      b <<= 1
    end
  end

  def checkmonscared(h)
    m = 0
    while m < 6
      if (h == @mondat[m].h) && (@mondat[m].dir == 2)
        @mondat[m].dir = 6
      end

      m += 1
    end
  end

  def createmonster
    i = 0
    while i < 6
      if !@mondat[i].flag
        @mondat[i].flag = true
        @mondat[i].alive = true
        @mondat[i].t = 0
        @mondat[i].nob = true
        @mondat[i].hnt = 0
        @mondat[i].h = 14
        @mondat[i].v = 0
        @mondat[i].x = 292
        @mondat[i].y = 18
        @mondat[i].xr = 0
        @mondat[i].yr = 0
        @mondat[i].dir = 4
        @mondat[i].hdir = 4
        @nextmonster += 1
        @nextmontime = @mongaptime
        @mondat[i].stime = 5
        @dig.Sprite.movedrawspr(i + 8, @mondat[i].x, @mondat[i].y)
        break
      end

      i += 1
    end
  end

  def domonsters
    if @nextmontime > 0
      @nextmontime -= 1
    else
      if @nextmonster < @totalmonsters && nmononscr < @maxmononscr && @dig.digonscr && !@dig.bonusmode
        createmonster
      end

      if @unbonusflag && @nextmonster == @totalmonsters && @nextmontime == 0
        if @dig.digonscr
          @unbonusflag = false
          @dig.createbonus
        end
      end
    end

    i = 0
    while i < 6
      if @mondat[i].flag
        if @mondat[i].hnt > 10 - @dig.Main.levof10
          if @mondat[i].nob
            @mondat[i].nob = false
            @mondat[i].hnt = 0
          end
        end

        if @mondat[i].alive
          if @mondat[i].t == 0
            monai(i)
            if @dig.Main.randno(15 - @dig.Main.levof10) == 0 && @mondat[i].nob
              monai(i)
            end
          else
            @mondat[i].t -= 1
          end
        else
          mondie(i)
        end
      end

      i += 1
    end
  end

  def erasemonsters
    i = 0
    while i < 6
      if @mondat[i].flag
        @dig.Sprite.erasespr(i + 8)
      end

      i += 1
    end
  end

  def fieldclear(dir, x, y)
    case dir
    when 0
      if x < 14
        if (getfield(x + 1, y) & 0x2000) == 0
          if (getfield(x + 1, y) & 1) == 0 || (getfield(x, y) & 0x10) == 0
            return true
          end
        end
      end
    when 4
      if x > 0
        if (getfield(x - 1, y) & 0x2000) == 0
          if (getfield(x - 1, y) & 0x10) == 0 || (getfield(x, y) & 1) == 0
            return true
          end
        end
      end
    when 2
      if y > 0
        if (getfield(x, y - 1) & 0x2000) == 0
          if (getfield(x, y - 1) & 0x800) == 0 || (getfield(x, y) & 0x40) == 0
            return true
          end
        end
      end
    when 6
      if y < 9
        if (getfield(x, y + 1) & 0x2000) == 0
          if (getfield(x, y + 1) & 0x40) == 0 || (getfield(x, y) & 0x800) == 0
            return true
          end
        end
      end
    end

    false
  end

  def getfield(x, y)
    @dig.Drawing.field[y * 15 + x]
  end

  def incmont(n)
    if n > 6
      n = 6
    end

    m = 1
    while m < n
      @mondat[m].t += 1
      m += 1
    end
  end

  def incpenalties(bits)
    m = 0
    b = 256
    while m < 6
      if (bits & b) != 0
        @dig.Main.incpenalty
      end

      b <<= 1

      m += 1
      b <<= 1
    end
  end

  def initmonsters
    i = 0
    while i < 6
      @mondat[i].flag = false
      i += 1
    end

    @nextmonster = 0
    @mongaptime = 45 - (@dig.Main.levof10 << 1)
    @totalmonsters = @dig.Main.levof10 + 5
    case @dig.Main.levof10
    when 1
      @maxmononscr = 3
    when 2, 3, 4, 5, 6, 7
      @maxmononscr = 4
    when 8, 9, 10
      @maxmononscr = 5
    end

    @nextmontime = 10
    @unbonusflag = true
  end

  def killmon(mon)
    if @mondat[mon].flag
      @mondat[mon].flag = false
      @mondat[mon].alive = false
      @dig.Sprite.erasespr(mon + 8)
      if @dig.bonusmode
        @totalmonsters += 1
      end
    end
  end

  def killmonsters(bits)
    n = 0

    m = 0
    b = 256
    while m < 6
      if (bits & b) != 0
        killmon(m)
        n += 1
      end

      m += 1
      b <<= 1
    end

    n
  end

  def monai(mon)
    monox = @mondat[mon].x
    monoy = @mondat[mon].y
    if @mondat[mon].xr == 0 && @mondat[mon].yr == 0
      if @mondat[mon].hnt > 30 + (@dig.Main.levof10 << 1)
        if !@mondat[mon].nob
          @mondat[mon].hnt = 0
          @mondat[mon].nob = true
        end
      end

      if (@dig.diggery - @mondat[mon].y).abs > (@dig.diggerx - @mondat[mon].x).abs
        if @dig.diggery < @mondat[mon].y
          mdirp1 = 2
          mdirp4 = 6
        else
          mdirp1 = 6
          mdirp4 = 2
        end

        if @dig.diggerx < @mondat[mon].x
          mdirp2 = 4
          mdirp3 = 0
        else
          mdirp2 = 0
          mdirp3 = 4
        end
      else
        if @dig.diggerx < @mondat[mon].x
          mdirp1 = 4
          mdirp4 = 0
        else
          mdirp1 = 0
          mdirp4 = 4
        end

        if @dig.diggery < @mondat[mon].y
          mdirp2 = 2
          mdirp3 = 6
        else
          mdirp2 = 6
          mdirp3 = 2
        end
      end

      if @dig.bonusmode
        t = mdirp1
        mdirp1 = mdirp4
        mdirp4 = t
        t = mdirp2
        mdirp2 = mdirp3
        mdirp3 = t
      end

      dir = @dig.reversedir(@mondat[mon].dir)
      if dir == mdirp1
        mdirp1 = mdirp2
        mdirp2 = mdirp3
        mdirp3 = mdirp4
        mdirp4 = dir
      end

      if dir == mdirp2
        mdirp2 = mdirp3
        mdirp3 = mdirp4
        mdirp4 = dir
      end

      if dir == mdirp3
        mdirp3 = mdirp4
        mdirp4 = dir
      end

      if @dig.Main.randno(@dig.Main.levof10 + 5) == 1 && @dig.Main.levof10 < 6
        t = mdirp1
        mdirp1 = mdirp3
        mdirp3 = t
      end

      if fieldclear(mdirp1, @mondat[mon].h, @mondat[mon].v)
        dir = mdirp1
      elsif fieldclear(mdirp2, @mondat[mon].h, @mondat[mon].v)
        dir = mdirp2
      elsif fieldclear(mdirp3, @mondat[mon].h, @mondat[mon].v)
        dir = mdirp3
      elsif fieldclear(mdirp4, @mondat[mon].h, @mondat[mon].v)
        dir = mdirp4
      end

      if !@mondat[mon].nob
        dir = mdirp1
      end

      if @mondat[mon].dir != dir
        @mondat[mon].t += 1
      end

      @mondat[mon].dir = dir
    end

    if (@mondat[mon].x == 292 && @mondat[mon].dir == 0) || (@mondat[mon].x == 12 && @mondat[mon].dir == 4) || (@mondat[mon].y == 180 && @mondat[mon].dir == 6) || (@mondat[mon].y == 18 && @mondat[mon].dir == 2)
      @mondat[mon].dir = -1
    end

    if @mondat[mon].dir == 4 || @mondat[mon].dir == 0
      @mondat[mon].hdir = @mondat[mon].dir
    end

    if !@mondat[mon].nob
      @dig.Drawing.eatfield(@mondat[mon].x, @mondat[mon].y, @mondat[mon].dir)
    end

    case @mondat[mon].dir
    when 0
      if !@mondat[mon].nob
        @dig.Drawing.drawrightblob(@mondat[mon].x, @mondat[mon].y)
      end

      @mondat[mon].x += 4
    when 4
      if !@mondat[mon].nob
        @dig.Drawing.drawleftblob(@mondat[mon].x, @mondat[mon].y)
      end

      @mondat[mon].x -= 4
    when 2
      if !@mondat[mon].nob
        @dig.Drawing.drawtopblob(@mondat[mon].x, @mondat[mon].y)
      end

      @mondat[mon].y -= 3
    when 6
      if !@mondat[mon].nob
        @dig.Drawing.drawbottomblob(@mondat[mon].x, @mondat[mon].y)
      end

      @mondat[mon].y += 3
    end

    if !@mondat[mon].nob
      @dig.hitemerald((@mondat[mon].x - 12) / 20, (@mondat[mon].y - 18) / 18, (@mondat[mon].x - 12) % 20, (@mondat[mon].y - 18) % 18, @mondat[mon].dir)
    end

    if !@dig.digonscr
      @mondat[mon].x = monox
      @mondat[mon].y = monoy
    end

    if @mondat[mon].stime != 0
      @mondat[mon].stime -= 1
      @mondat[mon].x = monox
      @mondat[mon].y = monoy
    end

    if !@mondat[mon].nob && @mondat[mon].hnt < 100
      @mondat[mon].hnt += 1
    end

    push = true
    clbits = @dig.Drawing.drawmon(mon, @mondat[mon].nob, @mondat[mon].hdir, @mondat[mon].x, @mondat[mon].y)
    @dig.Main.incpenalty
    if (clbits & 0x3f00) != 0
      @mondat[mon].t += 1
      checkcoincide(mon, clbits)
      incpenalties(clbits)
    end

    if (clbits & @dig.Bags.bagbits) != 0
      @mondat[mon].t += 1
      @mongotgold = false
      if @mondat[mon].dir == 4 || @mondat[mon].dir == 0
        push = @dig.Bags.pushbags(@mondat[mon].dir, clbits)
        @mondat[mon].t += 1
      elsif !@dig.Bags.pushudbags(clbits)
        push = false
      end

      if @mongotgold
        @mondat[mon].t = 0
      end

      if !@mondat[mon].nob && @mondat[mon].hnt > 1
        @dig.Bags.removebags(clbits)
      end
    end

    if @mondat[mon].nob && ((clbits & 0x3f00) != 0) && @dig.digonscr
      @mondat[mon].hnt += 1
    end

    if !push
      @mondat[mon].x = monox
      @mondat[mon].y = monoy
      @dig.Drawing.drawmon(mon, @mondat[mon].nob, @mondat[mon].hdir, @mondat[mon].x, @mondat[mon].y)
      @dig.Main.incpenalty
      if @mondat[mon].nob
        @mondat[mon].hnt += 1
      end

      if (@mondat[mon].dir == 2 || @mondat[mon].dir == 6) && @mondat[mon].nob
        @mondat[mon].dir = @dig.reversedir(@mondat[mon].dir)
      end
    end

    if ((clbits & 1) != 0) && @dig.digonscr
      if @dig.bonusmode
        killmon(mon)
        @dig.Scores.scoreeatm
        @dig.Sound.soundeatm
      else
        @dig.killdigger(3, 0)
      end
    end

    @mondat[mon].h = (@mondat[mon].x - 12) / 20
    @mondat[mon].v = (@mondat[mon].y - 18) / 18
    @mondat[mon].xr = (@mondat[mon].x - 12) % 20
    @mondat[mon].yr = (@mondat[mon].y - 18) % 18
  end

  def mondie(mon)
    case @mondat[mon].death
    when 1
      if @dig.Bags.bagy(@mondat[mon].bag) + 6 > @mondat[mon].y
        @mondat[mon].y = @dig.Bags.bagy(@mondat[mon].bag)
      end

      @dig.Drawing.drawmondie(mon, @mondat[mon].nob, @mondat[mon].hdir, @mondat[mon].x, @mondat[mon].y)
      @dig.Main.incpenalty
      if @dig.Bags.getbagdir(@mondat[mon].bag) == -1
        @mondat[mon].dtime = 1
        @mondat[mon].death = 4
      end
    when 4
      if @mondat[mon].dtime != 0
        @mondat[mon].dtime -= 1
      else
        killmon(mon)
        @dig.Scores.scorekill
      end
    end
  end

  def mongold
    @mongotgold = true
  end

  def monleft
    nmononscr + @totalmonsters - @nextmonster
  end

  def nmononscr
    n = 0

    i = 0
    while i < 6
      if @mondat[i].flag
        n += 1
      end

      i += 1
    end

    n
  end

  def squashmonster(mon, death, bag)
    @mondat[mon].alive = false
    @mondat[mon].death = death
    @mondat[mon].bag = bag
  end

  def squashmonsters(bag, bits)
    m = 0
    b = 256
    while m < 6
      if (bits & b) != 0
        if @mondat[m].y >= @dig.Bags.bagy(bag)
          squashmonster(m, 1, bag)
        end
      end

      m += 1
      b <<= 1
    end
  end
end
