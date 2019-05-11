require 'plist'

module Encrust
  class Converter
    class << self
      def iterm_to_df(path)
        header << colors(path) << footer(path)
      end

      private

      # ANSI Color 3 ("yellow") is called "BROWN" in Dwarf Fortress,
      # while ANSI Color 11 ("bright yellow") is simply called "YELLOW".
      # ANSI Color 7 ("white") is called "LGRAY" in Dwarf Fortress,
      # ANSI Color 8 ("bright black") is called "DGRAY", and
      # ANSI Color 15 ("bright white") is called "WHITE".
      def df_color_names
        %i[BLACK  RED  GREEN  BROWN  BLUE  MAGENTA  CYAN LGRAY
           DGRAY LRED LGREEN YELLOW LBLUE LMAGENTA LCYAN WHITE]
      end

      def parse(path)
        begin
          Plist.parse_xml(path)
        rescue RuntimeError => e
          msg = "Failed to parse file at path: #{path}"
          raise ArgumentError.new(msg)
        end
      end

      def colors(path)
        iterm_colors = parse(path)
        df_color_names.each_with_index.reduce("") do |df_colors, (color, i)|
          iterm_rgb = iterm_colors["Ansi #{i} Color"]
          if iterm_rgb.nil?
            msg = "Missing color definition for #{color} (DF) / #{i} (ANSI)"
            raise ArgumentError.new(msg)
          end
          df_colors << generate_df_color(color, iterm_rgb)
        end
      end

      def generate_df_color(color, iterm_rgb)
        red   = (iterm_rgb['Red Component'] * 255).to_i
        green = (iterm_rgb['Green Component'] * 255).to_i
        blue  = (iterm_rgb['Blue Component'] * 255).to_i
        
        if [red, green, blue].any? { |x| x > 255 || 0 > x }
          msg = "RGB value for #{color} (DF) out of valid range."
          raise ArgumentError.new(msg)
        end

        <<~DWARF
            [#{color}_R:#{red}]
            [#{color}_G:#{green}]
            [#{color}_B:#{blue}]
        DWARF
      end

      def header
        <<~DWARF
          These are the display colors in RGB.  \
          The game is actually displaying extended \
          ASCII characters in OpenGL, so you can modify the colors.

        DWARF
      end

      def footer(path)
        <<~DWARF

          Converted from `#{File.basename(path)}` using encrust:
          https://github.com/smoochbot/encrust
        DWARF
      end
    end
  end
end
