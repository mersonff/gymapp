require 'rails_helper'

RSpec.describe SkinfoldsController do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:plan) { create(:plan, user: user) }
  let(:client) { create(:client, user: user, plan: plan) }
  let(:other_client) { create(:client, user: other_user, plan: create(:plan, user: other_user)) }
  let(:skinfold) { create(:skinfold, client: client) }

  describe 'GET #index' do
    context 'when user is logged in' do
      before { session[:user_id] = user.id }

      it 'returns a successful response' do
        get :index, params: { client_id: client.id }
        expect(response).to be_successful
      end

      it 'assigns @skinfolds' do
        skinfold1 = create(:skinfold, client: client)
        skinfold2 = create(:skinfold, client: client)
        get :index, params: { client_id: client.id }
        expect(assigns(:skinfolds)).to include(skinfold1, skinfold2)
      end

      it 'orders skinfolds by created_at DESC' do
        create(:skinfold, client: client, created_at: 2.days.ago)
        new_skinfold = create(:skinfold, client: client, created_at: 1.day.ago)
        get :index, params: { client_id: client.id }
        expect(assigns(:skinfolds).first).to eq(new_skinfold)
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

      it 'assigns a new skinfold' do
        get :new, params: { client_id: client.id }
        expect(assigns(:skinfold)).to be_a_new(Skinfold)
      end

      it 'assigns the skinfold to the client' do
        get :new, params: { client_id: client.id }
        expect(assigns(:skinfold).client).to eq(client)
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
        chest: 10.5,
        midaxilary: 8.2,
        subscapular: 12.1,
        bicep: 6.8,
        tricep: 9.4,
        abdominal: 15.3,
        suprailiac: 11.7,
        thigh: 14.2,
        calf: 8.9,
      }
    end

    context 'when user is logged in' do
      before { session[:user_id] = user.id }

      context 'with valid parameters' do
        it 'creates a new skinfold' do
          expect do
            post :create, params: { client_id: client.id, skinfold: valid_attributes }
          end.to change(Skinfold, :count).by(1)
        end

        it 'assigns the skinfold to the client' do
          post :create, params: { client_id: client.id, skinfold: valid_attributes }
          expect(assigns(:skinfold).client).to eq(client)
        end

        it 'redirects to the client' do
          post :create, params: { client_id: client.id, skinfold: valid_attributes }
          expect(response).to redirect_to(client_path(client))
        end

        it 'sets flash success message' do
          post :create, params: { client_id: client.id, skinfold: valid_attributes }
          expect(flash[:success]).to eq('Adipometria criada com sucesso')
        end
      end

      context 'with invalid parameters' do
        it 'does not create a new skinfold' do
          expect do
            post :create, params: { client_id: client.id, skinfold: { chest: -10 } }
          end.not_to change(Skinfold, :count)
        end

        it 'renders the new template' do
          post :create, params: { client_id: client.id, skinfold: { chest: -10 } }
          expect(response).to render_template(:new)
        end
      end
    end

    context 'when user is not logged in' do
      it 'redirects to login' do
        post :create, params: { client_id: client.id, skinfold: valid_attributes }
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
        post :create, params: { client_id: client.id, skinfold: { chest: 10.5 } }
        expect(response).to redirect_to(login_path)
      end
    end
  end
end
