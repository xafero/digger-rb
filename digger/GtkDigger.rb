require "gtk3"

class GtkDigger
  attr_accessor :digger, :area

  def initialize(d)
    @digger = d
    @area = Gtk::DrawingArea.new
    @area.signal_connect "draw" do |w, g|
      # width = da.get_allocated_width()
      # height = da.get_allocated_height()

      g.set_source_rgb(0, 0, 0)
      g.rectangle(0, 0, 3840, 2160)
      g.fill

      g.scale(4, 4)

      pc = @digger.Pc
      w = pc.width
      h = pc.height
      data = pc.pixels
      source = pc.currentSource
      model = source.get_model unless source.nil?

      unless model.nil?
        (0..w).each do |x|
          (0..h).each do |y|
            array_index = y * w + x
            (sr, sg, sb) = model.get_color(data[array_index])
            g.set_source_rgb(sr, sg, sb)
            g.rectangle(x, y, 1, 1)
            g.fill
          end
        end
      end

      false
    end
  end

  def set_focusable(param) end

  def do_key_up(key)
    @digger.key_up(key)
  end

  def do_key_down(key)
    @digger.key_down(key)
  end

  def create_refresher(model)
    GtkRefresher.new(self, model)
  end
end
