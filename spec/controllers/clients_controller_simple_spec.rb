require 'rails_helper'

RSpec.describe ClientsController, type: :controller do
  let(:user) { create(:user) }

  before do
    session[:user_id] = user.id
  end

  describe 'GET #index' do
    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #new' do
    it 'returns a successful response' do
      get :new
      expect(response).to be_successful
    end

    it 'renders the new template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'authentication required actions' do
    context 'when user is not logged in' do
      before { session[:user_id] = nil }

      it 'redirects index to login' do
        get :index
        expect(response).to redirect_to(login_path)
      end

      it 'redirects new to login' do
        get :new
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        name: 'John Doe',
        cellphone: '(11) 99999-9999',
        address: '123 Main St',
        birthdate: 25.years.ago.to_date,
        gender: 'M'
      }
    end

    it 'creates a new client with valid parameters' do
      expect {
        post :create, params: { client: valid_params }
      }.to change(Client, :count).by(1)
    end

    it 'assigns the client to the current user' do
      post :create, params: { client: valid_params }
      expect(Client.last.user).to eq(user)
    end
  end
end