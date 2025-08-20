require 'rails_helper'

RSpec.describe Plan do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:value) }
    it { is_expected.to validate_length_of(:description).is_at_least(10).is_at_most(300) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      plan = build(:plan)
      expect(plan).to be_valid
    end
  end

  describe 'value validation' do
    it 'accepts positive values' do
      plan = build(:plan, value: 99.99)
      expect(plan).to be_valid
    end

    it 'accepts zero value' do
      plan = build(:plan, value: 0)
      expect(plan).to be_valid
    end

    it 'accepts negative values' do
      plan = build(:plan, value: -10.50)
      expect(plan).to be_valid
    end
  end

  describe 'description validation' do
    it 'rejects descriptions that are too short' do
      plan = build(:plan, description: 'Short')
      expect(plan).not_to be_valid
    end

    it 'rejects descriptions that are too long' do
      plan = build(:plan, description: 'a' * 301)
      expect(plan).not_to be_valid
    end

    it 'accepts descriptions within valid range' do
      plan = build(:plan, description: 'This is a valid description that meets the minimum length requirement.')
      expect(plan).to be_valid
    end
  end

  describe '#plan_string' do
    it 'returns formatted plan string with value and description' do
      plan = create(:plan, value: 99.99, description: 'Premium Membership Plan')
      result = plan.plan_string

      expect(result).to include('R$ 99,99')
      expect(result).to include('Premium Membership Plan')
    end

    it 'handles zero value correctly' do
      plan = create(:plan, value: 0, description: 'Free Plan for basic membership')
      result = plan.plan_string

      expect(result).to include('R$ 0,00')
      expect(result).to include('Free Plan for basic membership')
    end
  end

  describe 'scopes and methods' do
    let(:user) { create(:user) }
    let!(:expensive_plan) { create(:plan, value: 199.99, user: user) }
    let!(:cheap_plan) { create(:plan, value: 49.99, user: user) }

    it 'orders plans by value' do
      plans = user.plans.order(:value)
      expect(plans.first).to eq(cheap_plan)
      expect(plans.last).to eq(expensive_plan)
    end
  end
end
