class ScoreEngNotWritten < Score
  belongs_to :user
  belongs_to :sentence

  before_create do
    if self.passed
      self.val = 1
    else
      self.val = -1
    end
  end
end
