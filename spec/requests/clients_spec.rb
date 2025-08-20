require 'rails_helper'

RSpec.describe 'Clients API' do
  let(:user) { create(:user) }
  let(:plan) { create(:plan, user: user) }
  let(:client) { create(:client, user: user, plan: plan) }

  before do
    # Simulate login by setting session
    post login_path, params: {
      session: {
        email: user.email,
        password: user.password,
      },
    }
  end

  describe 'GET /clients' do
    it 'returns successful response for logged in user' do
      get clients_path
      expect(response).to have_http_status(:success)
    end

    it "includes user's clients" do
      client # create the client
      get clients_path
      expect(response.body).to include(client.name)
    end

    context 'with search parameter' do
      let!(:matching_client) { create(:client, name: 'John Doe', user: user, plan: plan) }
      let!(:non_matching_client) { create(:client, name: 'Jane Smith', user: user, plan: plan) }

      it 'filters clients by search term' do
        get clients_path, params: { search: 'John' }

        expect(response).to have_http_status(:success)
        expect(response.body).to include('John Doe')
        expect(response.body).not_to include('Jane Smith')
      end
    end

    context 'with turbo_stream format' do
      it 'returns turbo_stream response' do
        get clients_path, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        expect(response).to have_http_status(:success)
        expect(response.content_type).to include('turbo-stream')
      end
    end
  end

  describe 'GET /clients/:id' do
    it "returns successful response for user's client" do
      get client_path(client)
      expect(response).to have_http_status(:success)
    end

    it 'includes client details' do
      get client_path(client)
      expect(response.body).to include(client.name)
      expect(response.body).to include(client.cellphone)
    end
  end

  describe 'POST /clients' do
    let(:valid_params) do
      {
        client: {
          name: 'New Client',
          cellphone: '(11) 99999-9999',
          address: 'Test Address',
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
        },
      }
    end

    context 'with valid parameters' do
      it 'creates client and redirects' do
        expect do
          post clients_path, params: valid_params
        end.to change(Client, :count).by(1)

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(clients_path)
      end

      it 'creates associated measurement' do
        expect do
          post clients_path, params: valid_params
        end.to change(Measurement, :count).by(1)
      end

      context 'with turbo_stream format' do
        it 'creates client and returns turbo_stream redirect' do
          expect do
            post clients_path, params: valid_params,
                               headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
          end.to change(Client, :count).by(1)

          expect(response).to have_http_status(:see_other)
        end
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        { client: { name: '', cellphone: '' } }
      end

      it 'does not create client' do
        expect do
          post clients_path, params: invalid_params
        end.not_to change(Client, :count)
      end

      it 'renders new template with errors' do
        post clients_path, params: invalid_params
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'PATCH /clients/:id' do
    let(:update_params) do
      { client: { name: 'Updated Name' } }
    end

    it 'updates client successfully' do
      patch client_path(client), params: update_params

      expect(response).to have_http_status(:redirect)
      expect(client.reload.name).to eq('Updated Name')
    end

    context 'with turbo_stream format' do
      it 'updates client and returns turbo_stream redirect' do
        patch client_path(client), params: update_params,
                                   headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

        expect(response).to have_http_status(:see_other)
        expect(client.reload.name).to eq('Updated Name')
      end
    end
  end

  describe 'DELETE /clients/:id' do
    it 'destroys client successfully' do
      client_to_delete = create(:client, user: user, plan: plan)

      expect do
        delete client_path(client_to_delete)
      end.to change(Client, :count).by(-1)

      expect(response).to have_http_status(:redirect)
    end

    context 'with turbo_stream format' do
      it 'destroys client and returns turbo_stream response' do
        client_to_delete = create(:client, user: user, plan: plan)

        expect do
          delete client_path(client_to_delete),
                 headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        end.to change(Client, :count).by(-1)

        expect(response).to have_http_status(:success)
        expect(response.content_type).to include('turbo-stream')
      end
    end
  end

  describe 'authorization' do
    let(:other_user) { create(:user) }
    let(:other_plan) { create(:plan, user: other_user) }
    let(:other_client) { create(:client, user: other_user, plan: other_plan) }

    it "prevents access to other user's clients when logged in" do
      # Since we're logged in as 'user', accessing 'other_client' should fail

      get client_path(other_client)
      # If no exception was raised, check that we got redirected or error response
      expect([302, 404, 403]).to include(response.status)
    rescue ActiveRecord::RecordNotFound
      # This is the expected behavior
      expect(true).to be true
    end
  end
end
