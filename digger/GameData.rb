class GameData
  attr_accessor :lives, :level, :dead, :levdone

  def initialize
    @lives = 0
    @level = 0
    @dead = false
    @levdone = false
  end
end
