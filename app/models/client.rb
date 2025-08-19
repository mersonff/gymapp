class Client < ApplicationRecord
  include PaymentTrackable
  
  has_many :payments, dependent: :destroy
  has_many :measurements, dependent: :destroy
  has_many :skinfolds, dependent: :destroy
  
  belongs_to :user
  
  accepts_nested_attributes_for :measurements, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :skinfolds, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :payments, reject_if: :all_blank, allow_destroy: true
  
  validates :name, presence: true, uniqueness: { case_sensitive: false }, 
            length: { minimum: 3, maximum: 50 }
  validates :birthdate, presence: true
  
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