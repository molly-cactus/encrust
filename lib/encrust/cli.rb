require 'encrust'

module Encrust
  class CLI
    class << self
      private

      def underline(text)
        "\e[4m#{text}\e[0m"
      end

      def patreon
        underline("https://www.patreon.com/bay12games")
      end

      def bay_12_site
        underline("http://bay12games.com/support.html")
      end

      def message
        <<~DWARF

          To use your colors in Dwarf Fortress, move the file to:

            <your_dwarf_fortress_path>/data/init/colors.txt

          Consider backing up the existing colors.txt file first.

          To support the development of Dwarf Fortress, go to:
            * Bay 12 Games's patreon: #{patreon}
            * Bay 12 Games's website: #{bay_12_site}

          Thanks for using encrust, and remember: Losing is fun!
        DWARF
      end

      def convert(files)
        files.each do |path|
          colors = Encrust.with_gems(path)
          file = "#{File.basename(path, ".*")}.colors.txt"
          File.write(file, colors)
          puts "💎 #{File.basename(path)} -> #{file}"
        end
      end

      public

      def start
        convert(ARGV)
        puts message
      end
    end
  end
end
