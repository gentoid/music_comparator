require 'thor'

require 'condition'
require 'database'
require 'files'

module MusicComparator
  class Cli < Thor

    desc 'scan', 'Scan directory and DB for differences'
    def scan
      db    = MusicComparator::Database.new
      files = MusicComparator::Files.new
      conditions.each do |condition|
        to_copy, to_delete = diff db.scan_for(condition), files.scan_for(condition)

        unless to_copy.empty? && to_delete.empty?
          puts "[ -- #{ 'wordless/' if condition.has_eq? :wordless }#{ condition.rating_with_leading_zero } -- ]"

          unless to_copy.empty?
            puts '  TO COPY:'
            puts to_copy
          end

          unless to_delete.empty?
            puts '  TO DELETE:'
            puts to_delete
          end
          puts ''
        end
      end
    end

    private

    def conditions
      result = []

      (8..10).each do |rating|
        condition = MusicComparator::Condition.new
        condition
            .eq(:checked)
            .not_eq(:wordless)
            .rating = rating
        result << condition
      end

      (7..10).each do |rating|
        condition = MusicComparator::Condition.new
        condition
            .eq(:checked)
            .eq(:wordless)
            .rating = rating
        result << condition
      end

      result
    end

    def diff(db, files)
      db_prepared = db.map { |row| row[:rpath].split('/')[-1] }
      files_prepared = files.map { |file| file.split('/')[-1] }

      to_delete = files_prepared - db_prepared
      to_copy = db_prepared - files_prepared

      [to_copy, to_delete]
    end

  end
end