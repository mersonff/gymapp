require 'rails_helper'

RSpec.describe ClientStatisticsService, type: :service do
  let(:user) { create(:user) }
  let(:service) { described_class.new(user) }

  describe '#initialize' do
    it 'sets the user' do
      expect(service.instance_variable_get(:@user)).to eq(user)
    end
  end

  describe '#total_clients' do
    it 'returns 0 when user has no clients' do
      expect(service.total_clients).to eq(0)
    end

    it 'returns the correct count of clients' do
      create_list(:client, 3, user: user)
      expect(service.total_clients).to eq(3)
    end

    it 'does not count other users clients' do
      other_user = create(:user)
      create_list(:client, 2, user: user)
      create_list(:client, 3, user: other_user)
      
      expect(service.total_clients).to eq(2)
    end
  end

  describe '#current_clients' do
    it 'returns 0 when user has no current clients' do
      expect(service.current_clients).to eq(0)
    end

    it 'counts clients without overdue payments' do
      current_client = create(:client, user: user)
      create(:payment, client: current_client, payday: Date.current)
      
      expect(service.current_clients).to eq(1)
    end

    it 'does not count clients with overdue payments' do
      overdue_client = create(:client, user: user)
      create(:payment, client: overdue_client, payday: 1.week.ago)
      
      expect(service.current_clients).to eq(0)
    end

    it 'counts clients with future payments as current' do
      future_client = create(:client, user: user)
      create(:payment, client: future_client, payday: 1.week.from_now)
      
      expect(service.current_clients).to eq(1)
    end

    it 'handles mixed payment scenarios correctly' do
      current_client = create(:client, user: user)
      overdue_client = create(:client, user: user)
      future_client = create(:client, user: user)
      
      create(:payment, client: current_client, payday: Date.current)
      create(:payment, client: overdue_client, payday: 1.week.ago)
      create(:payment, client: future_client, payday: 1.week.from_now)
      
      expect(service.current_clients).to eq(2)
    end
  end

  describe '#overdue_clients' do
    it 'returns 0 when user has no overdue clients' do
      expect(service.overdue_clients).to eq(0)
    end

    it 'counts clients with overdue payments' do
      overdue_client = create(:client, user: user)
      create(:payment, client: overdue_client, payday: 1.week.ago)
      
      expect(service.overdue_clients).to eq(1)
    end

    it 'does not count clients with current payments' do
      current_client = create(:client, user: user)
      create(:payment, client: current_client, payday: Date.current)
      
      expect(service.overdue_clients).to eq(0)
    end

    it 'does not count clients with future payments' do
      future_client = create(:client, user: user)
      create(:payment, client: future_client, payday: 1.week.from_now)
      
      expect(service.overdue_clients).to eq(0)
    end

    it 'handles multiple overdue clients correctly' do
      client1 = create(:client, user: user)
      client2 = create(:client, user: user)
      
      create(:payment, client: client1, payday: 1.week.ago)
      create(:payment, client: client2, payday: 2.weeks.ago)
      
      expect(service.overdue_clients).to eq(2)
    end
  end

  describe '#call' do
    it 'returns a hash with all statistics' do
      current_client = create(:client, user: user)
      overdue_client = create(:client, user: user)
      
      create(:payment, client: current_client, payday: Date.current)
      create(:payment, client: overdue_client, payday: 1.week.ago)
      
      result = service.call
      
      expect(result).to be_a(Hash)
      expect(result[:total]).to eq(2)
      expect(result[:current]).to eq(1)
      expect(result[:overdue]).to eq(1)
    end

    it 'returns zeros when user has no clients' do
      result = service.call
      
      expect(result[:total]).to eq(0)
      expect(result[:current]).to eq(0)
      expect(result[:overdue]).to eq(0)
    end
  end

  describe 'edge cases' do
    it 'handles clients without payments' do
      create(:client, user: user)
      
      expect(service.total_clients).to eq(1)
      expect(service.current_clients).to eq(1) # Clients without payments are considered current
      expect(service.overdue_clients).to eq(0)
    end

    it 'handles clients with multiple payments' do
      client = create(:client, user: user)
      create(:payment, client: client, payment_date: 2.weeks.ago) # overdue
      create(:payment, client: client, payment_date: Date.current) # current
      
      # Updated logic: prioritizes most recent payment - client is current if latest payment is not overdue
      expect(service.current_clients).to eq(1)
      expect(service.overdue_clients).to eq(0)
    end

    it 'handles boundary dates correctly' do
      client = create(:client, user: user)
      create(:payment, client: client, payment_date: Date.current)
      
      expect(service.current_clients).to eq(1)
      expect(service.overdue_clients).to eq(0)
    end
  end

  describe 'performance' do
    it 'calculates statistics for multiple clients' do
      create_list(:client, 10, user: user)
      
      result = service.call
      expect(result[:total]).to eq(10)
    end
  end
end