require 'encrust'

module Encrust
  class CLI
    class << self
      def start
        paths = ARGV.map(&:freeze)
        puts greeting(paths)
        errors = convert(paths)
        puts error_message(errors) if errors.any?
        puts instructions if paths.size > errors.size
        puts exit_message
      end

      private

      def convert(files)
        puts
        errors = []
        files.each do |path|
          print "  ☼ #{File.basename(path)} -> "
          begin
            colors = Converter.iterm_to_df(path)
          rescue ArgumentError => e
            STDERR.puts "ERROR \e[31;1m✕\e[0m"
            errors << path
          else
            file = "#{File.basename(path, ".*").tr(' ', '_')}.txt"
            File.write(file, colors)
            puts "«#{file}» \e[32;1m✓\e[0m"
          end
        end
        errors
      end

      def greeting(paths)
        if paths.count == 1
          "Converting an iterm2 color scheme to a Dwarf Fortress color file."
        else
          "Converting #{paths.count} iTerm2 color schemes " \
            "to Dwarf Fortress color files."
        end
      end

      def instructions
        <<~DWARF

          To use your colors in Dwarf Fortress, move your chosen file to:

            <your_dwarf_fortress_path>/data/init/colors.txt

          Consider backing up the existing colors.txt file first.
        DWARF
      end

      def error_message(paths_with_errors)
        plural = paths_with_errors.size > 1 ? 's' : nil
        <<~DWARF

          Error#{plural} while parsing file#{plural} at path#{plural}:

          #{paths_with_errors.map { |p| "  #{p}" }.join("\n")}

          Please make sure to use valid, suitable iTerm2 color files:
            ☼ They should be in PLIST (XML) format and contain <dict> tags.
            ☼ They should specify RGB values for all ANSI colors from 0 to 15,
              with each color's key formatted like e.g. `Ansi 0 Color` for 0.
            ☼ Each RGB value should lie between 0 and 1, both inclusive.
        DWARF
      end

      def exit_message
        <<~DWARF

          To support the development of Dwarf Fortress, go to:
            ☼ Bay 12 Games's patreon: #{patreon}
            ☼ Bay 12 Games's website: #{bay_12_site}

          Thanks for using encrust, and remember: Losing is fun!
        DWARF
      end

      def patreon
        underline("https://www.patreon.com/bay12games")
      end

      def bay_12_site
        underline("http://bay12games.com/support.html")
      end

      def underline(text)
        "\e[4m#{text}\e[0m"
      end
    end
  end
end
