class Payment < ApplicationRecord

  belongs_to :client

  validates :payment_date, presence: true
  validates :value, presence: true
end
