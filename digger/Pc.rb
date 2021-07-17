require "./GtkRefresher"
require "./SystemX"
require "./CgaGrafx"
require "./Alpha"

class Pc
  attr_accessor :dig, :image, :currentImage, :source, :currentSource, :width, :height, :size, :pixels, :pal

  def initialize(d)
    @dig = d
    @source = [GtkRefresher.new(), GtkRefresher.new()]
    @currentSource
    @width = 320
    @height = 200
    @pixels
    @pal = [[[0, 0x00, 0xAA, 0xAA], [0, 0xAA, 0x00, 0x54], [0, 0x00, 0x00, 0x00]], [[0, 0x54, 0xFF, 0xFF], [0, 0xFF, 0x54, 0xFF], [0, 0x54, 0x54, 0x54]]]
    @size = @width * @height
  end

  def gclear
    i = 0

    while i < @size
      @pixels[i] = 0
      i += 1
    end

    @currentSource.new_pixels_all()
  end

  def gethrt
    SystemX.current_millis
  end

  def getkips
    0
  end

  def ggeti(x, y, p, w, h)
    if p == nil
      return # TODO Why?
    end

    src = 0

    dest = y * @width + (x & 0xfffc)

    i = 0

    while i < h
      d = dest

      j = 0

      while j < w
        p[src] = ((((((@pixels[d] << 2) | @pixels[d + 1]) << 2) | @pixels[d + 2]) << 2) | @pixels[d + 3])
        src += 1
        d += 4
        if src == p.length
          return
        end

        j += 1
      end

      dest += @width

      i += 1
    end
  end

  def ggetpix(x, y)
    ofs = @width * y + x & 0xfffc

    (((((@pixels[ofs] << 2) | @pixels[ofs + 1]) << 2) | @pixels[ofs + 2]) << 2) | @pixels[ofs + 3]
  end

  def ginit; end

  def ginten(inten)
    i = inten & 1
    @currentSource = @source[i]
    @currentSource.new_pixels_all()
  end

  def gpal(pal) end

  def gputi(x, y, p, w, h, b = true)
    src = 0

    dest = y * @width + (x & 0xfffc)

    i = 0

    while i < h
      d = dest

      j = 0

      while j < w
        px = p[src]
        src += 1

        @pixels[d + 3] = px & 3
        px >>= 2
        @pixels[d + 2] = px & 3
        px >>= 2
        @pixels[d + 1] = px & 3
        px >>= 2
        @pixels[d] = px & 3
        d += 4
        if src == p.length
          return
        end

        j += 1
      end

      dest += @width

      i += 1
    end
  end

  def gputim(x, y, ch, w, h)
    spr = CgaGrafx.cgatable[ch * 2]

    msk = CgaGrafx.cgatable[ch * 2 + 1]

    src = 0

    dest = y * @width + (x & 0xfffc)

    i = 0

    while i < h
      d = dest

      j = 0

      while j < w
        px = spr[src]

        mx = msk[src]

        src += 1
        if (mx & 3) == 0
          @pixels[d + 3] = px & 3
        end

        px >>= 2
        if (mx & (3 << 2)) == 0
          @pixels[d + 2] = px & 3
        end

        px >>= 2
        if (mx & (3 << 4)) == 0
          @pixels[d + 1] = px & 3
        end

        px >>= 2
        if (mx & (3 << 6)) == 0
          @pixels[d] = px & 3
        end

        d += 4
        if src == spr.length || src == msk.length
          return
        end

        j += 1
      end

      dest += @width

      i += 1
    end
  end

  def gtitle
    src = 0
    dest = 0

    while true
      if src >= CgaGrafx.cgatitledat.length
        break
      end

      b = CgaGrafx.cgatitledat[src]
      src += 1

      if b == 0xfe
        l = CgaGrafx.cgatitledat[src]
        src += 1
        if l == 0
          l = 256
        end

        c = CgaGrafx.cgatitledat[src]
        src += 1
      else
        l = 1
        c = b
      end

      i = 0

      while i < l
        px = c

        if dest < 32768
          adst = (dest / 320) * 640 + dest % 320
        else
          adst = 320 + ((dest - 32768) / 320) * 640 + (dest - 32768) % 320
        end

        if px == nil
          break # TODO Why?
        end

        @pixels[adst + 3] = px & 3
        px >>= 2
        @pixels[adst + 2] = px & 3
        px >>= 2
        @pixels[adst + 1] = px & 3
        px >>= 2
        @pixels[adst + 0] = px & 3
        dest += 4
        if dest >= 65535
          break
        end

        i += 1
      end

      if dest >= 65535
        break
      end
    end
  end

  def gwrite(x, y, chRaw, c, upd = false)
    ch = chRaw.ord

    dest = x + y * @width
    ofs = 0
    color = c & 3

    ch -= 32
    if (ch < 0) || (ch > 0x5f)
      return
    end

    chartab = Alpha.ascii2cga[ch]

    if chartab == nil
      return
    end

    i = 0

    while i < 12
      d = dest

      j = 0

      while j < 3
        px = chartab[ofs]
        ofs += 1

        if px == nil
          break # TODO Why?
        end

        @pixels[d + 3] = px & color
        px >>= 2
        @pixels[d + 2] = px & color
        px >>= 2
        @pixels[d + 1] = px & color
        px >>= 2
        @pixels[d] = px & color
        d += 4

        j += 1
      end

      dest += @width

      i += 1
    end

    if upd
      @currentSource.new_pixels_all() # Highscore fix: (x, y, 12, 12)
    end
  end
end
