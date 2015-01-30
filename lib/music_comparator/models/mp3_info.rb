# require 'mongoid/document'
require 'mongoid'
require 'taglib'

module MusicComparator
  module Models
    class MP3Info
      include Mongoid::Document

      field :f, as: :filename,  type: String
      field :a, as: :artist,    type: String
      field :t, as: :title,     type: String
      field :r, as: :rating,    type: Integer
      field :s, as: :score,     type: String
      field :p, as: :playcount, type: Integer

      attr_readonly :rating, :score, :playcount

      before_create :prepare_info

      protected

      def prepare_info
        TagLib::MPEG::File.open(filename) do |mp3|
          tags = mp3.id3v2_tag
          parse_txxx tags.frame_list('TXXX')

          self.artist = tags.artist
          self.title = tags.title
        end
      end

      def parse_txxx(frame_list)
        frame_list.each do |frame|
          field, value = frame.field_list
          case field.to_s
            when 'FMPS_Rating'
              self.rating = (value.to_f * 10).round
            when 'FMPS_Rating_Amarok_Score'
              self.score = value
            when 'FMPS_Playcount'
              self.playcount = value.to_i
          end
        end
      end

    end
  end
end
