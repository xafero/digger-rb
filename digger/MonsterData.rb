class MonsterData
  attr_accessor :x, :y, :h, :v, :xr, :yr, :dir, :hdir, :t, :hnt, :death, :bag, :dtime, :stime, :flag, :nob, :alive

  def initialize
    @x = 0
    @y = 0
    @h = 0
    @v = 0
    @xr = 0
    @yr = 0
    @dir = 0
    @hdir = 0
    @t = 0
    @hnt = 0
    @death = 0
    @bag = 0
    @dtime = 0
    @stime = 0
    @flag = false
    @nob = false
    @alive = false
  end
end
