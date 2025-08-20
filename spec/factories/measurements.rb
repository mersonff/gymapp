FactoryBot.define do
  factory :measurement do
    height { Faker::Number.between(from: 150, to: 200) }
    weight { Faker::Number.between(from: 50, to: 120) }
    chest { Faker::Number.between(from: 80, to: 120) }
    left_arm { Faker::Number.between(from: 25, to: 45) }
    right_arm { Faker::Number.between(from: 25, to: 45) }
    waist { Faker::Number.between(from: 60, to: 100) }
    abdomen { Faker::Number.between(from: 70, to: 110) }
    hips { Faker::Number.between(from: 80, to: 120) }
    left_thigh { Faker::Number.between(from: 40, to: 70) }
    righ_thigh { Faker::Number.between(from: 40, to: 70) }
    client
  end
end
