class Client < ApplicationRecord
  include PaymentTrackable

  has_many :payments, dependent: :destroy
  has_many :measurements, dependent: :destroy
  has_many :skinfolds, dependent: :destroy

  belongs_to :user
  belongs_to :plan, optional: true

  accepts_nested_attributes_for :measurements, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :skinfolds, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :payments, reject_if: :all_blank, allow_destroy: true

  validates :name, presence: true, uniqueness: { case_sensitive: false },
                   length: { minimum: 3, maximum: 50 }
  validates :birthdate, presence: true
  validate :birthdate_cannot_be_in_future
  validates :cellphone, presence: true
  validates :gender, presence: true, inclusion: { in: %w[M F O] }

  before_create :set_registration_date

  def age
    return nil unless birthdate

    ((Date.current - birthdate) / 365.25).floor
  end

  def latest_measurement
    measurements.order(:created_at).last
  end

  def latest_skinfold
    skinfolds.order(:created_at).last
  end

  private

  def set_registration_date
    self.registration_date ||= Date.current
  end

  def birthdate_cannot_be_in_future
    return unless birthdate

    errors.add(:birthdate, "can't be in the future") if birthdate > Date.current
  end

  # Delegate cálculo de gordura corporal para o service
  def fat_percentage(skinfold_id)
    skinfold = skinfolds.find(skinfold_id)
    BodyFatCalculatorService.new(client: self, skinfold: skinfold).calculate
  end

  # Método mantido para compatibilidade, mas agora usa concern
  def days_in_debt
    days_overdue
  end
end
