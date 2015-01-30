require 'facets/hash/deep_rekey'
require 'yaml'

module MusicComparator
  class Config

    class << self

      def config
        @config ||= YAML.load(File.read(File.join(File.expand_path(File.dirname(__FILE__)),'..','..','config.yml'))).deep_rekey
      end

      def all_music_paths
        music_collection_paths + download_music_paths
      end

      def music_collection_paths
        config[:paths][:music_collection]
      end

      def download_music_paths
        config[:paths][:downloaded_music]
      end

    end

  end
end
