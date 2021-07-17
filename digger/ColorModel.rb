class ColorModel
  def initialize(bits, size, red, green, blue)
    @bits = bits
    @size = size
    @r = red
    @g = green
    @b = blue
  end

  def get_color(index)
    r = @r[index]
    g = @g[index]
    b = @b[index]
    [r, g, b]
  end
end
