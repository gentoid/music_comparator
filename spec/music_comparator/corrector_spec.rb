require 'music_comparator/corrector'

describe MusicComparator::Corrector do

  describe '#correct_title_feat' do

    def common_part(title_to_correct)
      feat = 'feat. Featuring Artist'
      title = 'Title'
      artist = 'Artist'

      title_to_correct.gsub!('feat', feat).gsub!('title', title)

      subject.instance_variable_set :@artist, artist
      subject.instance_variable_set :@title, title_to_correct

      subject.send :correct_title_feat

      expect(subject.instance_variable_get(:@artist)).to eq("#{artist} #{feat}")
      expect(subject.instance_variable_get(:@title)).to eq(title)
    end

    ['title (feat)', 'title feat', 'title - feat'].each do |pattern|
      it "removes feat from artist '#{pattern}' to title" do
        common_part pattern
      end
    end

  end

end
