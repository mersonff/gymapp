class Skinfold < ApplicationRecord
  belongs_to :client
  
  validates :chest, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :abdominal, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :thigh, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :tricep, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :subscapular, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :suprailiac, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :midaxilary, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :bicep, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :lower_back, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :calf, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  
  # Aliases for compatibility
  alias_attribute :abdomen, :abdominal
  alias_attribute :triceps, :tricep
  alias_attribute :midaxillary, :midaxilary
  
  def body_fat_percentage
    service = BodyFatCalculatorService.new(client)
    service.calculate_for_skinfold(self)
  end
end