require 'rails_helper'

RSpec.describe Payment, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:value) }
    it { should validate_presence_of(:payment_date) }
    it { should validate_numericality_of(:value).is_greater_than(0) }
  end

  describe 'associations' do
    it { should belong_to(:client) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      payment = build(:payment)
      expect(payment).to be_valid
    end

    it 'creates overdue payments' do
      overdue_payment = create(:payment, :overdue)
      expect(overdue_payment.payday).to be < Date.current
    end

    it 'creates future payments' do
      future_payment = create(:payment, :future)
      expect(future_payment.payday).to be > Date.current
    end

    it 'creates recent payments' do
      recent_payment = create(:payment, :recent)
      expect(recent_payment.payday).to be <= Date.current
    end
  end

  describe '#overdue?' do
    it 'returns true for overdue payments' do
      payment = create(:payment, payment_date: 1.week.ago)
      expect(payment.overdue?).to be true
    end

    it 'returns false for current payments' do
      payment = create(:payment, payment_date: Date.current)
      expect(payment.overdue?).to be false
    end

    it 'returns false for future payments' do
      payment = create(:payment, payment_date: 1.week.from_now)
      expect(payment.overdue?).to be false
    end
  end

  describe 'value validation' do
    it 'accepts positive values' do
      payment = build(:payment, value: 99.99)
      expect(payment).to be_valid
    end

    it 'rejects zero value' do
      payment = build(:payment, value: 0)
      expect(payment).not_to be_valid
    end

    it 'rejects negative values' do
      payment = build(:payment, value: -50.00)
      expect(payment).not_to be_valid
    end
  end

  describe 'payment_date validation' do
    it 'accepts past dates' do
      payment = build(:payment, payment_date: 1.month.ago)
      expect(payment).to be_valid
    end

    it 'accepts current date' do
      payment = build(:payment, payment_date: Date.current)
      expect(payment).to be_valid
    end

    it 'accepts future dates' do
      payment = build(:payment, payment_date: 1.month.from_now)
      expect(payment).to be_valid
    end
  end

  describe 'scopes' do
    let(:client) { create(:client) }
    
    before do
      create(:payment, client: client, payment_date: 1.week.ago)
      create(:payment, client: client, payment_date: Date.current)
      create(:payment, client: client, payment_date: 1.week.from_now)
    end

    it 'orders payments by payment_date' do
      payments = client.payments.order(:payment_date)
      expect(payments.first.payment_date).to be < payments.last.payment_date
    end
  end
end