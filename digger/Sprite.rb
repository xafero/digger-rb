class Sprite
  attr_accessor :dig, :retrflag, :sprrdrwf, :sprrecf, :sprenf, :sprch, :sprmov, :sprx, :spry, :sprwid, :sprhei, :sprbwid, :sprbhei, :sprnch, :sprnwid, :sprnhei, :sprnbwid, :sprnbhei, :defsprorder, :sprorder

  def initialize(d)
    @dig = d
    @retrflag = true
    @sprrdrwf = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
    @sprrecf = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
    @sprenf = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
    @sprch = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    @sprmov = [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
    @sprx = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    @spry = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    @sprwid = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    @sprhei = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    @sprbwid = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    @sprbhei = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    @sprnch = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    @sprnwid = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    @sprnhei = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    @sprnbwid = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    @sprnbhei = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    @defsprorder = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
    @sprorder = @defsprorder
  end

  def bcollide(bx, si)
    if @sprx[bx] >= @sprx[si]
      if @sprx[bx] + @sprbwid[bx] > @sprwid[si] * 4 + @sprx[si] - @sprbwid[si] - 1
        return false
      end
    elsif @sprx[si] + @sprbwid[si] > @sprwid[bx] * 4 + @sprx[bx] - @sprbwid[bx] - 1
      return false
    end

    if @spry[bx] >= @spry[si]
      if @spry[bx] + @sprbhei[bx] <= @sprhei[si] + @spry[si] - @sprbhei[si] - 1
        return true
      end

      return false
    end

    if @spry[si] + @sprbhei[si] <= @sprhei[bx] + @spry[bx] - @sprbhei[bx] - 1
      return true
    end

    false
  end

  def bcollides(bx)
    si = bx
    ax = 0
    dx = 0

    bx = 0
    loop do
      if @sprenf[bx] && bx != si
        if bcollide(bx, si)
          ax |= 1 << dx
        end

        @sprx[bx] += 320
        @spry[bx] -= 2
        if bcollide(bx, si)
          ax |= 1 << dx
        end

        @sprx[bx] -= 640
        @spry[bx] += 4
        if bcollide(bx, si)
          ax |= 1 << dx
        end

        @sprx[bx] += 320
        @spry[bx] -= 2
      end

      bx += 1
      dx += 1

      break if dx == 16
    end

    ax
  end

  def clearrdrwf
    clearrecf()
    i = 0
    while i < 17
      @sprrdrwf[i] = false
      i += 1
    end
  end

  def clearrecf
    i = 0
    while i < 17
      @sprrecf[i] = false
      i += 1
    end
  end

  def collide(bx, si)
    if @sprx[bx] >= @sprx[si]
      if @sprx[bx] > @sprwid[si] * 4 + @sprx[si] - 1
        return false
      end
    elsif @sprx[si] > @sprwid[bx] * 4 + @sprx[bx] - 1
      return false
    end

    if @spry[bx] >= @spry[si]
      if @spry[bx] <= @sprhei[si] + @spry[si] - 1
        return true
      end

      return false
    end

    if @spry[si] <= @sprhei[bx] + @spry[bx] - 1
      return true
    end

    false
  end

  def createspr(n, ch, mov, wid, hei, bwid, bhei)
    @sprnch[n & 15] = ch
    @sprch[n & 15] = ch
    @sprmov[n & 15] = mov
    @sprnwid[n & 15] = wid
    @sprwid[n & 15] = wid
    @sprnhei[n & 15] = hei
    @sprhei[n & 15] = hei
    @sprnbwid[n & 15] = bwid
    @sprbwid[n & 15] = bwid
    @sprnbhei[n & 15] = bhei
    @sprbhei[n & 15] = bhei
    @sprenf[n & 15] = false
  end

  def drawmiscspr(x, y, ch, wid, hei)
    @sprx[16] = x & -4
    @spry[16] = y
    @sprch[16] = ch
    @sprwid[16] = wid
    @sprhei[16] = hei
    @dig.Pc.gputim(@sprx[16], @spry[16], @sprch[16], @sprwid[16], @sprhei[16])
  end

  def drawspr(n, x, y)
    bx = n & 15
    x &= -4
    clearrdrwf()
    setrdrwflgs(bx)
    t1 = @sprx[bx]
    t2 = @spry[bx]
    t3 = @sprwid[bx]
    t4 = @sprhei[bx]
    @sprx[bx] = x
    @spry[bx] = y
    @sprwid[bx] = @sprnwid[bx]
    @sprhei[bx] = @sprnhei[bx]
    clearrecf()
    setrdrwflgs(bx)
    @sprhei[bx] = t4
    @sprwid[bx] = t3
    @spry[bx] = t2
    @sprx[bx] = t1
    @sprrdrwf[bx] = true
    putis()
    @sprx[bx] = x
    @spry[bx] = y
    @sprch[bx] = @sprnch[bx]
    @sprwid[bx] = @sprnwid[bx]
    @sprhei[bx] = @sprnhei[bx]
    @sprbwid[bx] = @sprnbwid[bx]
    @sprbhei[bx] = @sprnbhei[bx]
    @dig.Pc.ggeti(@sprx[bx], @spry[bx], @sprmov[bx], @sprwid[bx], @sprhei[bx])
    putims()
    bcollides(bx)
  end

  def erasespr(n)
    bx = n & 15

    @dig.Pc.gputi(@sprx[bx], @spry[bx], @sprmov[bx], @sprwid[bx], @sprhei[bx], true)
    @sprenf[bx] = false
    clearrdrwf()
    setrdrwflgs(bx)
    putims()
  end

  def getis
    i = 0
    while i < 16
      if @sprrdrwf[i]
        @dig.Pc.ggeti(@sprx[i], @spry[i], @sprmov[i], @sprwid[i], @sprhei[i])
      end

      i += 1
    end

    putims()
  end

  def initmiscspr(x, y, wid, hei)
    @sprx[16] = x
    @spry[16] = y
    @sprwid[16] = wid
    @sprhei[16] = hei
    clearrdrwf()
    setrdrwflgs(16)
    putis()
  end

  def initspr(n, ch, wid, hei, bwid, bhei)
    @sprnch[n & 15] = ch
    @sprnwid[n & 15] = wid
    @sprnhei[n & 15] = hei
    @sprnbwid[n & 15] = bwid
    @sprnbhei[n & 15] = bhei
  end

  def movedrawspr(n, x, y)
    bx = n & 15

    @sprx[bx] = x & -4
    @spry[bx] = y
    @sprch[bx] = @sprnch[bx]
    @sprwid[bx] = @sprnwid[bx]
    @sprhei[bx] = @sprnhei[bx]
    @sprbwid[bx] = @sprnbwid[bx]
    @sprbhei[bx] = @sprnbhei[bx]
    clearrdrwf()
    setrdrwflgs(bx)
    putis()
    @dig.Pc.ggeti(@sprx[bx], @spry[bx], @sprmov[bx], @sprwid[bx], @sprhei[bx])
    @sprenf[bx] = true
    @sprrdrwf[bx] = true
    putims()
    bcollides(bx)
  end

  def putims
    i = 0
    while i < 16
      j = @sprorder[i]
      if @sprrdrwf[j]
        @dig.Pc.gputim(@sprx[j], @spry[j], @sprch[j], @sprwid[j], @sprhei[j])
      end

      i += 1
    end
  end

  def putis
    i = 0
    while i < 16
      if @sprrdrwf[i]
        @dig.Pc.gputi(@sprx[i], @spry[i], @sprmov[i], @sprwid[i], @sprhei[i])
      end

      i += 1
    end
  end

  def setrdrwflgs(n)
    if !sprrecf[n]
      @sprrecf[n] = true
      i = 0
      while i < 16
        if @sprenf[i] && i != n
          if collide(i, n)
            @sprrdrwf[i] = true
            setrdrwflgs(i)
          end

          @sprx[i] += 320
          @spry[i] -= 2
          if collide(i, n)
            @sprrdrwf[i] = true
            setrdrwflgs(i)
          end

          @sprx[i] -= 640
          @spry[i] += 4
          if collide(i, n)
            @sprrdrwf[i] = true
            setrdrwflgs(i)
          end

          @sprx[i] += 320
          @spry[i] -= 2
        end

        i += 1
      end
    end
  end

  def setretr(f)
    @retrflag = f
  end

  def setsprorder(newsprorder)
    if newsprorder == nil
      @sprorder = @defsprorder
    else
      @sprorder = newsprorder
    end
  end
end
