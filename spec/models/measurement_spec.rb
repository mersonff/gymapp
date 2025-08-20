require 'rails_helper'

RSpec.describe Measurement do
  describe 'associations' do
    it { is_expected.to belong_to(:client) }
  end

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:height).is_greater_than(0).allow_nil }
    it { is_expected.to validate_numericality_of(:weight).is_greater_than(0).allow_nil }
    it { is_expected.to validate_numericality_of(:chest).is_greater_than_or_equal_to(0).allow_nil }
    it { is_expected.to validate_numericality_of(:left_arm).is_greater_than_or_equal_to(0).allow_nil }
    it { is_expected.to validate_numericality_of(:right_arm).is_greater_than_or_equal_to(0).allow_nil }
    it { is_expected.to validate_numericality_of(:waist).is_greater_than_or_equal_to(0).allow_nil }
    it { is_expected.to validate_numericality_of(:abdomen).is_greater_than_or_equal_to(0).allow_nil }
    it { is_expected.to validate_numericality_of(:hips).is_greater_than_or_equal_to(0).allow_nil }
    it { is_expected.to validate_numericality_of(:left_thigh).is_greater_than_or_equal_to(0).allow_nil }
    it { is_expected.to validate_numericality_of(:righ_thigh).is_greater_than_or_equal_to(0).allow_nil }
  end

  describe 'factory' do
    it 'has a valid factory' do
      measurement = build(:measurement)
      expect(measurement).to be_valid
    end
  end

  describe 'default values' do
    it 'sets default values to 0' do
      measurement = described_class.new
      expect(measurement.height).to eq(0)
      expect(measurement.weight).to eq(0)
      expect(measurement.chest).to eq(0)
      expect(measurement.left_arm).to eq(0)
      expect(measurement.right_arm).to eq(0)
      expect(measurement.waist).to eq(0)
      expect(measurement.abdomen).to eq(0)
      expect(measurement.hips).to eq(0)
      expect(measurement.left_thigh).to eq(0)
      expect(measurement.righ_thigh).to eq(0)
    end
  end

  describe '#bmi' do
    it 'calculates BMI correctly' do
      measurement = create(:measurement, height: 170, weight: 70)
      expected_bmi = 70.0 / ((170.0 / 100)**2)
      expect(measurement.bmi).to be_within(0.01).of(expected_bmi)
    end

    it 'returns nil when height is zero' do
      measurement = build(:measurement, height: 0, weight: 70)
      measurement.save(validate: false)
      expect(measurement.bmi).to be_nil
    end

    it 'returns nil when weight is zero' do
      measurement = build(:measurement, height: 170, weight: 0)
      measurement.save(validate: false)
      expect(measurement.bmi).to be_nil
    end
  end

  describe '#bmi_category' do
    it 'returns underweight for BMI < 18.5' do
      measurement = create(:measurement, height: 170, weight: 50)
      expect(measurement.bmi_category).to eq('Abaixo do peso')
    end

    it 'returns normal weight for BMI 18.5-24.9' do
      measurement = create(:measurement, height: 170, weight: 65)
      expect(measurement.bmi_category).to eq('Peso normal')
    end

    it 'returns overweight for BMI 25-29.9' do
      measurement = create(:measurement, height: 170, weight: 80)
      expect(measurement.bmi_category).to eq('Sobrepeso')
    end

    it 'returns obese for BMI >= 30' do
      measurement = create(:measurement, height: 170, weight: 95)
      expect(measurement.bmi_category).to eq('Obesidade')
    end

    it 'returns nil when BMI cannot be calculated' do
      measurement = build(:measurement, height: 0, weight: 70)
      measurement.save(validate: false)
      expect(measurement.bmi_category).to be_nil
    end
  end

  describe 'measurement validation' do
    it 'accepts positive values' do
      measurement = build(:measurement, height: 170, weight: 70)
      expect(measurement).to be_valid
    end

    it 'rejects negative values' do
      measurement = build(:measurement, height: -170)
      expect(measurement).not_to be_valid
    end

    it 'accepts nil values' do
      measurement = build(:measurement, height: nil, weight: nil)
      expect(measurement).to be_valid
    end
  end
end
