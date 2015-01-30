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
        feat_pattern = /(.+) (F(?:ea)?t\.?|ft\.?|feat) (.+)/
        vs_pattern = /(.+) (Vs\.|vs) (.+)/
        pres_pattern = /(.+) (Pres\.|pres|[Pp]resents) (.+)/

        Parallel.each(MusicComparator::Files.mp3_files(path), parallel_options) do |filename|
        # MusicComparator::Files.mp3_files(path).each do |filename|
          TagLib::MPEG::File.open(filename) do |mp3|
            changes = ''

            original_mix_pattern.match(mp3.id3v2_tag.title) do |match|
              changes += "  #{match[0].cyan.bold} > #{match[1].green.bold} #{match[2].red}\n"
              mp3.tag.title = match[1]
            end

            dashes_pattern.match(mp3.id3v2_tag.title) do |match|
              new_title = "#{ match[1] } (#{ match[2] })"
              changes += "  #{match[1].cyan.bold} - #{match[2].red}  > #{ match[1].green } #{ "(#{ match[2] })".green.bold }\n"
              mp3.tag.title = new_title
            end

            feat_pattern.match(mp3.id3v2_tag.artist) do |match|
              changes += "  #{match[1].cyan.bold} #{match[2].red} #{match[3].cyan.bold} > #{match[1].green} #{'feat.'.green.bold} #{match[3].green}\n"
              mp3.tag.artist = "#{ match[1] } feat. #{ match[3] }"
            end

            vs_pattern.match(mp3.id3v2_tag.artist) do |match|
              changes += "  #{match[1].cyan.bold} #{match[2].red} #{match[3].cyan.bold} > #{match[1].green} #{'vs.'.green.bold} #{match[3].green}\n"
              mp3.tag.artist = "#{ match[1] } vs. #{ match[3] }"
            end

            pres_pattern.match(mp3.id3v2_tag.artist) do |match|
              changes += "  #{match[1].cyan.bold} #{match[2].red} #{match[3].cyan.bold} > #{match[1].green} #{'pres.'.green.bold} #{match[3].green}\n"
              mp3.tag.artist = "#{ match[1] } pres. #{ match[3] }"
            end

            unless changes.length == 0
              mp3.save

              puts filename.black.bold
              puts changes
            end
          end
        end
      end

    end

  end
end
