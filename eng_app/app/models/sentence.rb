class Sentence < ApplicationRecord
  has_many :scores , dependent: :destroy
  has_many :score_eng_writtens
  has_many :score_eng_not_writtens

  def score_with(user)
    scores.where(user: user).sum(:val)
  end
end
