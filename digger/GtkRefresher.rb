require "gtk3"
require "glib2"

class GtkRefresher
  def initialize(area = nil, model = nil)
    @area = area
    @model = model
  end

  def get_model
    @model
  end

  def new_pixels(x, y, w, h)
    unless @area.nil?
      GLib::Idle.add do
        @area.area.queue_draw_area(x, y, w, h)
      end
    end
  end

  def new_pixels_all
    unless @area.nil?
      GLib::Idle.add do
        @area.area.queue_draw()
      end
    end
  end

  def get_color(index)
    @model.get_color(index)
  end

  def set_animated(val) end
end
