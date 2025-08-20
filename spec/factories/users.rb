FactoryBot.define do
  factory :user do
    username { Faker::Internet.username(specifier: 3..30) }
    email { Faker::Internet.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    business_name { Faker::Company.name }
  end
end
