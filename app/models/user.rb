class User < ApplicationRecord
  before_save { self.email = email.downcase if email.present? }

  has_many :plans, dependent: :destroy
  has_many :clients, dependent: :destroy
  
  validates_confirmation_of :password
  validates_confirmation_of :email


  validates :username, presence: true, uniqueness: { case_sensitive: false }, 
            length: { minimum: 3, maximum: 30 }
  validates :business_name, presence: true, uniqueness: { case_sensitive: false }, 
            length: { minimum: 3, maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 105 },
            uniqueness: { case_sensitive: false },
            format: { with: VALID_EMAIL_REGEX }
  has_secure_password
end