module MusicComparator
  class Conditions

    attr_accessor :rating
    attr_reader :eq_labels, :not_eq_labels

    def initialize
      @eq_labels = []
      @not_eq_labels = []
    end

    def eq(label)
      @eq_labels << label
      self
    end

    def not_eq(label)
      @not_eq_labels << label
      self
    end

    def all_labels
      @eq_labels + @not_eq_labels
    end

  end
end
