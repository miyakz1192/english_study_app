class ScoreEngWritten < Score
  belongs_to :user
  belongs_to :sentence

  before_create do
    if self.passed
      self.val = 2
    else
      self.val = -2
    end
  end
end
