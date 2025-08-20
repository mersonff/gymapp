require 'rails_helper'

RSpec.describe MeasurementsController do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:plan) { create(:plan, user: user) }
  let(:client) { create(:client, user: user, plan: plan) }
  let(:other_client) { create(:client, user: other_user, plan: create(:plan, user: other_user)) }
  let(:measurement) { create(:measurement, client: client) }

  describe 'GET #index' do
    context 'when user is logged in' do
      before { session[:user_id] = user.id }

      it 'returns a successful response' do
        get :index, params: { client_id: client.id }
        expect(response).to be_successful
      end

      it 'assigns @measurements' do
        measurement1 = create(:measurement, client: client)
        measurement2 = create(:measurement, client: client)
        get :index, params: { client_id: client.id }
        expect(assigns(:measurements)).to include(measurement1, measurement2)
      end

      it 'orders measurements by created_at DESC' do
        create(:measurement, client: client, created_at: 2.days.ago)
        new_measurement = create(:measurement, client: client, created_at: 1.day.ago)
        get :index, params: { client_id: client.id }
        expect(assigns(:measurements).first).to eq(new_measurement)
      end
    end
  end

  describe 'GET #new' do
    context 'when user is logged in' do
      before { session[:user_id] = user.id }

      it 'returns a successful response' do
        get :new, params: { client_id: client.id }
        expect(response).to be_successful
      end

      it 'assigns a new measurement' do
        get :new, params: { client_id: client.id }
        expect(assigns(:measurement)).to be_a_new(Measurement)
      end

      it 'assigns the measurement to the client' do
        get :new, params: { client_id: client.id }
        expect(assigns(:measurement).client).to eq(client)
      end
    end

    context 'when user is not logged in' do
      it 'redirects to login' do
        get :new, params: { client_id: client.id }
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) do
      {
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
      }
    end

    context 'when user is logged in' do
      before { session[:user_id] = user.id }

      context 'with valid parameters' do
        it 'creates a new measurement' do
          expect do
            post :create, params: { client_id: client.id, measurement: valid_attributes }
          end.to change(Measurement, :count).by(1)
        end

        it 'assigns the measurement to the client' do
          post :create, params: { client_id: client.id, measurement: valid_attributes }
          expect(assigns(:measurement).client).to eq(client)
        end

        it 'redirects to the client' do
          post :create, params: { client_id: client.id, measurement: valid_attributes }
          expect(response).to redirect_to(client_path(client))
        end

        it 'sets flash success message' do
          post :create, params: { client_id: client.id, measurement: valid_attributes }
          expect(flash[:success]).to eq('Perimetria criada com sucesso')
        end
      end

      context 'with invalid parameters' do
        it 'does not create a new measurement' do
          expect do
            post :create, params: { client_id: client.id, measurement: { height: -10 } }
          end.not_to change(Measurement, :count)
        end

        it 'renders the new template' do
          post :create, params: { client_id: client.id, measurement: { height: -10 } }
          expect(response).to render_template(:new)
        end
      end
    end

    context 'when user is not logged in' do
      it 'redirects to login' do
        post :create, params: { client_id: client.id, measurement: valid_attributes }
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe 'authorization' do
    context 'when user is not logged in' do
      it 'redirects new to login' do
        get :new, params: { client_id: client.id }
        expect(response).to redirect_to(login_path)
      end

      it 'redirects create to login' do
        post :create, params: { client_id: client.id, measurement: { height: 175 } }
        expect(response).to redirect_to(login_path)
      end
    end
  end
end
