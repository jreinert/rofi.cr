module Rofi
  enum MatchingMethod
    Normal
    Regex
    Glob
    Fuzzy

    def to_s
      super.underscore
    end
  end
end
