require 'encrust/version'
require 'plist'

module Encrust
  class << self
    private

    # ANSI Color 3 ("yellow") is called "BROWN" in Dwarf Fortress,
    # while ANSI Color 11 ("bright yellow") is simply called "YELLOW".
    # ANSI Color 7 ("white") is called "LGRAY" in Dwarf Fortress,
    # ANSI Color 8 ("bright black") is called "DGRAY", and
    # ANSI Color 15 ("bright white") is called "WHITE".
    def names
      %i[BLACK  RED  GREEN  BROWN  BLUE  MAGENTA  CYAN LGRAY
         DGRAY LRED LGREEN YELLOW LBLUE LMAGENTA LCYAN WHITE]
    end

    def header
      <<~DWARF
        These are the display colors in RGB.  \
        The game is actually displaying extended \
        ASCII characters in OpenGL, so you can modify the colors.

      DWARF
    end

    def colors(path)
      iterm_colors = Plist.parse_xml(path)
      names.map.with_index do |color, i|
        iterm_rgb = iterm_colors["Ansi #{i} Color"]
        <<~DWARF
          [#{color}_R:#{(iterm_rgb['Red Component'] * 255).to_i}]
          [#{color}_G:#{(iterm_rgb['Green Component'] * 255).to_i}]
          [#{color}_B:#{(iterm_rgb['Blue Component'] * 255).to_i}]
        DWARF
      end.join
    end

    def footer(path)
      <<~DWARF

        Converted from `#{File.basename(path)}` with encrust:
        https://github.com/smoochbot/encrust
      DWARF
    end

    public

    def with_gems(path)
      header << colors(path) << footer(path)
    end
  end
end
