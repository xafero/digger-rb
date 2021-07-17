require "./BagData"

class Bags
  attr_accessor :dig, :bagdat1, :bagdat2, :bagdat, :pushcount, :goldtime, :wblanim

  def initialize(d)
    @dig = d
    @bagdat1 = [BagData.new, BagData.new, BagData.new, BagData.new, BagData.new, BagData.new, BagData.new, BagData.new]
    @bagdat2 = [BagData.new, BagData.new, BagData.new, BagData.new, BagData.new, BagData.new, BagData.new, BagData.new]
    @bagdat = [BagData.new, BagData.new, BagData.new, BagData.new, BagData.new, BagData.new, BagData.new, BagData.new]
    @pushcount = 0
    @goldtime = 0
    @wblanim = [2, 0, 1, 0]
  end

  def bagbits
    bags = 0

    bag = 1
    b = 2
    while bag < 8
      if @bagdat[bag].exist
        bags |= b
      end

      bag += 1
      b <<= 1
    end

    bags
  end

  def baghitground(bag)
    if @bagdat[bag].dir == 6 && @bagdat[bag].fallh > 1
      @bagdat[bag].gt = 1
    else
      @bagdat[bag].fallh = 0
    end

    @bagdat[bag].dir = -1
    @bagdat[bag].wt = 15
    @bagdat[bag].wobbling = false
    clbits = @dig.Drawing.drawgold(bag, 0, @bagdat[bag].x, @bagdat[bag].y)
    @dig.Main.incpenalty()
    bn = 1
    b = 2
    while bn < 8
      if (b & clbits) != 0
        removebag(bn)
      end

      bn += 1
      b <<= 1
    end
  end

  def bagy(bag)
    @bagdat[bag].y
  end

  def cleanupbags
    @dig.Sound.soundfalloff()
    bpa = 1
    while bpa < 8
      if @bagdat[bpa].exist && ((@bagdat[bpa].h == 7 && @bagdat[bpa].v == 9) || @bagdat[bpa].xr != 0 || @bagdat[bpa].yr != 0 || @bagdat[bpa].gt != 0 || @bagdat[bpa].fallh != 0 || @bagdat[bpa].wobbling)
        @bagdat[bpa].exist = false
        @dig.Sprite.erasespr(bpa)
      end

      if @dig.Main.getcplayer() == 0
        @bagdat1[bpa].copy_from(@bagdat[bpa])
      else
        @bagdat2[bpa].copy_from(@bagdat[bpa])
      end

      bpa += 1
    end
  end

  def dobags
    soundfalloffflag = true
    soundwobbleoffflag = true

    bag = 1
    while bag < 8
      if @bagdat[bag].exist
        if @bagdat[bag].gt != 0
          if @bagdat[bag].gt == 1
            @dig.Sound.soundbreak()
            @dig.Drawing.drawgold(bag, 4, @bagdat[bag].x, @bagdat[bag].y)
            @dig.Main.incpenalty()
          end

          if @bagdat[bag].gt == 3
            @dig.Drawing.drawgold(bag, 5, @bagdat[bag].x, @bagdat[bag].y)
            @dig.Main.incpenalty()
          end

          if @bagdat[bag].gt == 5
            @dig.Drawing.drawgold(bag, 6, @bagdat[bag].x, @bagdat[bag].y)
            @dig.Main.incpenalty()
          end

          @bagdat[bag].gt += 1
          if @bagdat[bag].gt == @goldtime
            removebag(bag)
          elsif @bagdat[bag].v < 9 && @bagdat[bag].gt < @goldtime - 10
            if (@dig.Monster.getfield(@bagdat[bag].h, @bagdat[bag].v + 1) & 0x2000) == 0
              @bagdat[bag].gt = @goldtime - 10
            end
          end
        else
          updatebag(bag)
        end
      end

      bag += 1
    end

    bag = 1
    while bag < 8
      if @bagdat[bag].dir == 6 && @bagdat[bag].exist
        soundfalloffflag = false
      end

      if @bagdat[bag].dir != 6 && @bagdat[bag].wobbling && @bagdat[bag].exist
        soundwobbleoffflag = false
      end

      bag += 1
    end

    if soundfalloffflag
      @dig.Sound.soundfalloff()
    end

    if soundwobbleoffflag
      @dig.Sound.soundwobbleoff()
    end
  end

  def drawbags
    bag = 1
    while bag < 8
      if @dig.Main.getcplayer() == 0
        @bagdat[bag].copy_from(@bagdat1[bag])
      else
        @bagdat[bag].copy_from(@bagdat2[bag])
      end

      if @bagdat[bag].exist
        @dig.Sprite.movedrawspr(bag, @bagdat[bag].x, @bagdat[bag].y)
      end

      bag += 1
    end
  end

  def getbagdir(bag)
    if @bagdat[bag].exist
      return @bagdat[bag].dir
    end

    -1
  end

  def getgold(bag)
    clbits = @dig.Drawing.drawgold(bag, 6, @bagdat[bag].x, @bagdat[bag].y)
    @dig.Main.incpenalty()
    if (clbits & 1) != 0
      @dig.Scores.scoregold()
      @dig.Sound.soundgold()
      @dig.digtime = 0
    else
      @dig.Monster.mongold()
    end

    removebag(bag)
  end

  def getnmovingbags
    n = 0

    bag = 1
    while bag < 8
      if @bagdat[bag].exist && @bagdat[bag].gt < 10 && (@bagdat[bag].gt != 0 || @bagdat[bag].wobbling)
        n += 1
      end

      bag += 1
    end

    n
  end

  def initbags
    @pushcount = 0
    @goldtime = 150 - @dig.Main.levof10() * 10
    bag = 1
    while bag < 8
      @bagdat[bag].exist = false
      bag += 1
    end

    bag = 1
    x = 0
    while x < 15
      y = 0
      while y < 10
        if @dig.Main.getlevch(x, y, @dig.Main.levplan()) == "B"
          if bag < 8
            @bagdat[bag].exist = true
            @bagdat[bag].gt = 0
            @bagdat[bag].fallh = 0
            @bagdat[bag].dir = -1
            @bagdat[bag].wobbling = false
            @bagdat[bag].wt = 15
            @bagdat[bag].unfallen = true
            @bagdat[bag].x = x * 20 + 12
            @bagdat[bag].y = y * 18 + 18
            @bagdat[bag].h = x
            @bagdat[bag].v = y
            @bagdat[bag].xr = 0
            @bagdat[bag].yr = 0
            bag += 1
          end
        end

        y += 1
      end

      x += 1
    end

    if @dig.Main.getcplayer() == 0
      i = 1

      while i < 8
        @bagdat1[i].copy_from(@bagdat[i])
        i += 1
      end
    else
      i = 1

      while i < 8
        @bagdat2[i].copy_from(@bagdat[i])
        i += 1
      end
    end
  end

  def pushbag(bag, dir)
    push = true

    ox = @bagdat[bag].x
    x = @bagdat[bag].x
    oy = @bagdat[bag].y
    y = @bagdat[bag].y
    h = @bagdat[bag].h
    v = @bagdat[bag].v
    if @bagdat[bag].gt != 0
      getgold(bag)
      return true
    end

    if @bagdat[bag].dir == 6 && (dir == 4 || dir == 0)
      clbits = @dig.Drawing.drawgold(bag, 3, x, y)
      @dig.Main.incpenalty()
      if ((clbits & 1) != 0) && (@dig.diggery >= y)
        @dig.killdigger(1, bag)
      end

      if (clbits & 0x3f00) != 0
        @dig.Monster.squashmonsters(bag, clbits)
      end

      return true
    end

    if (x == 292 && dir == 0) || (x == 12 && dir == 4) || (y == 180 && dir == 6) || (y == 18 && dir == 2)
      push = false
    end

    if push
      case dir
      when 0
        x += 4
      when 4
        x -= 4
      when 6
        if @bagdat[bag].unfallen
          @bagdat[bag].unfallen = false
          @dig.Drawing.drawsquareblob(x, y)
          @dig.Drawing.drawtopblob(x, y + 21)
        else
          @dig.Drawing.drawfurryblob(x, y)
        end

        @dig.Drawing.eatfield(x, y, dir)
        @dig.killemerald(h, v)
        y += 6
      end

      case dir
      when 6
        clbits = @dig.Drawing.drawgold(bag, 3, x, y)
        @dig.Main.incpenalty()
        if ((clbits & 1) != 0) && @dig.diggery >= y
          @dig.killdigger(1, bag)
        end

        if (clbits & 0x3f00) != 0
          @dig.Monster.squashmonsters(bag, clbits)
        end
      when 0, 4
        @bagdat[bag].wt = 15
        @bagdat[bag].wobbling = false
        clbits = @dig.Drawing.drawgold(bag, 0, x, y)
        @dig.Main.incpenalty()
        @pushcount = 1
        if (clbits & 0xfe) != 0
          if !pushbags(dir, clbits)
            x = ox
            y = oy
            @dig.Drawing.drawgold(bag, 0, ox, oy)
            @dig.Main.incpenalty()
            push = false
          end
        end

        if ((clbits & 1) != 0) || ((clbits & 0x3f00) != 0)
          x = ox
          y = oy
          @dig.Drawing.drawgold(bag, 0, ox, oy)
          @dig.Main.incpenalty()
          push = false
        end
      end

      if push
        @bagdat[bag].dir = dir
      else
        @bagdat[bag].dir = @dig.reversedir(dir)
      end

      @bagdat[bag].x = x
      @bagdat[bag].y = y
      @bagdat[bag].h = (x - 12) / 20
      @bagdat[bag].v = (y - 18) / 18
      @bagdat[bag].xr = (x - 12) % 20
      @bagdat[bag].yr = (y - 18) % 18
    end

    push
  end

  def pushbags(dir, bits)
    push = true

    bag = 1
    bit = 2
    while bag < 8
      if (bits & bit) != 0
        if !pushbag(bag, dir)
          push = false
        end
      end

      bag += 1
      bit <<= 1
    end

    push
  end

  def pushudbags(bits)
    push = true

    bag = 1
    b = 2
    while bag < 8
      if (bits & b) != 0
        if @bagdat[bag].gt != 0
          getgold(bag)
        else
          push = false
        end
      end

      bag += 1
      b <<= 1
    end

    push
  end

  def removebag(bag)
    if @bagdat[bag].exist
      @bagdat[bag].exist = false
      @dig.Sprite.erasespr(bag)
    end
  end

  def removebags(bits)
    bag = 1
    b = 2
    while bag < 8
      if (@bagdat[bag].exist) && ((bits & b) != 0)
        removebag(bag)
      end

      bag += 1
      b <<= 1
    end
  end

  def updatebag(bag)
    x = @bagdat[bag].x
    h = @bagdat[bag].h
    xr = @bagdat[bag].xr
    y = @bagdat[bag].y
    v = @bagdat[bag].v
    yr = @bagdat[bag].yr
    case @bagdat[bag].dir
    when -1
      if y < 180 && xr == 0
        if @bagdat[bag].wobbling
          if @bagdat[bag].wt == 0
            @bagdat[bag].dir = 6
            @dig.Sound.soundfall()
          else
            @bagdat[bag].wt -= 1
            wbl = @bagdat[bag].wt % 8
            if !((wbl & 1) != 0)
              @dig.Drawing.drawgold(bag, @wblanim[wbl >> 1], x, y)
              @dig.Main.incpenalty()
              @dig.Sound.soundwobble()
            end
          end
        elsif (@dig.Monster.getfield(h, v + 1) & 0xfdf) != 0xfdf
          if !@dig.checkdiggerunderbag(h, v + 1)
            @bagdat[bag].wobbling = true
          end
        end
      else
        @bagdat[bag].wt = 15
        @bagdat[bag].wobbling = false
      end
    when 0, 4
      if xr == 0
        if y < 180 && (@dig.Monster.getfield(h, v + 1) & 0xfdf) != 0xfdf
          @bagdat[bag].dir = 6
          @bagdat[bag].wt = 0
          @dig.Sound.soundfall()
        else
          baghitground(bag)
        end
      end
    when 6
      if yr == 0
        @bagdat[bag].fallh += 1
      end

      if y >= 180
        baghitground(bag)
      elsif (@dig.Monster.getfield(h, v + 1) & 0xfdf) == 0xfdf
        if yr == 0
          baghitground(bag)
        end
      end

      @dig.Monster.checkmonscared(@bagdat[bag].h)
    end

    if @bagdat[bag].dir != -1
      if @bagdat[bag].dir != 6 && @pushcount != 0
        @pushcount -= 1
      else
        pushbag(bag, @bagdat[bag].dir)
      end
    end
  end
end
