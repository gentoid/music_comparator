require 'thor'

require 'condition'
require 'corrector'
require 'database'
require 'files'

module MusicComparator
  class Cli < Thor

    desc 'scan', 'Scan directory and DB for differences'
    def scan
      db    = MusicComparator::Database.new
      conditions.each do |condition|
        to_copy, to_delete = diff db.scan_for(condition), MusicComparator::Files.scan_for(condition)

        unless to_copy.empty? && to_delete.empty?
          puts "[ -- #{ condition.path } -- ]"

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

    desc 'remove_original_mix PATH', "Remove 'Original Mix' from music tags"
    method_option :jobs, aliases: '-j', default: -1, type: :numeric, banner: 'Number of threads'
    def remove_original_mix(path)
      MusicComparator::Corrector.remove_original_mix path, options
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