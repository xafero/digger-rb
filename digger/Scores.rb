require "./ScoreStorage"

class Scores
  attr_accessor :dig, :scores, :substr, :highbuf, :scorehigh, :scoreinit, :scoret, :score1, :score2, :nextbs1, :nextbs2, :hsbuf, :scorebuf, :bonusscore, :gotinitflag

  def initialize(d)
    @dig = d
    @scores
    @substr = ""
    @highbuf = [" ", " ", " ", " ", " ", " ", " ", " ", " ", " "]
    @scorehigh = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    @scoreinit = ["", "", "", "", "", "", "", "", "", "", ""]
    @scoret = 0
    @score1 = 0
    @score2 = 0
    @nextbs1 = 0
    @nextbs2 = 0
    @hsbuf = ""
    @scorebuf = [" ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " "]
    @bonusscore = 20000
    @gotinitflag = false
  end

  def _submit(n, s)
    if @dig.subaddr != nil
      # ms = 16 + (System.currentTimeMillis() % (65536 - 16))
      # @substr = n + "+" + s + "+" + ms + "+" + ((ms + 32768) * s) % 65536
      # Thread.new(self).start()
    end

    return @scores
  end

  def _updatescores(o)
    if o == nil
      return
    end

    inx = Array.new()
    scx = Array.new()

    i = 0
    while i < 10
      inx[i] = o[i].key
      scx[i] = o[i].value

      i += 1
    end

    i = 0
    while i < 10
      @scoreinit[i + 1] = inx[i]
      @scorehigh[i + 2] = scx[i]

      i += 1
    end
  end

  def addscore(score)
    if @dig.Main.getcplayer() == 0
      @score1 += score
      if @score1 > 999999
        @score1 = 0
      end

      writenum(score1, 0, 0, 6, 1)
      if @score1 >= @nextbs1
        if @dig.Main.getlives(1) < 5
          @dig.Main.addlife(1)
          @dig.Drawing.drawlives()
        end

        @nextbs1 += @bonusscore
      end
    else
      @score2 += score
      if @score2 > 999999
        @score2 = 0
      end

      if @score2 < 100000
        writenum(@score2, 236, 0, 6, 1)
      else
        writenum(@score2, 248, 0, 6, 1)
      end

      if @score2 > @nextbs2
        if @dig.Main.getlives(2) < 5
          @dig.Main.addlife(2)
          @dig.Drawing.drawlives()
        end

        @nextbs2 += @bonusscore
      end
    end

    @dig.Main.incpenalty()
    @dig.Main.incpenalty()
    @dig.Main.incpenalty()
  end

  def drawscores
    writenum(@score1, 0, 0, 6, 3)
    if @dig.Main.nplayers == 2
      if @score2 < 100000
        writenum(@score2, 236, 0, 6, 3)
      else
        writenum(@score2, 248, 0, 6, 3)
      end
    end
  end

  def endofgame
    addscore(0)
    if @dig.Main.getcplayer() == 0
      @scoret = @score1
    else
      @scoret = @score2
    end

    if @scoret > @scorehigh[11]
      @dig.Pc.gclear()
      drawscores()
      @dig.Main.pldispbuf = "PLAYER "
      if @dig.Main.getcplayer() == 0
        @dig.Main.pldispbuf += "1"
      else
        @dig.Main.pldispbuf += "2"
      end

      @dig.Drawing.outtext(@dig.Main.pldispbuf, 108, 0, 2, true)
      @dig.Drawing.outtext(" NEW HIGH SCORE ", 64, 40, 2, true)
      getinitials()
      _updatescores(_submit(@scoreinit[0], @scoret))
      shufflehigh()
      ScoreStorage.write_to_storage(self)
    else
      @dig.Main.cleartopline()
      @dig.Drawing.outtext("GAME OVER", 104, 0, 3, true)
      _updatescores(_submit("...", @scoret))
      @dig.Sound.killsound()
      j = 0
      while j < 20
        i = 0
        while i < 2
          @dig.Sprite.setretr(true)
          @dig.Pc.gpal(1 - (j & 1))
          @dig.Sprite.setretr(false)
          z = 0
          while z < 111
            z += 1
          end

          @dig.Pc.gpal(0)
          @dig.Pc.ginten(1 - i & 1)
          @dig.newframe()

          i += 1
        end

        j += 1
      end

      @dig.Sound.setupsound()
      @dig.Drawing.outtext("         ", 104, 0, 3, true)
      @dig.Sprite.setretr(true)
    end
  end

  def flashywait(n)
    SystemX.sleep_ms(n * 2)
  end

  def getinitial(x, y)
    @dig.Input.keypressed = 0
    @dig.Pc.gwrite(x, y, "_", 3, true)
    j = 0
    while j < 5
      i = 0
      while i < 40
        if (@dig.Input.keypressed & 0x80) == 0 && @dig.Input.keypressed != 0
          return @dig.Input.keypressed
        end

        flashywait(15)

        i += 1
      end

      i = 0
      while i < 40
        if (@dig.Input.keypressed & 0x80) == 0 && @dig.Input.keypressed != 0
          @dig.Pc.gwrite(x, y, "_", 3, true)
          return @dig.Input.keypressed
        end

        flashywait(15)

        i += 1
      end

      j += 1
    end

    @gotinitflag = true
    return 0
  end

  def getinitials
    @dig.Drawing.outtext("ENTER YOUR", 100, 70, 3, true)
    @dig.Drawing.outtext(" INITIALS", 100, 90, 3, true)
    @dig.Drawing.outtext("_ _ _", 128, 130, 3, true)
    @scoreinit[0] = "..."
    @dig.Sound.killsound()
    @gotinitflag = false
    i = 0
    while i < 3
      k = 0
      while k == 0 && !gotinitflag
        k = getinitial(i * 24 + 128, 130)
        if i != 0 && k == 8
          i -= 1
        end

        k = @dig.Input.getasciikey(k)
      end

      if k != 0
        @dig.Pc.gwrite(i * 24 + 128, 130, k, 3, true)
        sb = scoreinit[0] + ""
        sb[i] = k.chr
        @scoreinit[0] = sb
      end

      i += 1
    end

    @dig.Input.keypressed = 0
    i = 0
    while i < 20
      flashywait(15)
      i += 1
    end

    @dig.Sound.setupsound()
    @dig.Pc.gclear()
    @dig.Pc.gpal(0)
    @dig.Pc.ginten(0)
    @dig.newframe()
    @dig.Sprite.setretr(true)
  end

  def initscores
    addscore(0)
  end

  def loadscores
    p = 1

    i = 1
    while i < 11
      x = 0
      while x < 3
        @scoreinit[i] = "..."
        x += 1
      end

      p += 2
      x = 0
      while x < 6
        @highbuf[x] = @scorebuf[p]
        p += 1
        x += 1
      end

      @scorehigh[i + 1] = 0

      i += 1
    end

    if @scorebuf[0] != "s"
      i = 0
      while i < 11
        @scorehigh[i + 1] = 0
        @scoreinit[i] = "..."

        i += 1
      end
    end
  end

  def numtostring(n)
    p = ""

    x = 0
    while x < 6
      p = (n % 10).to_s + p
      n /= 10
      if n == 0
        x += 1
        break
      end

      x += 1
    end

    while x < 6
      p = " " + p
      x += 1
    end

    return p
  end

  def init
    if !ScoreStorage.read_from_storage(self)
      ScoreStorage.create_in_storage(self)
    end
  end

  def scorebonus
    addscore(1000)
  end

  def scoreeatm
    addscore(@dig.eatmsc * 200)
    @dig.eatmsc <<= 1
  end

  def scoreemerald
    addscore(25)
  end

  def scoregold
    addscore(500)
  end

  def scorekill
    addscore(250)
  end

  def scoreoctave
    addscore(250)
  end

  def showtable
    @dig.Drawing.outtext("HIGH SCORES", 16, 25, 3)
    col = 2
    i = 1
    while i < 11
      @hsbuf = @scoreinit[i] + "  " + numtostring(@scorehigh[i + 1])
      @dig.Drawing.outtext(@hsbuf, 16, 31 + 13 * i, col)
      col = 1

      i += 1
    end
  end

  def shufflehigh
    j = 10
    while j > 1
      if @scoret < @scorehigh[j]
        break
      end

      j -= 1
    end

    i = 10
    while i > j
      @scorehigh[i + 1] = @scorehigh[i]
      @scoreinit[i] = @scoreinit[i - 1]

      i -= 1
    end

    @scorehigh[j + 1] = @scoret
    @scoreinit[j] = @scoreinit[0]
  end

  def writecurscore(bp6)
    if @dig.Main.getcplayer() == 0
      writenum(@score1, 0, 0, 6, bp6)
    elsif @score2 < 100000
      writenum(@score2, 236, 0, 6, bp6)
    else
      writenum(@score2, 248, 0, 6, bp6)
    end
  end

  def writenum(n, x, y, w, c)
    xp = (w - 1) * 12 + x

    while w > 0
      d = (n % 10)
      if w > 1 || d > 0
        @dig.Pc.gwrite(xp, y, d + "0".ord, c, false)
      end

      n /= 10
      w -= 1
      xp -= 12
    end
  end

  def zeroscores
    @score2 = 0
    @score1 = 0
    @scoret = 0
    @nextbs1 = @bonusscore
    @nextbs2 = @bonusscore
  end
end
