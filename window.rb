#!/usr/bin/env ruby
require 'gtk2'

class StatusIcon
  def initialize
    @status = Gtk::StatusIcon.new
    @status.pixbuf=Gdk::Pixbuf.new(File.dirname(__FILE__) + '/postgresql_54.png')
    #@status.stock = Gtk::Stock::DIALOG_WARNING
    @status.tooltip = "PostgreSQL Controller" 
    @status.signal_connect('activate') { on_activate }
    @status.signal_connect('popup-menu') {|statusicon, button, time| on_right_click statusicon, button, time }
    @menu = Gtk::Menu.new
    @menu.append(about = Gtk::ImageMenuItem.new(Gtk::Stock::ABOUT))
    @menu.append(Gtk::SeparatorMenuItem.new)
    @menu.append(quit = Gtk::ImageMenuItem.new(Gtk::Stock::QUIT))
    about.signal_connect('activate') { on_click_about }
    quit.signal_connect('activate') do
      system("gksudo service postgresql stop")
      Gtk.main_quit
    end
    system("gksudo service postgresql start")
  end

  def on_activate
    @window ||= Proc.new { window = Window.new; window.signal_connect('destroy') { @window = nil }; puts "#{@window}"; window }.call
  end

  def on_click_about
    dialog = Gtk::AboutDialog.new
    dialog.program_name = "PostgreSQL Controller"
    dialog.version = "0.1"
    dialog.copyright = "(C) 2012 Alex Takitani"
    dialog.comments = "Starts and stops PostgreSQL service on Ubuntu"

    # Set the license text, which is usually loaded from
    # # a file. Also, set the web site address and label.
    dialog.license = "Free as a bird"
    dialog.website = "http://www.gtkbook.com"
    dialog.website_label = "www.gtkbook.com"
    #
    # # Set the application authors, documenters and translators.
    # dialog.authors = authors
    # dialog.documenters = documenters
    # dialog.translator_credits = "Translator #1\nTranslator #2"
    # # NOTE: all these properties are optional
    # # dialog.artists = ["Artist #1", "Artist #2"]
    #
    #dialog.show_all
    dialog.run
    dialog.destroy
    #Gtk::AboutDialog.new.show_all
  end

  def on_right_click(statusicon, button, time)
    @menu.popup(nil, nil, button, time) {|menu, x, y, push_in| @status.position_menu(@menu)}
    @menu.show_all
  end
end 

StatusIcon.new
Gtk.main
