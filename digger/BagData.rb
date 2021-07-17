class BagData
  attr_accessor :x, :y, :h, :v, :xr, :yr, :dir, :wt, :gt, :fallh, :wobbling, :unfallen, :exist

  def initialize
    @x = 0
    @y = 0
    @h = 0
    @v = 0
    @xr = 0
    @yr = 0
    @dir = 0
    @wt = 0
    @gt = 0
    @fallh = 0
    @wobbling = false
    @unfallen = false
    @exist = false
  end

  def copy_from(t)
    @x = t.x
    @y = t.y
    @h = t.h
    @v = t.v
    @xr = t.xr
    @yr = t.yr
    @dir = t.dir
    @wt = t.wt
    @gt = t.gt
    @fallh = t.fallh
    @wobbling = t.wobbling
    @unfallen = t.unfallen
    @exist = t.exist
  end
end
