require 'rails_helper'

RSpec.describe ClientPresenter, type: :presenter do
  let(:user) { create(:user) }
  let(:plan) { create(:plan, description: 'Premium Plan', value: 99.99, user: user) }
  let(:client) { create(:client, user: user, plan: plan, birthdate: 25.years.ago) }
  let(:presenter) { described_class.new(client) }

  describe '#initialize' do
    it 'sets the client' do
      expect(presenter.instance_variable_get(:@client)).to eq(client)
    end
  end

  describe '#name' do
    it 'returns the client name' do
      expect(presenter.name).to eq(client.name)
    end

    it 'handles nil name gracefully' do
      client.name = nil
      expect(presenter.name).to be_nil
    end
  end

  describe '#age' do
    it 'calculates and returns the client age' do
      expected_age = ((Date.current - client.birthdate) / 365.25).floor
      expect(presenter.age).to eq(expected_age)
    end

    it 'returns nil when birthdate is nil' do
      client.birthdate = nil
      expect(presenter.age).to be_nil
    end
  end

  describe '#formatted_phone' do
    it 'returns formatted phone number' do
      client.cellphone = '11999999999'
      expect(presenter.formatted_phone).to eq('(11) 99999-9999')
    end

    it 'returns original phone if formatting fails' do
      client.cellphone = 'invalid-phone'
      expect(presenter.formatted_phone).to eq('invalid-phone')
    end

    it 'handles nil phone gracefully' do
      client.cellphone = nil
      expect(presenter.formatted_phone).to be_nil
    end
  end

  describe '#plan_name' do
    it 'returns the plan description' do
      expect(presenter.plan_name).to eq('Premium Plan')
    end

    it 'returns "Sem plano" when plan is nil' do
      client.plan = nil
      expect(presenter.plan_name).to eq('Sem plano')
    end
  end

  describe '#plan_price' do
    it 'returns formatted plan price' do
      expect(presenter.plan_price).to eq('R$ 99,99')
    end

    it 'returns "N/A" when plan is nil' do
      client.plan = nil
      expect(presenter.plan_price).to eq('N/A')
    end

    it 'handles zero price' do
      plan.update(value: 0)
      expect(presenter.plan_price).to eq('R$ 0,00')
    end
  end

  describe '#registration_date' do
    it 'returns formatted registration date' do
      client.registration_date = Date.new(2023, 12, 25)
      expect(presenter.registration_date).to eq('25/12/2023')
    end

    it 'returns nil when registration_date is nil' do
      client.registration_date = nil
      expect(presenter.registration_date).to be_nil
    end
  end

  describe '#status' do
    context 'when client has no payments' do
      it 'returns "Em dia"' do
        expect(presenter.status).to eq('Em dia')
      end
    end

    context 'when client has current payments' do
      before do
        create(:payment, client: client, payday: Date.current)
      end

      it 'returns "Em dia"' do
        expect(presenter.status).to eq('Em dia')
      end
    end

    context 'when client has overdue payments' do
      before do
        create(:payment, client: client, payday: 1.week.ago)
      end

      it 'returns "Inadimplente"' do
        expect(presenter.status).to eq('Inadimplente')
      end
    end

    context 'when client has mixed payments' do
      before do
        create(:payment, client: client, payday: 1.week.ago)    # overdue
        create(:payment, client: client, payday: Date.current)  # current
      end

      it 'returns "Em dia" (prioritizes current payments)' do
        expect(presenter.status).to eq('Em dia')
      end
    end
  end

  describe '#status_color' do
    context 'when status is "Em dia"' do
      before do
        create(:payment, client: client, payday: Date.current)
      end

      it 'returns green color class' do
        expect(presenter.status_color).to eq('text-green-600 bg-green-50')
      end
    end

    context 'when status is "Inadimplente"' do
      before do
        create(:payment, client: client, payday: 1.week.ago)
      end

      it 'returns red color class' do
        expect(presenter.status_color).to eq('text-red-600 bg-red-50')
      end
    end
  end

  describe '#latest_measurement' do
    context 'when client has measurements' do
      let!(:old_measurement) { create(:measurement, client: client, created_at: 2.days.ago) }
      let!(:recent_measurement) { create(:measurement, client: client, created_at: 1.day.ago) }

      it 'returns the most recent measurement' do
        expect(presenter.latest_measurement).to eq(recent_measurement)
      end
    end

    context 'when client has no measurements' do
      it 'returns nil' do
        expect(presenter.latest_measurement).to be_nil
      end
    end
  end

  describe '#latest_weight' do
    context 'when client has measurements with weight' do
      let!(:measurement) { create(:measurement, client: client, weight: 75) }

      it 'returns formatted weight' do
        expect(presenter.latest_weight).to eq('75 kg')
      end
    end

    context 'when latest measurement has no weight' do
      let!(:measurement) do
        m = build(:measurement, client: client)
        m.save(validate: false) # Skip validation to allow nil weight
        m.update_column(:weight, nil) # Directly update column to nil
        m
      end

      it 'returns "N/A"' do
        expect(presenter.latest_weight).to eq('N/A')
      end
    end

    context 'when client has no measurements' do
      it 'returns "N/A"' do
        expect(presenter.latest_weight).to eq('N/A')
      end
    end
  end

  describe '#latest_height' do
    context 'when client has measurements with height' do
      let!(:measurement) { create(:measurement, client: client, height: 180) }

      it 'returns formatted height' do
        expect(presenter.latest_height).to eq('180 cm')
      end
    end

    context 'when latest measurement has no height' do
      let!(:measurement) do
        m = build(:measurement, client: client)
        m.save(validate: false)
        m.update_column(:height, nil)
        m
      end

      it 'returns "N/A"' do
        expect(presenter.latest_height).to eq('N/A')
      end
    end

    context 'when client has no measurements' do
      it 'returns "N/A"' do
        expect(presenter.latest_height).to eq('N/A')
      end
    end
  end

  describe '#bmi' do
    context 'when client has valid height and weight' do
      let!(:measurement) { create(:measurement, client: client, height: 180, weight: 75) }

      it 'returns formatted BMI' do
        expected_bmi = 75.0 / ((180.0 / 100)**2)
        expect(presenter.bmi).to eq('%.1f' % expected_bmi)
      end
    end

    context 'when client has invalid measurements' do
      let!(:measurement) do
        m = build(:measurement, client: client, weight: 75)
        m.save(validate: false)
        m.update_column(:height, nil)
        m
      end

      it 'returns "N/A"' do
        expect(presenter.bmi).to eq('N/A')
      end
    end

    context 'when client has no measurements' do
      it 'returns "N/A"' do
        expect(presenter.bmi).to eq('N/A')
      end
    end
  end

  describe '#latest_body_fat' do
    context 'when client has skinfolds' do
      let(:male_client) { create(:client, :male, user: user, plan: plan, birthdate: 25.years.ago) }
      let!(:skinfold) { create(:skinfold, client: male_client, chest: 10.0, abdominal: 15.0, thigh: 12.0) }

      it 'returns formatted body fat percentage' do
        male_presenter = described_class.new(male_client)
        result = male_presenter.latest_body_fat
        expect(result).to match(/\d+\.\d+%/)
      end
    end

    context 'when body fat calculation returns nil' do
      let!(:skinfold) { create(:skinfold, client: client, chest: 0, abdomen: 0, thigh: 0) }

      it 'returns "N/A"' do
        expect(presenter.latest_body_fat).to eq('N/A')
      end
    end

    context 'when client has no skinfolds' do
      it 'returns "N/A"' do
        expect(presenter.latest_body_fat).to eq('N/A')
      end
    end
  end

  describe '#payment_count' do
    it 'returns zero when client has no payments' do
      expect(presenter.payment_count).to eq(0)
    end

    it 'returns correct count of payments' do
      create_list(:payment, 3, client: client)
      expect(presenter.payment_count).to eq(3)
    end
  end

  describe '#next_payment_date' do
    context 'when client has future payments' do
      let!(:future_payment) { create(:payment, client: client, payday: 1.week.from_now) }

      it 'returns formatted next payment date' do
        expected_date = 1.week.from_now.strftime('%d/%m/%Y')
        expect(presenter.next_payment_date).to eq(expected_date)
      end
    end

    context 'when client has no future payments' do
      before do
        create(:payment, client: client, payday: 1.week.ago)
      end

      it 'returns "N/A"' do
        expect(presenter.next_payment_date).to eq('N/A')
      end
    end

    context 'when client has no payments' do
      it 'returns "N/A"' do
        expect(presenter.next_payment_date).to eq('N/A')
      end
    end
  end

  describe '#gender_display' do
    it 'returns "Masculino" for male clients' do
      client.gender = 'M'
      expect(presenter.gender_display).to eq('Masculino')
    end

    it 'returns "Feminino" for female clients' do
      client.gender = 'F'
      expect(presenter.gender_display).to eq('Feminino')
    end

    it 'returns "Outro" for other gender' do
      client.gender = 'O'
      expect(presenter.gender_display).to eq('Outro')
    end

    it 'returns original value for unknown gender' do
      client.gender = 'X'
      expect(presenter.gender_display).to eq('X')
    end
  end

  describe 'delegation' do
    it 'delegates other methods to the client object' do
      expect(presenter.id).to eq(client.id)
      expect(presenter.address).to eq(client.address)
      expect(presenter.created_at).to eq(client.created_at)
    end

    it 'responds to client methods' do
      expect(presenter).to respond_to(:id)
      expect(presenter).to respond_to(:address)
      expect(presenter).to respond_to(:created_at)
    end
  end

  describe 'edge cases' do
    it 'handles very old clients' do
      client.birthdate = 100.years.ago
      expect(presenter.age).to be >= 99
    end

    it 'handles clients born today' do
      client.birthdate = Date.current
      expect(presenter.age).to eq(0)
    end

    it 'handles very large phone numbers' do
      client.cellphone = '1' * 20
      expect(presenter.formatted_phone).to eq('1' * 20)
    end

    it 'handles very large plan prices' do
      plan.update(value: 999_999.99)
      expect(presenter.plan_price).to eq('R$ 999999,99')
    end
  end
end
