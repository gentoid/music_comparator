require 'mysql2'

module MusicComparator
  class Database

    def initialize
      @client = Mysql2::Client.new host: 'localhost', username: 'amarok', password: 'amarok', database: 'amarokdb'
    end

    def scan_for(condition)
      joins = ['LEFT JOIN statistics AS s ON u.id = s.url']
      condition.all_labels.each_with_index do |label, i|
        joins << "LEFT JOIN (SELECT url AS url_id, true AS #{label} FROM urls_labels AS ul#{i} "\
          "LEFT JOIN labels AS l#{i} ON ul#{i}.label = l#{i}.id WHERE l#{i}.label = '#{label}') AS t#{i} ON u.id = t#{i}.url_id"
      end

      where_parts = ["rating = #{condition.rating}"]
      condition.eq_labels.each     { |label| where_parts << "#{label} IS true" }
      condition.not_eq_labels.each { |label| where_parts << "#{label} IS null" }

      query = "SELECT u.id, u.rpath FROM urls AS u #{joins.join ' '} WHERE #{where_parts.join ' AND '}"

      @client.query(query, symbolize_keys: true).to_a
    end

  end
end
