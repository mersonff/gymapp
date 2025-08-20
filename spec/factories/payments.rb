FactoryBot.define do
  factory :payment do
    value { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    payment_date { Faker::Date.between(from: 1.month.ago, to: 1.month.from_now) }
    client

    trait :overdue do
      payment_date { Faker::Date.between(from: 1.year.ago, to: 1.week.ago) }
    end

    trait :future do
      payment_date { Faker::Date.between(from: 1.week.from_now, to: 1.month.from_now) }
    end

    trait :recent do
      payment_date { Faker::Date.between(from: 1.week.ago, to: Date.current) }
    end
  end
end
