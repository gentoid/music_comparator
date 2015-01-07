module MusicComparator
  class Condition

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

    def has_eq?(label)
      @eq_labels.include? label
    end

    def rating_with_leading_zero
      rating.to_s.rjust 2, '0'
    end

  end
end
