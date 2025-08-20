class Payment < ApplicationRecord
  belongs_to :client

  validates :payment_date, presence: true
  validates :value, presence: true, numericality: { greater_than: 0 }

  alias_attribute :payday, :payment_date

  def overdue?
    payment_date < Date.current
  end
end
