require 'colorize'
require 'parallel'
require 'taglib'

module MusicComparator
  class Corrector

    class << self

      def remove_original_mix(path, options)
        parallel_options = {progress: 'Checking files'}
        parallel_options[:in_processes] = options[:jobs].floor if options[:jobs] >= 0

        pattern_to_remove = /(.+[^ ]) +(\(original mix\)|- original mix) *$/i

        Parallel.each(MusicComparator::Files.new_music(path), parallel_options) do |filename|
          TagLib::MPEG::File.open(filename) do |mp3|
            pattern_to_remove.match(mp3.id3v2_tag.title) do |match|
              puts "#{filename.black.bold}\n  #{match[0].cyan.bold} > #{match[1].green.bold} #{match[2].red}"
              mp3.tag.title = match[1]
              mp3.save
            end
          end
        end
      end

    end

  end
end
