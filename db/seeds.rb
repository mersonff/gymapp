# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'faker'

User.create ([{
  username: "leolemos",
  password: "123456",
  email: "hardtraining2019@gmail.com",
  business_name: "Hard Training"
}])

Plan.create ([{
  description: "5 Dias - Todos os dias",
  value: 50.0,
  user_id: 1
}])

Plan.create ([{
  description: "3 Dias - Três dias na semana",
  value: 35.0,
  user_id: 1
}])

50.times do 
    Client.create ([{
      name: Faker::Name.unique.name,
      birthdate: Faker::Date.birthday(min_age: 18, max_age: 65),
      address: Faker::Address.full_address,
      gender: "Feminino",
      cellphone: Faker::PhoneNumber.subscriber_number(length: 11),
      user_id: 1
    }])
end

50.times do 
    Client.create ([{
      name: Faker::Name.unique.name,
      birthdate: Faker::Date.birthday(min_age: 18, max_age: 65),
      address: Faker::Address.full_address,
      cellphone: Faker::PhoneNumber.subscriber_number(length: 11),
      gender: "Masculino",
      user_id: 1
    }])
end

for i in 1..100
  for j in 0..23
    date = Time.zone.now - 25.month
    Payment.create ([{
      payment_date: date + j.month,
      value: 50.0,
      client_id: i
    }])
  end
end

for j in 1..100
  for i in 0..23
    date = Time.zone.now - 25.month
    Measurement.create ([{
      created_at: date + i.month,
      height: 150 + i,
      weight: 50 + i,
      chest: 1 + i,
      left_arm: 1 + i,
      right_arm: 1 + i,
      waist: 1 + i,
      abdomen: 1 + i,
      hips: 1 + i,
      left_thigh: 1 + i,
      righ_thigh: 1 + i,
      client_id: j
    }])
  end
end

for j in 1..100
  for i in 0..23
    date = Time.zone.now - 25.month
    Skinfold.create ([{
      created_at: date + i.month,
      chest: 1 + i,
      subscapular: 1 + i,
      midaxilary: 1 + i,
      bicep: 1 + i,
      tricep: 1 + i,
      abdominal: 1 + i,
      suprailiac: 1 + i,
      thigh: 1 + i,
      calf: 1 + i,
      client_id: j
    }])
  end
end

