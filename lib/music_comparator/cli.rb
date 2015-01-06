require 'thor'
require 'database'

module MusicComparator
  class Cli < Thor

  desc 'scan', 'Scan directory and DB for differences'
  def scan
    db = MusicComparator::Database.new
    db_files = db.scan
  end

  end
end