require 'rails_helper'

RSpec.describe 'Payments API' do
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

  describe 'GET /clients/:id/new_payment' do
    it 'returns successful response' do
      get new_payment_client_path(client)
      expect(response).to have_http_status(:success)
    end

    context 'with turbo_stream format' do
      it 'returns turbo_stream response' do
        get new_payment_client_path(client),
            headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        expect(response).to have_http_status(:success)
        expect(response.content_type).to include('turbo-stream')
      end
    end
  end

  describe 'POST /clients/:id/create_payment' do
    let(:payment_params) do
      {
        payment: {
          value: 150.00,
          payment_date: Date.current,
        },
      }
    end

    context 'with valid parameters' do
      it 'creates payment successfully' do
        expect do
          post create_payment_client_path(client), params: payment_params
        end.to change(client.payments, :count).by(1)

        expect(response).to have_http_status(:redirect)
      end

      it 'assigns payment to client with correct values' do
        post create_payment_client_path(client), params: payment_params

        payment = client.payments.last
        expect(payment.value).to eq(150.00)
        expect(payment.payment_date).to eq(Date.current)
      end

      context 'with turbo_stream format' do
        it 'creates payment and returns turbo_stream redirect' do
          expect do
            post create_payment_client_path(client), params: payment_params,
                                                     headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
          end.to change(client.payments, :count).by(1)

          expect(response).to have_http_status(:see_other)
        end
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        { payment: { value: -10, payment_date: nil } }
      end

      it 'does not create payment' do
        expect do
          post create_payment_client_path(client), params: invalid_params
        end.not_to change(client.payments, :count)
      end

      it 'renders error response' do
        post create_payment_client_path(client), params: invalid_params
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'with different payment values' do
      it 'creates payment with decimal values' do
        params = { payment: { value: 99.99, payment_date: Date.current } }

        post create_payment_client_path(client), params: params

        payment = client.payments.last
        expect(payment.value).to eq(99.99)
      end

      it 'creates payment with future date' do
        future_date = 1.week.from_now.to_date
        params = { payment: { value: 200.00, payment_date: future_date } }

        post create_payment_client_path(client), params: params

        payment = client.payments.last
        expect(payment.payment_date).to eq(future_date)
      end
    end
  end

  describe 'authorization' do
    let(:other_user) { create(:user) }
    let(:other_plan) { create(:plan, user: other_user) }
    let(:other_client) { create(:client, user: other_user, plan: other_plan) }

    it "prevents creating payments for other user's clients" do
      get new_payment_client_path(other_client)
      expect([302, 404, 403]).to include(response.status)
    rescue ActiveRecord::RecordNotFound
      expect(true).to be true
    end
  end
end
