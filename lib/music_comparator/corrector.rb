require 'colorize'
require 'parallel'
require 'taglib'

module MusicComparator
  class Corrector

    class << self

      def remove_original_mix(path, options)
        parallel_options = {progress: 'Checking files'}
        parallel_options[:in_processes] = options[:jobs].floor if options[:jobs] >= 0

        original_mix_pattern = /(.+[^ ]) +(\(original mix\)|- original mix) *$/i

        dashes_pattern = /^(.*[^ ]) +- +([^()]+(?:edit|mix))$/i

        Parallel.each(MusicComparator::Files.mp3_files(path), parallel_options) do |filename|
          TagLib::MPEG::File.open(filename) do |mp3|
            changed = false

            original_mix_pattern.match(mp3.id3v2_tag.title) do |match|
              puts "#{filename.black.bold}\n  #{match[0].cyan.bold} > #{match[1].green.bold} #{match[2].red}"
              mp3.tag.title = match[1]
              changed = true
            end

            dashes_pattern.match(mp3.id3v2_tag.title) do |match|
              new_title = "#{ match[1] } (#{ match[2] })"
              puts "#{filename.black.bold}\n  #{match[1].cyan.bold} - #{match[2].red}  > #{ match[1].green } #{ "(#{ match[2] })".green.bold }"
              mp3.tag.title = new_title
              changed = true
            end

            mp3.save if changed
          end
        end
      end

    end

  end
end
