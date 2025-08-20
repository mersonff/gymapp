FactoryBot.define do
  factory :client do
    sequence(:name) { |n| "Client #{n}" }
    cellphone { Faker::PhoneNumber.cell_phone }
    address { Faker::Address.full_address }
    birthdate { Faker::Date.birthday(min_age: 18, max_age: 65) }
    gender { %w[M F O].sample }
    registration_date { Faker::Date.between(from: 1.year.ago, to: Date.current) }
    user
    plan

    trait :male do
      gender { 'M' }
    end

    trait :female do
      gender { 'F' }
    end

    trait :with_measurements do
      after(:create) do |client|
        create(:measurement, client: client)
      end
    end

    trait :with_payments do
      after(:create) do |client|
        create_list(:payment, 3, client: client)
      end
    end

    trait :with_skinfolds do
      after(:create) do |client|
        create(:skinfold, client: client)
      end
    end

    trait :overdue do
      after(:create) do |client|
        create(:payment, :overdue, client: client)
      end
    end
  end
end
