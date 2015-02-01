require 'thor'

require 'colorize'
require 'config'
require 'condition'
require 'corrector'
require 'database'
require 'files'
require 'models/mp3_info'
require 'parallel'

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

    desc 'find_duplicates', 'Find duplicates'
    method_option :path, aliases: '-p', default: nil, type: :string, banner: 'Path to scan for duplicates, if not given path will be taken from config file'
    method_option :jobs, aliases: '-j', default: -1, type: :numeric, banner: 'Number of threads'
    def find_duplicates
      Mongoid.load!(File.join(File.dirname(__FILE__), '..', '..', 'mongoid.yml'), :development)

      parallel_options = {progress: 'Saving file info into DB'}
      parallel_options[:in_processes] = options[:jobs].floor if options[:jobs] >= 0

      paths = options[:path] ? options[:path] : MusicComparator::Config.all_music_paths

      # MusicComparator::Models::MP3Info.delete_all

      Parallel.each(MusicComparator::Files.mp3_files(paths), parallel_options) do |filename|
        MusicComparator::Models::MP3Info.new(filename: filename).save
      end


      #[15] pry(main)> MusicComparator::Models::MP3Info.collection.aggregate(
      # [15] pry(main)*   {'$group' => { '_id' => { 'a' => '$a', 't' => '$t' }, 'uniqueIds' => { '$addToSet' => '$_id' }, 'count' => { '$sum' => 1 } }},
      #     [15] pry(main)*   { '$match' => { 'count' => { '$gte' => 2 } }},
      #     [15] pry(main)*   { '$sort' => { 'count' => -1 }},
      #     [15] pry(main)* )

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

            if (moved_to = file_moved(file_to_delete, condition.path))
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