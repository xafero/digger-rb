class SystemX
  def self.current_millis
    (Time.now.to_f * 1000).to_i
  end

  def self.sleep_ms(wait_ms)
    sec = (wait_ms / 1000.0)
    sleep(sec)
  end
end
