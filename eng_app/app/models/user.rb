require "view_model/user_view_model.rb"

module UserActionMode
  NORMAL = "normal"
  TOP    = "top"
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
  include ViewModelBase

  before_create do
    self.mode = UserActionMode::NORMAL if self.mode.blank?
  end
end
