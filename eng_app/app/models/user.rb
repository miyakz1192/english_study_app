module UserActionMode
  NORMAL = "normal"
  WORST  = "worst"
end

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :scores
  has_many :score_eng_writtens
  has_many :score_eng_not_writtens

  include UserActionMode

  before_create do
    self.mode = UserActionMode::NORMAL if self.mode.blank?
  end


  #returns configurable setting name and values hash
  #return array of hash
  def configurable_settings
    [{item: "mode", value: self.mode, description: "sentence sequence based on normal(nodemal mode), worst(worst mode)"}]
  end
end
