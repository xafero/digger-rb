require "./ScoreTuple"

class ScoreStorage
  def self.create_in_storage(mem)
    ScoreStorage.write_to_storage(mem)
  end

  def self.write_to_storage(mem)
    sco_file = ScoreStorage.get_score_file
    File.open(sco_file, "w") do |bw|
      scoreinit = mem.scoreinit
      scorehigh = mem.scorehigh
      (0..9).each do |i|
        bw.write(scoreinit[i + 1])
        bw.write("\n")
        bw.write((scorehigh[i + 2]).to_s)
        bw.write("\n")
      end
      bw.flush
      bw.close
    end
  end

  def self.get_score_file()
    file_name = "../digger.sco"
    file_path = File.expand_path(file_name)
    file_path
  end

  def self.read_from_storage(mem)
    sco_file = ScoreStorage.get_score_file
    if !File.exists?(sco_file) || File.directory?(sco_file)
      return false
    end
    File.open(sco_file, "r") do |br|
      lines = br.readlines
      sc = []
      i = 0
      while i < 20
        name = lines[i].strip
        score = lines[i + 1].to_i
        sc[i / 2] = ScoreTuple.new(name, score)
        i += 2
      end
      br.close
      mem.scores = sc
      return true
    end
    false
  end
end
