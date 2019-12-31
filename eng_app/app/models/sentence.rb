class Sentence < ApplicationRecord
  has_many :scores , dependent: :destroy
end
