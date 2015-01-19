module MusicComparator
  class Condition

    attr_accessor :rating, :to_copy, :to_delete, :all_files
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

    def path
      "#{ 'wordless/' if has_eq? :wordless }#{ rating_with_leading_zero }"
    end

    def has_changes?
      has_to_copy? or has_to_delete?
    end

    def has_to_copy?
      !to_copy.empty?
    end

    def has_to_delete?
      !to_delete.empty?
    end

  end
end
