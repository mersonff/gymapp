require 'rails_helper'

RSpec.describe 'Measurements API' do
  let(:user) { create(:user) }
  let(:plan) { create(:plan, user: user) }
  let(:client) { create(:client, user: user, plan: plan) }

  before do
    post login_path, params: {
      session: {
        email: user.email,
        password: user.password,
      },
    }
  end

  describe 'GET /clients/:id/new_measurement' do
    it 'returns successful response' do
      get new_measurement_client_path(client)
      expect(response).to have_http_status(:success)
    end

    context 'with turbo_stream format' do
      it 'returns turbo_stream response' do
        get new_measurement_client_path(client),
            headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        expect(response).to have_http_status(:success)
        expect(response.content_type).to include('turbo-stream')
      end
    end
  end

  describe 'POST /clients/:id/create_measurement' do
    let(:measurement_params) do
      {
        measurement: {
          height: 180,
          weight: 75,
          chest: 105,
          left_arm: 35,
          right_arm: 35,
          waist: 85,
          abdomen: 90,
          hips: 100,
          left_thigh: 60,
          righ_thigh: 60,
        },
      }
    end

    context 'with valid parameters' do
      it 'creates measurement successfully' do
        expect do
          post create_measurement_client_path(client), params: measurement_params
        end.to change(client.measurements, :count).by(1)

        expect(response).to have_http_status(:redirect)
      end

      it 'assigns measurement to client' do
        post create_measurement_client_path(client), params: measurement_params

        measurement = client.measurements.last
        expect(measurement.height).to eq(180)
        expect(measurement.weight).to eq(75)
      end

      context 'with turbo_stream format' do
        it 'creates measurement and returns turbo_stream redirect' do
          expect do
            post create_measurement_client_path(client), params: measurement_params,
                                                         headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
          end.to change(client.measurements, :count).by(1)

          expect(response).to have_http_status(:see_other)
        end
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        { measurement: { height: -10, weight: -5 } }
      end

      it 'does not create measurement' do
        expect do
          post create_measurement_client_path(client), params: invalid_params
        end.not_to change(client.measurements, :count)
      end

      it 'renders error response' do
        post create_measurement_client_path(client), params: invalid_params
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'with minimal valid data' do
      let(:minimal_params) do
        { measurement: { height: 170, weight: 70 } }
      end

      it 'creates measurement with required fields only' do
        expect do
          post create_measurement_client_path(client), params: minimal_params
        end.to change(client.measurements, :count).by(1)
      end
    end
  end

  describe 'authorization' do
    let(:other_user) { create(:user) }
    let(:other_plan) { create(:plan, user: other_user) }
    let(:other_client) { create(:client, user: other_user, plan: other_plan) }

    it "prevents creating measurements for other user's clients" do
      get new_measurement_client_path(other_client)
      expect([302, 404, 403]).to include(response.status)
    rescue ActiveRecord::RecordNotFound
      expect(true).to be true
    end
  end
end
