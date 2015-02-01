require 'colorize'
require 'parallel'
require 'taglib'

module MusicComparator
  class Corrector

    class << self

      def remove_original_mix(path, options)
        parallel_options = {progress: 'Checking files'}
        parallel_options[:in_processes] = options[:jobs].floor if options[:jobs] >= 0

        # Parallel.each(MusicComparator::Files.mp3_files(path), parallel_options) do |filename|
        MusicComparator::Files.mp3_files(path).each do |filename|
          TagLib::MPEG::File.open(filename) do |mp3|
            corrector = self.new
            corrector.correct mp3.id3v2_tag.artist, mp3.id3v2_tag.title

            if corrector.changed?
              puts corrector.changes.join("\n") unless corrector.changes.empty?
              # puts "#{mp3.id3v2_tag.artist.public_send(corrector.artist_changed? ? :red : :cyan)} - \
#{mp3.id3v2_tag.title.public_send(corrector.title_changed? ? :red : :cyan)} > \
#{corrector.artist.public_send(corrector.artist_changed? ? :green : :cyan)} - \
#{corrector.title.public_send(corrector.title_changed? ? :green : :cyan)}"
            end

          end
        end
      end

    end

    attr_reader :artist, :title, :changes

    def correct(artist, title)
      init artist, title

      remove_original_mix
      dash_to_parenthesis
      correct_feat
      correct_vs
      correct_pres
      correct_title_feat
    end

    def artist_changed?
      @artist != @original_artist
    end

    def title_changed?
      @title != @original_title
    end

    def changed?
      artist_changed? or title_changed?
    end

    protected

    def init(artist, title)
      @original_artist = artist.dup
      @original_title  = title.dup

      @changes = []

      @artist = artist.dup
      @title  = title.dup
    end

    def remove_original_mix
      if (match = /(.+[^ ]) +(\(original mix\)|- original mix) *$/i.match(@title))
        @changes << "#{match[0].cyan.bold} > #{match[1].green.bold} #{match[2].red}"
        @title = match[1]
      end
    end

    def dash_to_parenthesis
      if (match = /^(.*[^ ]) +- +([^()]+(?:edit|mix))$/i.match(@title))
        @changes << "#{match[1].cyan.bold} - #{match[2].red}  > #{ match[1].green } #{ "(#{ match[2] })".green.bold }"
        @title = "#{ match[1] } (#{ match[2] })"
      end
    end

    def correct_feat
      if (match = /(.+) ((?:F(?:ea)?t|ft)\.?|feat) (.+)/.match(@artist))
        @changes << "#{match[1].cyan.bold} #{match[2].red} #{match[3].cyan.bold} > #{match[1].green} #{'feat.'.green.bold} #{match[3].green}"
        @artist = "#{ match[1] } feat. #{ match[3] }"
      end
    end

    def correct_vs
      if (match = /(.+) (Vs\.|vs) (.+)/.match(@artist))
        @changes << "#{match[1].cyan.bold} #{match[2].red} #{match[3].cyan.bold} > #{match[1].green} #{'vs.'.green.bold} #{match[3].green}"
        @artist = "#{ match[1] } vs. #{ match[3] }"
      end
    end

    def correct_pres
      if (match = /(.+) (Pres\.|pres|[Pp]resents) (.+)/.match(@artist))
        @changes << "#{match[1].cyan.bold} #{match[2].red} #{match[3].cyan.bold} > #{match[1].green} #{'pres.'.green.bold} #{match[3].green}"
        @artist = "#{ match[1] } pres. #{ match[3] }"
      end
    end

    def correct_title_feat
      if (match = /(.+[(\[ ])(f(?:ea)?t(?:\.|uring)?) +(.+)/i.match(@title)) # catch all variants of 'featuring'
        before_feat = ''
        title = match[1].gsub(/(( +?-)? +| +\()$/) { |m| before_feat = m; '' }
        feat_shortcut = match[2]
        rest = match[3].strip

        if (m = /^(.+[^\)])( +(?:- |\())(.+[^)])(\)?)$/.match(rest))
          feat = m[1]
          rest = m[3]
          rest_to_changes = "#{feat.red}#{m[2].magenta}#{rest.cyan}#{m[4].magenta}"
        elsif (m = /^([^\(\)]+)(\) *\(?)([^)]*)(.*)$/.match(rest))
          feat = m[1]
          rest = m[3]
          rest_to_changes = "#{feat.red}#{m[2].magenta}#{rest.cyan}#{m[4].magenta}"
        else
          feat = rest
          rest = ''
          rest_to_changes = "#{feat.red}"
        end

        changes = "#{@artist.cyan} - #{title.cyan}#{before_feat.magenta}#{feat_shortcut.red} #{rest_to_changes} > "

        if rest.length > 0
          title += " (#{rest})"
        end

        @title = title
        @artist += " feat. #{feat}"

        changes += "#{@artist.green} - #{@title.green}"
        @changes << changes
      end
    end

  end
end
