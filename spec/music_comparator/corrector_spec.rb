require 'music_comparator/corrector'

describe MusicComparator::Corrector do

  describe '#correct_title_feat' do

    def common_part(options)
      remix  = 'Artist 2 Remix'
      title  = 'Title'
      artist = 'Artist'

      feat = "#{options[:feat_shortcut]} Featuring Artist"

      title_before_corrections = options[:pattern].gsub('feat', feat).gsub('title', title).gsub('remix', remix)

      subject.instance_variable_set :@artist, artist
      subject.instance_variable_set :@title, title_before_corrections

      subject.send :correct_title_feat

      expect(subject.instance_variable_get(:@artist)).to eq("#{artist} #{feat}")
      expect(subject.instance_variable_get(:@title)).to eq(title)
    end

    %w(feat feat. Feat Feat. ft ft.).each do |feat_shortcut|
      ['title (feat)', 'title feat', 'title - feat', 'title (feat) (remix)', 'title feat (remix)', 'title (feat - remix)'].each do |pattern|
        it "moves feat with shortcut '#{feat_shortcut}' and pattern '#{pattern}' from artist to title" do
          common_part pattern: pattern, feat_shortcut: feat_shortcut
        end
      end
    end

  end

end
