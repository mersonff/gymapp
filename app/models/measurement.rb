class Measurement < ApplicationRecord
  belongs_to :client

  validates :height, numericality: { greater_than: 0, allow_nil: true }
  validates :weight, numericality: { greater_than: 0, allow_nil: true }
  validates :chest, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :left_arm, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :right_arm, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :waist, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :abdomen, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :hips, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :left_thigh, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :righ_thigh, numericality: { greater_than_or_equal_to: 0, allow_nil: true }

  def bmi
    return nil if height.nil? || weight.nil? || height.zero? || weight.zero?

    weight / ((height / 100.0)**2)
  end

  def bmi_category
    return nil unless bmi

    case bmi
    when 0..18.5
      'Abaixo do peso'
    when 18.5..24.9
      'Peso normal'
    when 25..29.9
      'Sobrepeso'
    else
      'Obesidade'
    end
  end
end
