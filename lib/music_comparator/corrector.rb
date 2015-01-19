require 'mp3info'
require 'parallel'

module MusicComparator
  class Corrector

    class << self

      def remove_original_mix(path, options)
        parallel_options = {progress: 'Checking files'}
        parallel_options[:in_processes] = options[:jobs].floor if options[:jobs] >= 0
        Parallel.each(MusicComparator::Files.new_music(path), parallel_options) do |file|
          # puts "\e[1;31m#{file}\e[0m"
          Mp3Info.open(file) do |mp3|
            /(.+[^ ]) +(\(original mix\)|- original mix) *$/i.match(mp3.tag.title) do |match|
              puts "file \e[1;30m#{file}\e[0m\n  \e[1;36m#{match[0]}\e[0m \e[1m=>\e[0m \e[1;32m#{match[1]} \e[0m\e[31m#{match[2]}\e[0m"
              mp3.tag.title = match[1]
            end
          end
        end
      end

    end

  end
end
