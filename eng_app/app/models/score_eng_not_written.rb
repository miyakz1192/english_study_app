class ScoreEngNotWritten < Score
  before_create do
    if self.passed
      self.val = 1
    else
      self.val = -1
    end
  end
end
