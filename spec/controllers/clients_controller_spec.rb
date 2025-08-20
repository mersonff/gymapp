require 'rails_helper'

RSpec.describe ClientsController do
  let(:user) { create(:user) }
  let(:plan) { create(:plan, user: user) }
  let(:client) { create(:client, user: user, plan: plan) }
  let(:valid_attributes) do
    {
      name: 'John Doe',
      cellphone: '(11) 99999-9999',
      address: '123 Main St',
      birthdate: 25.years.ago.to_date,
      gender: 'M',
      plan_id: plan.id,
      measurements_attributes: {
        '0' => {
          height: 175,
          weight: 70,
          chest: 100,
          left_arm: 30,
          right_arm: 30,
          waist: 80,
          abdomen: 85,
          hips: 95,
          left_thigh: 55,
          righ_thigh: 55,
        },
      },
    }
  end

  before do
    session[:user_id] = user.id
  end

  describe 'GET #index' do
    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns @clients' do
      client
      get :index
      expect(assigns(:clients)).to include(client)
    end

    it 'calculates statistics' do
      create(:client, :overdue, user: user)
      get :index

      expect(assigns(:total_clients)).to eq(1)
      expect(assigns(:overdue_clients)).to eq(1)
    end

    context 'with search parameter' do
      it 'filters clients by search term' do
        matching_client = create(:client, name: 'John Doe', user: user)
        non_matching_client = create(:client, name: 'Jane Smith', user: user)

        get :index, params: { search: 'John' }

        expect(assigns(:clients)).to include(matching_client)
        expect(assigns(:clients)).not_to include(non_matching_client)
      end
    end

    context 'with filter parameter' do
      it 'filters overdue clients' do
        overdue_client = create(:client, :overdue, user: user)
        current_client = create(:client, user: user)

        get :index, params: { filter: 'overdue' }

        expect(assigns(:clients)).to include(overdue_client)
        expect(assigns(:clients)).not_to include(current_client)
      end
    end
  end

  describe 'GET #show' do
    it 'returns a successful response' do
      get :show, params: { id: client.id }
      expect(response).to be_successful
    end

    it 'assigns the requested client' do
      get :show, params: { id: client.id }
      expect(assigns(:client)).to eq(client)
    end
  end

  describe 'GET #new' do
    it 'returns a successful response' do
      get :new
      expect(response).to be_successful
    end

    it 'assigns a new client' do
      get :new
      expect(assigns(:client)).to be_a_new(Client)
    end

    it 'builds a measurement for the client' do
      get :new
      expect(assigns(:client).measurements.size).to eq(1)
      expect(assigns(:client).measurements.first).to be_a_new(Measurement)
    end
  end

  describe 'GET #edit' do
    it 'returns a successful response' do
      get :edit, params: { id: client.id }
      expect(response).to be_successful
    end

    it 'assigns the requested client' do
      get :edit, params: { id: client.id }
      expect(assigns(:client)).to eq(client)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new client' do
        expect do
          post :create, params: { client: valid_attributes }
        end.to change(Client, :count).by(1)
      end

      it 'creates a measurement for the client' do
        expect do
          post :create, params: { client: valid_attributes }
        end.to change(Measurement, :count).by(1)
      end

      it 'assigns the client to the current user' do
        post :create, params: { client: valid_attributes }
        expect(assigns(:client).user).to eq(user)
      end

      it 'redirects to clients index' do
        post :create, params: { client: valid_attributes }
        expect(response).to redirect_to(clients_path)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { name: '', cellphone: '' } }

      it 'does not create a new client' do
        expect do
          post :create, params: { client: invalid_attributes }
        end.not_to change(Client, :count)
      end

      it 'renders the new template' do
        post :create, params: { client: invalid_attributes }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid parameters' do
      let(:new_attributes) { { name: 'Updated Name' } }

      it 'updates the requested client' do
        patch :update, params: { id: client.id, client: new_attributes }
        client.reload
        expect(client.name).to eq('Updated Name')
      end

      it 'redirects to the client' do
        patch :update, params: { id: client.id, client: new_attributes }
        expect(response).to redirect_to(clients_path)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { name: '' } }

      it 'does not update the client' do
        original_name = client.name
        patch :update, params: { id: client.id, client: invalid_attributes }
        client.reload
        expect(client.name).to eq(original_name)
      end

      it 'renders the edit template' do
        patch :update, params: { id: client.id, client: invalid_attributes }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested client' do
      client
      expect do
        delete :destroy, params: { id: client.id }
      end.to change(Client, :count).by(-1)
    end

    it 'redirects to clients index' do
      delete :destroy, params: { id: client.id }
      expect(response).to redirect_to(clients_path)
    end
  end

  describe 'GET #new_measurement' do
    it 'returns a successful response' do
      get :new_measurement, params: { id: client.id }
      expect(response).to be_successful
    end

    it 'assigns the client' do
      get :new_measurement, params: { id: client.id }
      expect(assigns(:client)).to eq(client)
    end

    it 'builds a new measurement' do
      get :new_measurement, params: { id: client.id }
      expect(assigns(:measurement)).to be_a_new(Measurement)
    end
  end

  describe 'POST #create_measurement' do
    let(:measurement_attributes) { { height: 180, weight: 75 } }

    it 'creates a new measurement' do
      expect do
        post :create_measurement, params: { id: client.id, measurement: measurement_attributes }
      end.to change(client.measurements, :count).by(1)
    end

    it 'assigns the measurement to the client' do
      post :create_measurement, params: { id: client.id, measurement: measurement_attributes }
      expect(client.measurements.last.height).to eq(180)
    end
  end

  describe 'GET #new_payment' do
    it 'returns a successful response' do
      get :new_payment, params: { id: client.id }
      expect(response).to be_successful
    end

    it 'assigns the client' do
      get :new_payment, params: { id: client.id }
      expect(assigns(:client)).to eq(client)
    end

    it 'builds a new payment' do
      get :new_payment, params: { id: client.id }
      expect(assigns(:payment)).to be_a_new(Payment)
    end
  end

  describe 'POST #create_payment' do
    let(:payment_attributes) { { value: 99.99, payment_date: Date.current } }

    it 'creates a new payment' do
      expect do
        post :create_payment, params: { id: client.id, payment: payment_attributes }
      end.to change(client.payments, :count).by(1)
    end

    it 'assigns the payment to the client' do
      post :create_payment, params: { id: client.id, payment: payment_attributes }
      expect(client.payments.last.value).to eq(99.99)
    end
  end

  describe 'GET #new_skinfold' do
    it 'returns a successful response' do
      get :new_skinfold, params: { id: client.id }
      expect(response).to be_successful
    end

    it 'assigns the client' do
      get :new_skinfold, params: { id: client.id }
      expect(assigns(:client)).to eq(client)
    end

    it 'builds a new skinfold' do
      get :new_skinfold, params: { id: client.id }
      expect(assigns(:skinfold)).to be_a_new(Skinfold)
    end
  end

  describe 'POST #create_skinfold' do
    let(:skinfold_attributes) { { chest: 10.5, abdomen: 15.2, thigh: 12.8 } }

    it 'creates a new skinfold' do
      expect do
        post :create_skinfold, params: { id: client.id, skinfold: skinfold_attributes }
      end.to change(client.skinfolds, :count).by(1)
    end

    it 'assigns the skinfold to the client' do
      post :create_skinfold, params: { id: client.id, skinfold: skinfold_attributes }
      expect(client.skinfolds.last.chest).to eq(10.5)
    end
  end

  describe 'authorization' do
    context 'when user is not logged in' do
      before { session[:user_id] = nil }

      it 'redirects to login for index' do
        get :index
        expect(response).to redirect_to(login_path)
      end

      it 'redirects to login for show' do
        get :show, params: { id: client.id }
        expect(response).to redirect_to(login_path)
      end
    end

    context 'when accessing another user\'s client' do
      let(:other_user) { create(:user) }
      let(:other_client) { create(:client, user: other_user) }

      it 'raises RecordNotFound for show' do
        expect do
          get :show, params: { id: other_client.id }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'raises RecordNotFound for edit' do
        expect do
          get :edit, params: { id: other_client.id }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
