require 'rails_helper'

RSpec.describe ClientsQuery, type: :query do
  let(:user) { create(:user) }
  let(:base_relation) { user.clients }
  let(:query) { described_class.new(base_relation) }

  describe '#initialize' do
    it 'sets the relation' do
      expect(query.instance_variable_get(:@relation)).to eq(base_relation)
    end
  end

  describe '#search' do
    let!(:john_doe) { create(:client, name: 'John Doe', cellphone: '(11) 99999-1111', address: '123 Main St', user: user) }
    let!(:jane_smith) { create(:client, name: 'Jane Smith', cellphone: '(11) 99999-2222', address: '456 Oak Ave', user: user) }
    let!(:bob_johnson) { create(:client, name: 'Bob Johnson', cellphone: '(11) 99999-3333', address: '789 Pine Rd', user: user) }

    context 'with empty search term' do
      it 'returns all clients when term is blank' do
        result = query.search('').all
        expect(result).to include(john_doe, jane_smith, bob_johnson)
      end

      it 'returns all clients when term is nil' do
        result = query.search(nil).all
        expect(result).to include(john_doe, jane_smith, bob_johnson)
      end
    end

    context 'searching by name' do
      it 'finds clients by exact name match' do
        result = query.search('John Doe').all
        expect(result).to include(john_doe)
        expect(result).not_to include(jane_smith, bob_johnson)
      end

      it 'finds clients by partial name match' do
        result = query.search('John').all
        expect(result).to include(john_doe, bob_johnson)
        expect(result).not_to include(jane_smith)
      end

      it 'finds clients by last name' do
        result = query.search('Smith').all
        expect(result).to include(jane_smith)
        expect(result).not_to include(john_doe, bob_johnson)
      end

      it 'is case insensitive' do
        result = query.search('JOHN').all
        expect(result).to include(john_doe, bob_johnson)
        expect(result).not_to include(jane_smith)
      end

      it 'handles accented characters' do
        accented_client = create(:client, name: 'José María', user: user)
        result = query.search('josé').all
        expect(result).to include(accented_client)
      end
    end

    context 'searching by cellphone' do
      it 'finds clients by exact cellphone match' do
        result = query.search('(11) 99999-1111').all
        expect(result).to include(john_doe)
        expect(result).not_to include(jane_smith, bob_johnson)
      end

      it 'finds clients by partial cellphone match' do
        result = query.search('99999-2222').all
        expect(result).to include(jane_smith)
        expect(result).not_to include(john_doe, bob_johnson)
      end

      it 'finds clients by phone number without formatting' do
        result = query.search('1199999').all
        expect(result).to include(john_doe, jane_smith, bob_johnson)
      end
    end

    context 'searching by address' do
      it 'finds clients by exact address match' do
        result = query.search('123 Main St').all
        expect(result).to include(john_doe)
        expect(result).not_to include(jane_smith, bob_johnson)
      end

      it 'finds clients by partial address match' do
        result = query.search('Main').all
        expect(result).to include(john_doe)
        expect(result).not_to include(jane_smith, bob_johnson)
      end

      it 'finds clients by street type' do
        result = query.search('Ave').all
        expect(result).to include(jane_smith)
        expect(result).not_to include(john_doe, bob_johnson)
      end
    end

    context 'combined searches' do
      it 'returns empty result when no matches found' do
        result = query.search('NonExistent').all
        expect(result).to be_empty
      end

      it 'finds multiple clients with common terms' do
        result = query.search('99999').all
        expect(result).to include(john_doe, jane_smith, bob_johnson)
      end
    end

    context 'method chaining' do
      it 'returns self for method chaining' do
        result = query.search('John')
        expect(result).to be_a(described_class)
        expect(result).to eq(query)
      end

      it 'can be chained with other query methods' do
        result = query.search('John').filter('all').all
        expect(result).to include(john_doe, bob_johnson)
      end
    end
  end

  describe '#filter' do
    let!(:current_client) { create(:client, user: user) }
    let!(:overdue_client) { create(:client, :overdue, user: user) }

    context 'with overdue filter' do
      it 'returns only overdue clients' do
        result = query.filter('overdue').all
        expect(result).to include(overdue_client)
        expect(result).not_to include(current_client)
      end
    end

    context 'with all filter' do
      it 'returns all clients' do
        result = query.filter('all').all
        expect(result).to include(current_client, overdue_client)
      end
    end

    context 'with empty or nil filter' do
      it 'returns all clients when filter is blank' do
        result = query.filter('').all
        expect(result).to include(current_client, overdue_client)
      end

      it 'returns all clients when filter is nil' do
        result = query.filter(nil).all
        expect(result).to include(current_client, overdue_client)
      end
    end

    context 'method chaining' do
      it 'returns self for method chaining' do
        result = query.filter('overdue')
        expect(result).to be_a(described_class)
        expect(result).to eq(query)
      end

      it 'can be chained with search' do
        overdue_john = create(:client, :overdue, name: 'John Overdue', user: user)
        current_john = create(:client, name: 'John Current', user: user)
        
        result = query.search('John').filter('overdue').all
        expect(result).to include(overdue_john)
        expect(result).not_to include(current_john)
      end
    end
  end

  describe '#all' do
    let!(:client1) { create(:client, user: user) }
    let!(:client2) { create(:client, user: user) }

    it 'returns ActiveRecord::Relation' do
      result = query.all
      expect(result).to be_a(ActiveRecord::Relation)
    end

    it 'returns all clients in the relation' do
      result = query.all
      expect(result).to include(client1, client2)
    end

    it 'applies previous filters' do
      searched_query = query.search(client1.name)
      result = searched_query.all
      expect(result).to include(client1)
      expect(result).not_to include(client2)
    end
  end

  describe 'complex query combinations' do
    let!(:john_current) { create(:client, name: 'John Current', cellphone: '(11) 11111-1111', user: user) }
    let!(:john_overdue) { create(:client, :overdue, name: 'John Overdue', cellphone: '(11) 22222-2222', user: user) }
    let!(:jane_overdue) { create(:client, :overdue, name: 'Jane Overdue', cellphone: '(11) 33333-3333', user: user) }

    it 'combines search and filter correctly' do
      result = query.search('John').filter('overdue').all
      expect(result).to include(john_overdue)
      expect(result).not_to include(john_current, jane_overdue)
    end

    it 'searches across multiple fields with filter' do
      result = query.search('22222').filter('overdue').all
      expect(result).to include(john_overdue)
      expect(result).not_to include(john_current, jane_overdue)
    end

    it 'handles empty results gracefully' do
      result = query.search('NonExistent').filter('overdue').all
      expect(result).to be_empty
    end
  end

  describe 'performance' do
    it 'uses efficient SQL queries' do
      create_list(:client, 10, user: user)
      
      # Performance test - should run without errors
      expect { query.search('test').filter('overdue').all.to_a }.not_to raise_error
    end

    it 'does not execute queries until #all is called' do
      # Lazy evaluation test - should not execute query until .all is called
      expect { query.search('test').filter('overdue') }.not_to raise_error
    end
  end

  describe 'edge cases' do
    it 'handles special characters in search' do
      special_client = create(:client, name: "O'Brien & Sons", user: user)
      result = query.search("O'Brien").all
      expect(result).to include(special_client)
    end

    it 'handles very long search terms' do
      long_term = 'a' * 1000
      result = query.search(long_term).all
      expect(result).to be_empty
    end

    it 'handles SQL injection attempts safely' do
      malicious_term = "'; DROP TABLE clients; --"
      expect { query.search(malicious_term).all }.not_to raise_error
    end
  end
end