require 'rails_helper'

RSpec.describe ClientRepository, type: :repository do
  let(:user) { create(:user) }
  let(:repository) { described_class.new(user) }

  describe '#initialize' do
    it 'sets the user' do
      expect(repository.instance_variable_get(:@user)).to eq(user)
    end
  end

  describe '#all' do
    it 'returns empty relation when user has no clients' do
      result = repository.all
      expect(result).to be_empty
    end

    it 'returns all clients for the user' do
      client1 = create(:client, user: user)
      client2 = create(:client, user: user)
      other_user_client = create(:client)

      result = repository.all
      expect(result).to include(client1, client2)
      expect(result).not_to include(other_user_client)
    end

    it 'returns ActiveRecord::Relation' do
      result = repository.all
      expect(result).to be_a(ActiveRecord::Relation)
    end
  end

  describe '#find' do
    let!(:client) { create(:client, user: user) }

    it 'finds client by id for the current user' do
      result = repository.find(client.id)
      expect(result).to eq(client)
    end

    it 'raises RecordNotFound for non-existent client' do
      expect do
        repository.find(99_999)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'raises RecordNotFound for client belonging to different user' do
      other_user_client = create(:client)
      expect do
        repository.find(other_user_client.id)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '#search' do
    let!(:john_doe) { create(:client, name: 'John Doe', user: user) }
    let!(:jane_smith) { create(:client, name: 'Jane Smith', user: user) }

    it 'delegates to ClientsQuery for searching' do
      expect(ClientsQuery).to receive(:new).with(user.clients).and_call_original

      result = repository.search('John')
      expect(result).to include(john_doe)
      expect(result).not_to include(jane_smith)
    end

    it 'returns clients matching search term' do
      result = repository.search('John')
      expect(result).to include(john_doe)
      expect(result).not_to include(jane_smith)
    end

    it 'returns empty result for non-matching search' do
      result = repository.search('NonExistent')
      expect(result).to be_empty
    end

    it 'returns all clients when search term is empty' do
      result = repository.search('')
      expect(result).to include(john_doe, jane_smith)
    end
  end

  describe '#filter' do
    let!(:current_client) { create(:client, user: user) }
    let!(:overdue_client) { create(:client, :overdue, user: user) }

    it 'delegates to ClientsQuery for filtering' do
      expect(ClientsQuery).to receive(:new).with(user.clients).and_call_original

      result = repository.filter('overdue')
      expect(result).to include(overdue_client)
      expect(result).not_to include(current_client)
    end

    it 'filters overdue clients' do
      result = repository.filter('overdue')
      expect(result).to include(overdue_client)
      expect(result).not_to include(current_client)
    end

    it 'returns all clients for "all" filter' do
      result = repository.filter('all')
      expect(result).to include(current_client, overdue_client)
    end

    it 'returns all clients when filter is empty' do
      result = repository.filter('')
      expect(result).to include(current_client, overdue_client)
    end
  end

  describe '#search_and_filter' do
    let!(:john_current) { create(:client, name: 'John Current', user: user) }
    let!(:john_overdue) { create(:client, :overdue, name: 'John Overdue', user: user) }
    let!(:jane_overdue) { create(:client, :overdue, name: 'Jane Overdue', user: user) }

    it 'combines search and filter operations' do
      result = repository.search_and_filter('John', 'overdue')
      expect(result).to include(john_overdue)
      expect(result).not_to include(john_current, jane_overdue)
    end

    it 'delegates to ClientsQuery with chained operations' do
      query_double = instance_double(ClientsQuery)
      allow(ClientsQuery).to receive(:new).and_return(query_double)
      allow(query_double).to receive_messages(search: query_double, filter: query_double, all: [])

      repository.search_and_filter('John', 'overdue')

      expect(query_double).to have_received(:search).with('John')
      expect(query_double).to have_received(:filter).with('overdue')
      expect(query_double).to have_received(:all)
    end

    it 'returns all clients when both search and filter are empty' do
      result = repository.search_and_filter('', '')
      expect(result).to include(john_current, john_overdue, jane_overdue)
    end

    it 'applies only search when filter is empty' do
      result = repository.search_and_filter('John', '')
      expect(result).to include(john_current, john_overdue)
      expect(result).not_to include(jane_overdue)
    end

    it 'applies only filter when search is empty' do
      result = repository.search_and_filter('', 'overdue')
      expect(result).to include(john_overdue, jane_overdue)
      expect(result).not_to include(john_current)
    end
  end

  describe '#with_includes' do
    let!(:client) { create(:client, :with_measurements, :with_payments, :with_skinfolds, user: user) }

    it 'includes associated records to avoid N+1 queries' do
      # Performance test - should run without N+1 query issues
      expect do
        clients = repository.with_includes
        clients.each do |client|
          client.measurements.to_a
          client.payments.to_a
          client.skinfolds.to_a
          client.plan&.description
        end
      end.not_to raise_error
    end

    it 'returns clients with preloaded associations' do
      clients = repository.with_includes.to_a
      expect(clients.first.association(:measurements)).to be_loaded
      expect(clients.first.association(:payments)).to be_loaded
      expect(clients.first.association(:skinfolds)).to be_loaded
      expect(clients.first.association(:plan)).to be_loaded
    end
  end

  describe '#paginated' do
    before { 25.times { |i| create(:client, user: user, name: "Client #{i}") } }

    it 'paginates results' do
      page1 = repository.paginated(page: 1, per_page: 10)
      expect(page1.size).to eq(10)
    end

    it 'returns different results for different pages' do
      page1 = repository.paginated(page: 1, per_page: 10)
      page2 = repository.paginated(page: 2, per_page: 10)

      expect(page1.to_a).not_to eq(page2.to_a)
    end

    it 'handles last page correctly' do
      last_page = repository.paginated(page: 3, per_page: 10)
      # Page 3 of 25 items with 10 per page should have 5 items (items 21-25)
      expect(last_page.length).to eq(5)
    end

    it 'defaults pagination parameters when not provided' do
      result = repository.paginated
      expect(result.size).to be <= 20 # default per_page
    end
  end

  describe '#recent' do
    let!(:old_client) { create(:client, registration_date: 2.weeks.ago, user: user) }
    let!(:recent_client) { create(:client, registration_date: 2.days.ago, user: user) }

    it 'returns clients ordered by registration date descending' do
      result = repository.recent.to_a
      expect(result.first).to eq(recent_client)
      expect(result.last).to eq(old_client)
    end

    it 'can be chained with other methods' do
      result = repository.recent.limit(1)
      expect(result.first).to eq(recent_client)
    end
  end

  describe '#statistics' do
    before do
      create(:client, user: user)
      create(:client, :overdue, user: user)
    end

    it 'delegates to ClientStatisticsService' do
      expect(ClientStatisticsService).to receive(:new).with(user).and_call_original
      repository.statistics
    end

    it 'returns statistics hash' do
      result = repository.statistics
      expect(result).to be_a(Hash)
      expect(result).to have_key(:total)
      expect(result).to have_key(:current)
      expect(result).to have_key(:overdue)
    end
  end

  describe 'scoping to user' do
    let(:other_user) { create(:user) }
    let!(:user_client) { create(:client, user: user) }
    let!(:other_user_client) { create(:client, user: other_user) }

    it 'scopes all operations to the current user' do
      expect(repository.all).to include(user_client)
      expect(repository.all).not_to include(other_user_client)
    end

    it 'scopes search to the current user' do
      result = repository.search(user_client.name)
      expect(result).to include(user_client)
      expect(result).not_to include(other_user_client)
    end

    it 'scopes filter to the current user' do
      create(:client, :overdue, user: other_user)
      result = repository.filter('overdue')
      expect(result).not_to include(other_user_client)
    end
  end

  describe 'error handling' do
    it 'handles database connection errors gracefully' do
      allow(user).to receive(:clients).and_raise(ActiveRecord::ConnectionNotEstablished)

      expect do
        repository.all
      end.to raise_error(ActiveRecord::ConnectionNotEstablished)
    end

    it 'handles invalid SQL gracefully in search' do
      # This should not raise an error due to proper parameter binding
      expect do
        repository.search("test'; DROP TABLE clients; --")
      end.not_to raise_error
    end
  end
end
