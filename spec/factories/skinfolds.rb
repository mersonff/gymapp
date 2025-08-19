FactoryBot.define do
  factory :skinfold do
    chest { Faker::Number.decimal(l_digits: 1, r_digits: 2) }
    abdominal { Faker::Number.decimal(l_digits: 1, r_digits: 2) }
    thigh { Faker::Number.decimal(l_digits: 1, r_digits: 2) }
    tricep { Faker::Number.decimal(l_digits: 1, r_digits: 2) }
    subscapular { Faker::Number.decimal(l_digits: 1, r_digits: 2) }
    suprailiac { Faker::Number.decimal(l_digits: 1, r_digits: 2) }
    midaxilary { Faker::Number.decimal(l_digits: 1, r_digits: 2) }
    bicep { Faker::Number.decimal(l_digits: 1, r_digits: 2) }
    lower_back { Faker::Number.decimal(l_digits: 1, r_digits: 2) }
    calf { Faker::Number.decimal(l_digits: 1, r_digits: 2) }
    client
  end
end