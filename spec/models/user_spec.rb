require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:username) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:business_name) }
    it { should validate_uniqueness_of(:username).case_insensitive }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_uniqueness_of(:business_name).case_insensitive }
    it { should validate_length_of(:username).is_at_least(3).is_at_most(30) }
    it { should validate_length_of(:business_name).is_at_least(3).is_at_most(50) }
    it { should validate_length_of(:email).is_at_most(105) }
    it { should have_secure_password }
  end

  describe 'associations' do
    it { should have_many(:clients).dependent(:destroy) }
    it { should have_many(:plans).dependent(:destroy) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      user = build(:user)
      expect(user).to be_valid
    end
  end

  describe 'email validation' do
    it 'accepts valid email addresses' do
      valid_emails = %w[test@example.com user.name@domain.co.uk first.last@subdomain.example.com]
      
      valid_emails.each do |email|
        user = build(:user, email: email)
        expect(user).to be_valid, "#{email} should be valid"
      end
    end

    it 'rejects invalid email addresses' do
      invalid_emails = %w[invalid-email @domain.com user@]
      
      invalid_emails.each do |email|
        user = build(:user, email: email)
        expect(user).not_to be_valid, "#{email} should be invalid"
      end
    end
  end

  describe 'before_save callback' do
    it 'downcases email before saving' do
      user = create(:user, email: 'TEST@EXAMPLE.COM')
      expect(user.email).to eq('test@example.com')
    end

    it 'handles nil email gracefully' do
      user = User.new(username: 'test', business_name: 'Test Business')
      user.email = nil
      expect { user.save }.not_to raise_error
    end
  end

  describe 'username validation' do
    it 'accepts valid usernames' do
      valid_usernames = %w[user123 test_user user-name]
      
      valid_usernames.each do |username|
        user = build(:user, username: username)
        expect(user).to be_valid, "#{username} should be valid"
      end
    end

    it 'rejects usernames that are too short' do
      user = build(:user, username: 'ab')
      expect(user).not_to be_valid
    end

    it 'rejects usernames that are too long' do
      user = build(:user, username: 'a' * 31)
      expect(user).not_to be_valid
    end
  end

  describe 'business_name validation' do
    it 'accepts valid business names' do
      valid_names = ['ABC Corp', 'Test Business Inc.', 'My Company']
      
      valid_names.each do |name|
        user = build(:user, business_name: name)
        expect(user).to be_valid, "#{name} should be valid"
      end
    end

    it 'rejects business names that are too short' do
      user = build(:user, business_name: 'AB')
      expect(user).not_to be_valid
    end

    it 'rejects business names that are too long' do
      user = build(:user, business_name: 'a' * 51)
      expect(user).not_to be_valid
    end
  end
end