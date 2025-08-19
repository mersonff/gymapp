FactoryBot.define do
  factory :plan do
    description { Faker::Lorem.sentence(word_count: 10) }
    value { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    user
  end
end