module MusicComparator
  class Files

    def scan_for(condition)
      path = "/home/viktor/disks/data1/music-rated/#{ 'wordless/' if condition.has_eq? :wordless }#{ condition.rating_with_leading_zero }"

      result = []
      Dir.glob("#{path}/*") do |file|
        result << file if File.file?(file) && /\.(mp3|flac|m4a)$/i =~ file
      end

      result
    end

  end
end
