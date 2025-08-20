require 'rails_helper'

RSpec.describe Skinfold do
  describe 'associations' do
    it { is_expected.to belong_to(:client) }
  end

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:chest).is_greater_than_or_equal_to(0).allow_nil }
    it { is_expected.to validate_numericality_of(:abdominal).is_greater_than_or_equal_to(0).allow_nil }
    it { is_expected.to validate_numericality_of(:thigh).is_greater_than_or_equal_to(0).allow_nil }
    it { is_expected.to validate_numericality_of(:tricep).is_greater_than_or_equal_to(0).allow_nil }
    it { is_expected.to validate_numericality_of(:subscapular).is_greater_than_or_equal_to(0).allow_nil }
    it { is_expected.to validate_numericality_of(:suprailiac).is_greater_than_or_equal_to(0).allow_nil }
    it { is_expected.to validate_numericality_of(:midaxilary).is_greater_than_or_equal_to(0).allow_nil }
    it { is_expected.to validate_numericality_of(:bicep).is_greater_than_or_equal_to(0).allow_nil }
    it { is_expected.to validate_numericality_of(:lower_back).is_greater_than_or_equal_to(0).allow_nil }
    it { is_expected.to validate_numericality_of(:calf).is_greater_than_or_equal_to(0).allow_nil }
  end

  describe 'factory' do
    it 'has a valid factory' do
      skinfold = build(:skinfold)
      expect(skinfold).to be_valid
    end
  end

  describe 'default values' do
    it 'sets default values to 0.0' do
      skinfold = described_class.new
      expect(skinfold.chest).to eq(0.0)
      expect(skinfold.abdomen).to eq(0.0)
      expect(skinfold.thigh).to eq(0.0)
      expect(skinfold.triceps).to eq(0.0)
      expect(skinfold.subscapular).to eq(0.0)
      expect(skinfold.suprailiac).to eq(0.0)
      expect(skinfold.midaxillary).to eq(0.0)
    end
  end

  describe '#body_fat_percentage' do
    let(:male_client) { create(:client, :male, birthdate: 25.years.ago) }
    let(:female_client) { create(:client, :female, birthdate: 25.years.ago) }

    context 'for male clients' do
      it 'calculates body fat percentage using 3-site formula' do
        skinfold = create(:skinfold,
                          client: male_client,
                          chest: 10.0,
                          abdomen: 15.0,
                          thigh: 12.0)

        # Should use BodyFatCalculatorService
        expect(skinfold.body_fat_percentage).to be_a(Numeric)
        expect(skinfold.body_fat_percentage).to be > 0
      end
    end

    context 'for female clients' do
      it 'calculates body fat percentage using 3-site formula' do
        skinfold = create(:skinfold,
                          client: female_client,
                          triceps: 15.0,
                          suprailiac: 12.0,
                          thigh: 18.0)

        # Should use BodyFatCalculatorService
        expect(skinfold.body_fat_percentage).to be_a(Numeric)
        expect(skinfold.body_fat_percentage).to be > 0
      end
    end

    it 'returns nil when required measurements are missing' do
      skinfold = create(:skinfold, client: male_client, chest: 0, abdomen: 0, thigh: 0)
      expect(skinfold.body_fat_percentage).to be_nil
    end
  end

  describe 'decimal precision' do
    it 'stores decimal values correctly' do
      skinfold = create(:skinfold, chest: 10.25, abdomen: 15.75)
      skinfold.reload

      expect(skinfold.chest).to eq(10.25)
      expect(skinfold.abdomen).to eq(15.75)
    end

    it 'handles precise decimal values' do
      skinfold = create(:skinfold, chest: 9.99, abdomen: 12.01)
      skinfold.reload

      expect(skinfold.chest).to eq(9.99)
      expect(skinfold.abdomen).to eq(12.01)
    end
  end

  describe 'validation' do
    it 'accepts zero values' do
      skinfold = build(:skinfold, chest: 0.0, abdomen: 0.0)
      expect(skinfold).to be_valid
    end

    it 'accepts positive decimal values' do
      skinfold = build(:skinfold, chest: 15.5, abdomen: 20.25)
      expect(skinfold).to be_valid
    end

    it 'rejects negative values' do
      skinfold = build(:skinfold, chest: -5.0)
      expect(skinfold).not_to be_valid
    end

    it 'accepts nil values' do
      skinfold = build(:skinfold, chest: nil, abdomen: nil)
      expect(skinfold).to be_valid
    end
  end
end
