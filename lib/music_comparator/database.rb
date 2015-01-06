require 'mysql2'
require 'conditions'

module MusicComparator
  class Database

    def initialize
      @client = Mysql2::Client.new host: 'localhost', username: 'amarok', password: 'amarok', database: 'amarokdb'
    end

    def scan
      result = []

      (8..10).each do |rating|
        conditions = MusicComparator::Conditions.new
        conditions
            .eq(:checked)
            .not_eq(:wordless)
            .rating = rating
        result << { conditions: conditions, result: scan_for(conditions) }
      end

      (7..10).each do |rating|
        conditions = MusicComparator::Conditions.new
        conditions
            .eq(:checked)
            .eq(:wordless)
            .rating = rating
        result << { conditions: conditions, result: scan_for(conditions) }
      end

      result
    end

    def scan_for(conditions)
      joins = ['LEFT JOIN statistics AS s ON u.id = s.url']
      conditions.all_labels.each_with_index do |label, i|
        joins << "LEFT JOIN (SELECT url AS url_id, true AS #{label} FROM urls_labels AS ul#{i} "\
          "LEFT JOIN labels AS l#{i} ON ul#{i}.label = l#{i}.id WHERE l#{i}.label = '#{label}') AS t#{i} ON u.id = t#{i}.url_id"
      end

      where_parts = ["rating = #{conditions.rating}"]
      conditions.eq_labels.each     { |label| where_parts << "#{label} IS true" }
      conditions.not_eq_labels.each { |label| where_parts << "#{label} IS null" }

      query = "SELECT u.rpath FROM urls AS u #{joins.join ' '} WHERE #{where_parts.join ' AND '}"

      @client.query(query, symbolize_keys: true).to_a.map { |file_path| file_path[:rpath].split('/')[-1] if file_path[:rpath] }.compact
    end

  end
end
