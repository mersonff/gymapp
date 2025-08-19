class Plan < ApplicationRecord
  belongs_to :user
  has_many :clients, dependent: :nullify
  
  validates :description, presence: true, length: { minimum: 10, maximum: 300 }
  validates :value, presence: true
  
  def plan_string
    "#{ActionController::Base.helpers.number_to_currency(value, :unit => "R$ ", :separator => ",", :delimiter => "" )} ( #{description} )"
  end
  
end