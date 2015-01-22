require 'thor'

require 'colorize'
require 'condition'
require 'corrector'
require 'database'
require 'files'

module MusicComparator
  class Cli < Thor

    desc 'scan', 'Scan directory and DB for differences'
    def scan
      compute_changes
      output = generate_scan_output
      puts output unless output.empty?
    end

    desc 'remove_original_mix PATH', "Remove 'Original Mix' from music tags"
    method_option :jobs, aliases: '-j', default: -1, type: :numeric, banner: 'Number of threads'
    def remove_original_mix(path)
      MusicComparator::Corrector.remove_original_mix path, options
    end

    private

    def conditions
      @result ||= begin
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

    end

    def compute_changes
      db    = MusicComparator::Database.new

      conditions.each do |condition|
        condition.all_files, condition.to_copy, condition.to_delete = diff db.scan_for(condition), MusicComparator::Files.scan_for(condition)
      end
    end

    def generate_scan_output
      result = ''
      conditions.each do |condition|
        next unless condition.has_changes?

        result += "#{'['.yellow.bold} #{condition.path.green} #{']'.yellow.bold}\n"
        if condition.has_to_copy?
          condition.to_copy.each do |file_to_copy|
            result += "#{file_to_copy.green}\n"
          end
        end

        if condition.has_to_delete?
          condition.to_delete.each do |file_to_delete|
            result += file_to_delete.red

            if moved_to = file_moved(file_to_delete, condition.path)
              result += '  ' + '>>'.white.bold
              if moved_to[:exists]
                result += "  #{ moved_to[:path].magenta } (file already exists)"
              else
                result += "  #{ moved_to[:path].cyan }"
              end
            end

            result += "\n"
          end
        end
      end

      result
    end

    def file_moved(file, moved_from)
      result = nil

      conditions.each do |condition|
        next if condition.path == moved_from

        if condition.all_files.include?(file)
          result = { path: condition.path, exists: !condition.to_copy.include?(file) }
          break
        end
      end

      result
    end

    def diff(db, files)
      db_prepared = db.map { |row| row[:rpath].split('/')[-1] }
      files_prepared = files.map { |file| file.split('/')[-1] }

      to_delete = files_prepared - db_prepared
      to_copy = db_prepared - files_prepared

      [db_prepared, to_copy, to_delete]
    end

  end
end