require 'music_comparator/corrector'

describe MusicComparator::Corrector do

  describe '#correct_title_feat' do

    def common_part(options)
      feat_artist = 'Second Artist'
      remix  = 'Artist 2 Remix'
      title  = 'Title'
      artist = 'Artist'

      title_before_corrections = options[:pattern].gsub('feat', "#{options[:feat_shortcut]} #{feat_artist}").gsub('title', title).gsub('remix', remix)

      title_correct_to = title
      if options[:pattern].include?('remix')
        title_correct_to += " (#{remix})"
      end

      subject.send :init, artist, title_before_corrections
      subject.send :correct_title_feat

      if options[:check] == :artist
        expect(subject.instance_variable_get(:@artist)).to eq("#{artist} feat. #{feat_artist}")
      else
        expect(subject.instance_variable_get(:@title)).to eq(title_correct_to)
      end
    end

    %w(featuring Featuring feat feat. Feat Feat. ft ft.).each do |feat_shortcut|
      ['title (feat)', 'title feat', 'title - feat', 'title (feat) (remix)', 'title feat (remix)', 'title (feat - remix)'].each do |pattern|
        context "with shortcut '#{feat_shortcut}' and pattern '#{pattern}'" do

          it 'sets correct artist' do
            common_part pattern: pattern, feat_shortcut: feat_shortcut, check: :artist
          end

          it 'sets correct title' do
            common_part pattern: pattern, feat_shortcut: feat_shortcut, check: :title
          end
        end
      end
    end

  end

end
