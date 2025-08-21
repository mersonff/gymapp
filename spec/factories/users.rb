FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user_#{n} #{SecureRandom.hex(4)}" }
    email { Faker::Internet.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    sequence(:business_name) { |n| "#{Faker::Company.name} #{n}" }
  end
end
