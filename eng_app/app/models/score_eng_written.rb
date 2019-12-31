class ScoreEngWritten < Score
  before_create do
    if self.passed
      self.val = 2
    else
      self.val = -2
    end
  end
end
