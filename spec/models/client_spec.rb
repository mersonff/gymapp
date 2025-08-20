require 'rails_helper'

RSpec.describe Client do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:cellphone) }
    it { is_expected.to validate_presence_of(:birthdate) }
    it { is_expected.to validate_presence_of(:gender) }
    it { is_expected.to validate_inclusion_of(:gender).in_array(%w[M F O]) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:plan).optional }
    it { is_expected.to have_many(:measurements).dependent(:destroy) }
    it { is_expected.to have_many(:payments).dependent(:destroy) }
    it { is_expected.to have_many(:skinfolds).dependent(:destroy) }
    it { is_expected.to accept_nested_attributes_for(:measurements) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      client = build(:client)
      expect(client).to be_valid
    end

    it 'creates male clients' do
      male_client = create(:client, :male)
      expect(male_client.gender).to eq('M')
    end

    it 'creates female clients' do
      female_client = create(:client, :female)
      expect(female_client.gender).to eq('F')
    end
  end

  describe 'concerns' do
    it { is_expected.to respond_to(:overdue?) }
    it { is_expected.to respond_to(:current?) }
  end

  describe 'callbacks' do
    it 'sets registration_date before create' do
      client = build(:client, registration_date: nil)
      client.save
      expect(client.registration_date).to eq(Date.current)
    end

    it 'does not override existing registration_date' do
      specific_date = 1.month.ago.to_date
      client = create(:client, registration_date: specific_date)
      expect(client.registration_date).to eq(specific_date)
    end
  end

  describe '#age' do
    it 'calculates age correctly' do
      client = create(:client, birthdate: 25.years.ago.to_date)
      expect(client.age).to be_between(24, 25)
    end

    it 'handles leap years' do
      client = create(:client, birthdate: Date.new(2000, 2, 29))
      expected_age = Date.current.year - 2000
      expected_age -= 1 if Date.current < Date.new(Date.current.year, 2, 28)
      expect(client.age).to eq(expected_age)
    end
  end

  describe '#latest_measurement' do
    let(:client) { create(:client) }

    it 'returns the most recent measurement' do
      create(:measurement, client: client, created_at: 2.days.ago)
      recent_measurement = create(:measurement, client: client, created_at: 1.day.ago)

      expect(client.latest_measurement).to eq(recent_measurement)
    end

    it 'returns nil when no measurements exist' do
      expect(client.latest_measurement).to be_nil
    end
  end

  describe '#latest_skinfold' do
    let(:client) { create(:client) }

    it 'returns the most recent skinfold' do
      create(:skinfold, client: client, created_at: 2.days.ago)
      recent_skinfold = create(:skinfold, client: client, created_at: 1.day.ago)

      expect(client.latest_skinfold).to eq(recent_skinfold)
    end

    it 'returns nil when no skinfolds exist' do
      expect(client.latest_skinfold).to be_nil
    end
  end

  describe 'gender validation' do
    it 'accepts valid gender values' do
      %w[M F O].each do |gender|
        client = build(:client, gender: gender)
        expect(client).to be_valid
      end
    end

    it 'rejects invalid gender values' do
      client = build(:client, gender: 'X')
      expect(client).not_to be_valid
    end
  end

  describe 'birthdate validation' do
    it 'accepts past dates' do
      client = build(:client, birthdate: 25.years.ago.to_date)
      expect(client).to be_valid
    end

    it 'rejects future dates' do
      client = build(:client, birthdate: 1.day.from_now.to_date)
      expect(client).not_to be_valid
    end
  end
end
