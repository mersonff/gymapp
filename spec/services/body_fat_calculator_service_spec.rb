require 'rails_helper'

RSpec.describe BodyFatCalculatorService, type: :service do
  let(:male_client) { create(:client, :male, birthdate: 25.years.ago) }
  let(:female_client) { create(:client, :female, birthdate: 25.years.ago) }

  describe '#initialize' do
    it 'sets the client' do
      service = described_class.new(male_client)
      expect(service.instance_variable_get(:@client)).to eq(male_client)
    end
  end

  describe '#calculate_for_skinfold' do
    context 'for male clients' do
      let(:skinfold) { create(:skinfold, client: male_client, chest: 10.0, abdomen: 15.0, thigh: 12.0) }
      let(:service) { described_class.new(male_client) }

      it 'calculates body fat percentage using Jackson-Pollock 3-site formula for men' do
        result = service.calculate_for_skinfold(skinfold)

        expect(result).to be_a(Numeric)
        expect(result).to be > 0
        expect(result).to be < 50 # reasonable upper bound
      end

      it 'uses correct measurements for male formula (chest, abdomen, thigh)' do
        skinfold = create(:skinfold,
                          client: male_client,
                          chest: 10.0,
                          abdomen: 15.0,
                          thigh: 12.0,
                          triceps: 20.0, # should not be used for males
                          suprailiac: 18.0) # should not be used for males

        result = service.calculate_for_skinfold(skinfold)
        expect(result).to be_a(Numeric)
      end

      it 'returns nil when required measurements are missing' do
        skinfold = create(:skinfold, client: male_client, chest: 0, abdomen: 0, thigh: 0)
        result = service.calculate_for_skinfold(skinfold)

        expect(result).to be_nil
      end

      it 'calculates correctly for different age ranges' do
        young_client = create(:client, :male, birthdate: 20.years.ago)
        old_client = create(:client, :male, birthdate: 50.years.ago)

        young_skinfold = create(:skinfold, client: young_client, chest: 10.0, abdomen: 15.0, thigh: 12.0)
        old_skinfold = create(:skinfold, client: old_client, chest: 10.0, abdomen: 15.0, thigh: 12.0)

        young_service = described_class.new(young_client)
        old_service = described_class.new(old_client)

        young_result = young_service.calculate_for_skinfold(young_skinfold)
        old_result = old_service.calculate_for_skinfold(old_skinfold)

        expect(young_result).to be_a(Numeric)
        expect(old_result).to be_a(Numeric)
        expect(old_result).to be > young_result # older people typically have higher body fat %
      end
    end

    context 'for female clients' do
      let(:skinfold) { create(:skinfold, client: female_client, triceps: 15.0, suprailiac: 12.0, thigh: 18.0) }
      let(:service) { described_class.new(female_client) }

      it 'calculates body fat percentage using Jackson-Pollock 3-site formula for women' do
        result = service.calculate_for_skinfold(skinfold)

        expect(result).to be_a(Numeric)
        expect(result).to be > 0
        expect(result).to be < 50 # reasonable upper bound
      end

      it 'uses correct measurements for female formula (triceps, suprailiac, thigh)' do
        skinfold = create(:skinfold,
                          client: female_client,
                          triceps: 15.0,
                          suprailiac: 12.0,
                          thigh: 18.0,
                          chest: 10.0, # should not be used for females
                          abdomen: 15.0) # should not be used for females

        result = service.calculate_for_skinfold(skinfold)
        expect(result).to be_a(Numeric)
      end

      it 'returns nil when required measurements are missing' do
        skinfold = create(:skinfold, client: female_client, triceps: 0, suprailiac: 0, thigh: 0)
        result = service.calculate_for_skinfold(skinfold)

        expect(result).to be_nil
      end

      it 'calculates correctly for different age ranges' do
        young_client = create(:client, :female, birthdate: 20.years.ago)
        old_client = create(:client, :female, birthdate: 50.years.ago)

        young_skinfold = create(:skinfold, client: young_client, triceps: 15.0, suprailiac: 12.0, thigh: 18.0)
        old_skinfold = create(:skinfold, client: old_client, triceps: 15.0, suprailiac: 12.0, thigh: 18.0)

        young_service = described_class.new(young_client)
        old_service = described_class.new(old_client)

        young_result = young_service.calculate_for_skinfold(young_skinfold)
        old_result = old_service.calculate_for_skinfold(old_skinfold)

        expect(young_result).to be_a(Numeric)
        expect(old_result).to be_a(Numeric)
        expect(old_result).to be > young_result # older people typically have higher body fat %
      end
    end

    context 'for clients with other gender' do
      let(:other_client) { create(:client, gender: 'O', birthdate: 25.years.ago) }
      let(:service) { described_class.new(other_client) }

      it 'returns nil for unsupported gender' do
        skinfold = create(:skinfold, client: other_client, chest: 10.0, abdomen: 15.0, thigh: 12.0)
        result = service.calculate_for_skinfold(skinfold)

        expect(result).to be_nil
      end
    end
  end

  describe 'formula accuracy' do
    context 'male Jackson-Pollock 3-site formula' do
      let(:service) { described_class.new(male_client) }

      it 'produces results within expected range for typical values' do
        skinfold = create(:skinfold, client: male_client, chest: 12.0, abdominal: 18.0, thigh: 15.0)
        result = service.calculate_for_skinfold(skinfold)

        expect(result).to be_a(Numeric)
        expect(result).to be > 0
      end

      it 'handles high skinfold values' do
        skinfold = create(:skinfold, client: male_client, chest: 25.0, abdominal: 30.0, thigh: 28.0)
        result = service.calculate_for_skinfold(skinfold)

        expect(result).to be_a(Numeric)
        expect(result).to be > 0
      end

      it 'handles low skinfold values' do
        skinfold = create(:skinfold, client: male_client, chest: 5.0, abdominal: 8.0, thigh: 6.0)
        result = service.calculate_for_skinfold(skinfold)

        expect(result).to be_a(Numeric)
        expect(result).to be > 0
      end
    end

    context 'female Jackson-Pollock 3-site formula' do
      let(:service) { described_class.new(female_client) }

      it 'produces results within expected range for typical values' do
        skinfold = create(:skinfold, client: female_client, tricep: 18.0, suprailiac: 15.0, thigh: 22.0)
        result = service.calculate_for_skinfold(skinfold)

        expect(result).to be_a(Numeric)
        expect(result).to be > 0
      end

      it 'handles high skinfold values' do
        skinfold = create(:skinfold, client: female_client, tricep: 30.0, suprailiac: 25.0, thigh: 35.0)
        result = service.calculate_for_skinfold(skinfold)

        expect(result).to be_a(Numeric)
        expect(result).to be > 0
      end

      it 'handles low skinfold values' do
        skinfold = create(:skinfold, client: female_client, tricep: 10.0, suprailiac: 8.0, thigh: 12.0)
        result = service.calculate_for_skinfold(skinfold)

        expect(result).to be_a(Numeric)
        expect(result).to be > 0
      end
    end
  end

  describe 'edge cases' do
    it 'handles decimal precision correctly' do
      service = described_class.new(male_client)
      skinfold = create(:skinfold, client: male_client, chest: 10.25, abdominal: 15.75, thigh: 12.50)

      result = service.calculate_for_skinfold(skinfold)
      expect(result).to be_a(Numeric)
      expect(result).to respond_to(:round)
    end

    it 'handles very young clients' do
      young_client = create(:client, :male, birthdate: 18.years.ago)
      service = described_class.new(young_client)
      skinfold = create(:skinfold, client: young_client, chest: 10.0, abdomen: 15.0, thigh: 12.0)

      result = service.calculate_for_skinfold(skinfold)
      expect(result).to be_a(Numeric)
    end

    it 'handles very old clients' do
      old_client = create(:client, :male, birthdate: 80.years.ago)
      service = described_class.new(old_client)
      skinfold = create(:skinfold, client: old_client, chest: 15.0, abdomen: 20.0, thigh: 18.0)

      result = service.calculate_for_skinfold(skinfold)
      expect(result).to be_a(Numeric)
    end

    it 'handles nil skinfold values' do
      service = described_class.new(male_client)
      skinfold = create(:skinfold, client: male_client, chest: nil, abdomen: 15.0, thigh: 12.0)

      result = service.calculate_for_skinfold(skinfold)
      expect(result).to be_nil
    end
  end
end
