class Client < ApplicationRecord
  
  has_many :payments, dependent: :destroy
  has_many :measurements, dependent: :destroy
  has_many :skinfolds, dependent: :destroy
  
  belongs_to :user
  
  accepts_nested_attributes_for :measurements
  accepts_nested_attributes_for :skinfolds
  accepts_nested_attributes_for :payments
  
  validates :name, presence: true, uniqueness: { case_sensitive: false }, 
            length: { minimum: 3, maximum: 25 }
  validates :birthdate, presence: true
  
  
  def fat_percentage(skinfold_id)
    skinfold = Skinfold.find(skinfold_id)
    
    total = skinfold.chest + 
            skinfold.midaxilary +
            skinfold.subscapular +
            skinfold.tricep +
            skinfold.abdominal +
            skinfold.suprailiac +
            skinfold.thigh 
    
    age = ((Time.zone.now - self.birthdate.to_time) / 1.year.seconds).floor 
    
    client = Client.find(skinfold.client_id)
    
    if client.gender == "Masculino"
      body_density = 1.112 - ( 0.00043499 * total ) + (0.00000055 * (total * total)) - (0.00028826 * age)
    else
      body_density = 1.097 - ( 0.00046971 * total ) + (0.00000056 * (total * total)) - (0.00012828 * age)
    end
    
    body_fat = (495 / body_density) - 450

    return body_fat.round(1)
  end
  
end