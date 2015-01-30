module MusicComparator
  class Files

    class << self

      def scan_for(condition)
        path = "/home/viktor/disks/data1/music-rated/#{ condition.path }"

        scan_path_for_music path
      end

      def mp3_files(path)
        scan_path_for_music path, ext: [:mp3]
      end

      def is_music_file(file, options = {})
        options[:ext] ||= [:mp3, :flac, :m4a]
        File.file?(file) && /\.(#{ options[:ext].join '|' })$/i =~ file
      end

      def scan_path_for_music(path, options = {})
        if path.is_a?(Array)
          return path.reduce([]) { |memo, _path| memo + scan_path_for_music(_path, options) }
        end

        result = []
        options[:recursive] ||= true

        Dir.glob("#{path}/*") do |file|
          result << file if self.is_music_file(file, options)
          if File.directory?(file) and options[:recursive]
            result += scan_path_for_music file, options
          end
        end

        result
      end

    end

  end
end
