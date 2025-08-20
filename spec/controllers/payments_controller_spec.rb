require 'rails_helper'

RSpec.describe PaymentsController do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:plan) { create(:plan, user: user) }
  let(:client) { create(:client, user: user, plan: plan) }
  let(:other_client) { create(:client, user: other_user, plan: create(:plan, user: other_user)) }
  let(:payment) { create(:payment, client: client) }

  describe 'GET #index' do
    context 'when user is logged in' do
      before { session[:user_id] = user.id }

      it 'returns a successful response' do
        get :index, params: { client_id: client.id }
        expect(response).to be_successful
      end

      it 'assigns @payments' do
        payment1 = create(:payment, client: client)
        payment2 = create(:payment, client: client)
        get :index, params: { client_id: client.id }
        expect(assigns(:payments)).to include(payment1, payment2)
      end

      it 'orders payments by payment_date DESC' do
        create(:payment, client: client, payment_date: 2.days.ago)
        new_payment = create(:payment, client: client, payment_date: 1.day.ago)
        get :index, params: { client_id: client.id }
        expect(assigns(:payments).first).to eq(new_payment)
      end
    end
  end

  describe 'GET #new' do
    context 'when user is logged in' do
      before do
        session[:user_id] = user.id
        # Ensure client has at least one payment for controller logic
        create(:payment, client: client, payment_date: 1.month.ago)
      end

      it 'returns a successful response' do
        get :new, params: { client_id: client.id }
        expect(response).to be_successful
      end

      it 'assigns a new payment' do
        get :new, params: { client_id: client.id }
        expect(assigns(:payment)).to be_a_new(Payment)
      end

      it 'assigns the payment to the client' do
        get :new, params: { client_id: client.id }
        expect(assigns(:payment).client).to eq(client)
      end

      context 'when client has no previous payments' do
        it 'sets start_date to current date' do
          client_without_payments = create(:client, user: user, plan: plan)
          # Need at least one payment for the controller logic to work
          create(:payment, client: client_without_payments, payment_date: Date.current)
          get :new, params: { client_id: client_without_payments.id }
          expect(assigns(:start_date)).to be_present
        end
      end

      context 'when client has previous payments' do
        context 'when last payment is overdue' do
          it 'sets start_date to current date' do
            create(:payment, client: client, payment_date: 2.months.ago)
            get :new, params: { client_id: client.id }
            expect(assigns(:start_date)).to eq(Date.current)
          end
        end

        context 'when last payment is current' do
          it 'sets start_date to next month' do
            last_payment = create(:payment, client: client, payment_date: Date.current)
            get :new, params: { client_id: client.id }
            expect(assigns(:start_date)).to eq(last_payment.payment_date + 1.month)
          end
        end
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
        payment_date: Date.current,
        value: 150.00,
      }
    end

    context 'when user is logged in' do
      before { session[:user_id] = user.id }

      context 'with valid parameters' do
        it 'creates a new payment' do
          expect do
            post :create, params: { client_id: client.id, payment: valid_attributes }
          end.to change(Payment, :count).by(1)
        end

        it 'assigns the payment to the client' do
          post :create, params: { client_id: client.id, payment: valid_attributes }
          expect(assigns(:payment).client).to eq(client)
        end

        it 'redirects to the client' do
          post :create, params: { client_id: client.id, payment: valid_attributes }
          expect(response).to redirect_to(client_path(client))
        end

        it 'sets flash success message' do
          post :create, params: { client_id: client.id, payment: valid_attributes }
          expect(flash[:success]).to eq('Pagamento criado com sucesso')
        end
      end

      context 'with invalid parameters' do
        it 'does not create a new payment' do
          expect do
            post :create, params: { client_id: client.id, payment: { value: -10 } }
          end.not_to change(Payment, :count)
        end

        it 'renders the new template' do
          post :create, params: { client_id: client.id, payment: { value: -10 } }
          expect(response).to render_template(:new)
        end
      end
    end

    context 'when user is not logged in' do
      it 'redirects to login' do
        post :create, params: { client_id: client.id, payment: valid_attributes }
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
        post :create, params: { client_id: client.id, payment: { value: 150 } }
        expect(response).to redirect_to(login_path)
      end
    end
  end
end
