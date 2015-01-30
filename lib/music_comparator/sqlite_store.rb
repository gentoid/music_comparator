module MusicComparator
  class SqliteStore

    def initialize
      @db = SQLite3::Database.new MusicComparator::Config.config[:sqlite][:database]
    end



  end
end
