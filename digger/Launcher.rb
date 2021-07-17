require "gtk3"
require "./GtkDigger"
require "./Digger"
require "./Compat"

def create_app
  app = Gtk::Application.new("org.digger.classic", :flags_none)
  app.signal_connect "activate" do |appl|

    pgtk = GtkDigger.new(nil)
    game = Digger.new(pgtk)
    pgtk.digger = game
    pgtk.set_focusable(true)
    game.init
    game.start

    frame = Gtk::ApplicationWindow.new(appl)
    frame.set_title("Digger Remastered")
    frame.signal_connect("delete-event") { |_widget| Gtk.main_quit }
    frame.set_default_size(game.width * 4.03, game.height * 4.15)
    frame.set_position(Gtk::WindowPosition::CENTER)

    icon = "./res/icons/digger.png"
    frame.set_icon_from_file(icon)

    frame.signal_connect("key-press-event") do |w, ev|
      num = Compat.convert_to_legacy(ev.keyval)
      if num >= 0
        game.key_down(num)
      end
    end
    frame.signal_connect("key-release-event") do |w, ev|
      num = Compat.convert_to_legacy(ev.keyval)
      if num >= 0
        game.key_up(num)
      end
    end

    frame.add(pgtk.area)
    frame.show_all
  end

  app
end

create_app.run ARGV
