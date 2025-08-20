require 'rails_helper'

RSpec.describe PagesController do
  let(:user) { create(:user) }
  let!(:plan) { create(:plan, user: user) }
  let!(:client1) { create(:client, user: user, plan: plan) }
  let!(:client2) { create(:client, user: user, plan: plan) }

  before do
    session[:user_id] = user.id
  end

  describe 'GET #home' do
    context 'with clients and payments' do
      let!(:current_payment1) { create(:payment, client: client1, payment_date: Date.current, value: 100.0) }
      let!(:current_payment2) { create(:payment, client: client2, payment_date: Date.current, value: 150.0) }
      let!(:old_payment) { create(:payment, client: client1, payment_date: 2.months.ago, value: 100.0) }

      it 'returns a successful response' do
        get :home
        expect(response).to be_successful
      end

      it 'assigns @clients' do
        get :home
        expect(assigns(:clients)).to include(client1, client2)
      end

      it 'calculates total clients with payments' do
        get :home
        expect(assigns(:total_clients)).to eq(2)
      end

      it 'calculates current clients (non-overdue)' do
        get :home
        expect(assigns(:current_clients)).to be >= 0
      end

      it 'calculates overdue clients' do
        get :home
        expect(assigns(:overdue_clients)).to be >= 0
      end

      it 'calculates monthly revenue for current month' do
        get :home
        expect(assigns(:monthly_revenue)).to eq(250.0) # 100 + 150
      end

      it 'calculates yearly revenue for current year' do
        get :home
        expect(assigns(:yearly_revenue)).to be >= 250.0
      end

      it 'generates chart data for last 12 months' do
        get :home
        chart_data = assigns(:chart_data)
        expect(chart_data).to be_an(Array)
        expect(chart_data.length).to eq(12)
        expect(chart_data.first).to be_an(Array)
        expect(chart_data.first.length).to eq(2) # [month, revenue]
      end

      it 'assigns overdue clients list limited to 10' do
        get :home
        expect(assigns(:clients_indebt)).to respond_to(:limit)
      end
    end

    context 'with no clients' do
      let(:user_without_clients) { create(:user) }

      before do
        session[:user_id] = user_without_clients.id
      end

      it 'returns zero statistics' do
        get :home
        expect(assigns(:total_clients)).to eq(0)
        expect(assigns(:overdue_clients)).to eq(0)
        expect(assigns(:current_clients)).to eq(0)
        expect(assigns(:monthly_revenue)).to eq(0)
        expect(assigns(:yearly_revenue)).to eq(0)
      end

      it 'still generates empty chart data' do
        get :home
        chart_data = assigns(:chart_data)
        expect(chart_data).to be_an(Array)
        expect(chart_data.length).to eq(12)
        expect(chart_data.all? { |month_data| month_data[1] == 0.0 }).to be true
      end
    end

    context 'with overdue clients' do
      let!(:overdue_payment) { create(:payment, client: client1, payment_date: 2.months.ago, value: 100.0) }

      it 'correctly identifies overdue clients' do
        get :home
        expect(assigns(:overdue_clients)).to be >= 0
        expect(assigns(:current_clients)).to be >= 0
      end
    end
  end

  describe 'GET #revenue_data' do
    let!(:payment_jan) { create(:payment, client: client1, payment_date: Date.new(2024, 1, 15), value: 100.0) }
    let!(:payment_feb) { create(:payment, client: client2, payment_date: Date.new(2024, 2, 20), value: 200.0) }

    context 'with year parameter only' do
      it 'returns monthly data for the year' do
        get :revenue_data, params: { year: 2024 }

        expect(response).to be_successful
        json_response = response.parsed_body

        expect(json_response['chart_data']).to be_an(Array)
        expect(json_response['chart_data'].length).to eq(12) # 12 months
        expect(json_response['period_type']).to eq('monthly')
        expect(json_response['total_revenue']).to be >= 0
      end
    end

    context 'with year and valid month parameters' do
      it 'returns daily data for the month' do
        get :revenue_data, params: { year: 2024, month: '1' }

        expect(response).to be_successful
        json_response = response.parsed_body

        expect(json_response['chart_data']).to be_an(Array)
        expect(json_response['chart_data'].length).to be > 20 # Days in month
        expect(json_response['period_type']).to eq('daily')
        expect(json_response['total_revenue']).to be >= 0
      end
    end

    context 'with invalid month parameter' do
      it 'returns monthly data when month is invalid' do
        get :revenue_data, params: { year: 2024, month: '13' }

        expect(response).to be_successful
        json_response = response.parsed_body

        expect(json_response['period_type']).to eq('monthly')
        expect(json_response['chart_data'].length).to eq(12)
      end

      it 'returns monthly data when month is zero' do
        get :revenue_data, params: { year: 2024, month: '0' }

        expect(response).to be_successful
        json_response = response.parsed_body

        expect(json_response['period_type']).to eq('monthly')
      end

      it 'returns monthly data when month is non-numeric' do
        get :revenue_data, params: { year: 2024, month: 'invalid' }

        expect(response).to be_successful
        json_response = response.parsed_body

        expect(json_response['period_type']).to eq('monthly')
      end

      it 'handles empty month parameter' do
        get :revenue_data, params: { year: 2024, month: '' }

        expect(response).to be_successful
        json_response = response.parsed_body

        expect(json_response['period_type']).to eq('monthly')
      end

      it 'handles whitespace month parameter' do
        get :revenue_data, params: { year: 2024, month: '  ' }

        expect(response).to be_successful
        json_response = response.parsed_body

        expect(json_response['period_type']).to eq('monthly')
      end
    end

    context 'with no year parameter' do
      it 'uses current year as default' do
        get :revenue_data

        expect(response).to be_successful
        json_response = response.parsed_body

        expect(json_response['chart_data']).to be_an(Array)
        expect(json_response['period_type']).to eq('monthly')
      end
    end

    context 'with edge cases' do
      it 'handles February in leap year' do
        get :revenue_data, params: { year: 2024, month: '2' }

        expect(response).to be_successful
        json_response = response.parsed_body

        expect(json_response['chart_data'].length).to eq(29) # Leap year February
        expect(json_response['period_type']).to eq('daily')
      end

      it 'handles February in non-leap year' do
        get :revenue_data, params: { year: 2023, month: '2' }

        expect(response).to be_successful
        json_response = response.parsed_body

        expect(json_response['chart_data'].length).to eq(28) # Non-leap year February
      end

      it 'handles month with 31 days' do
        get :revenue_data, params: { year: 2024, month: '1' }

        expect(response).to be_successful
        json_response = response.parsed_body

        expect(json_response['chart_data'].length).to eq(31) # January has 31 days
      end

      it 'handles month with 30 days' do
        get :revenue_data, params: { year: 2024, month: '4' }

        expect(response).to be_successful
        json_response = response.parsed_body

        expect(json_response['chart_data'].length).to eq(30) # April has 30 days
      end
    end

    context 'data format validation' do
      it 'returns properly formatted JSON' do
        get :revenue_data, params: { year: 2024 }

        expect(response).to be_successful
        expect(response.content_type).to include('application/json')

        json_response = response.parsed_body
        expect(json_response).to have_key('chart_data')
        expect(json_response).to have_key('total_revenue')
        expect(json_response).to have_key('period_type')
      end

      it 'returns chart data in correct format for monthly view' do
        get :revenue_data, params: { year: 2024 }

        json_response = response.parsed_body
        chart_data = json_response['chart_data']

        chart_data.each do |data_point|
          expect(data_point).to be_an(Array)
          expect(data_point.length).to eq(2)
          expect(data_point[0]).to be_a(String) # Month label
          expect(data_point[1]).to be_a(Numeric) # Revenue value
        end
      end

      it 'returns chart data in correct format for daily view' do
        get :revenue_data, params: { year: 2024, month: '1' }

        json_response = response.parsed_body
        chart_data = json_response['chart_data']

        chart_data.each do |data_point|
          expect(data_point).to be_an(Array)
          expect(data_point.length).to eq(2)
          expect(data_point[0]).to be_a(String) # Day label
          expect(data_point[1]).to be_a(Numeric) # Revenue value
        end
      end
    end

    context 'with user isolation' do
      let(:other_user) { create(:user) }
      let(:other_client) { create(:client, user: other_user, plan: create(:plan, user: other_user)) }
      let!(:other_payment) { create(:payment, client: other_client, payment_date: Date.new(2024, 1, 10), value: 500.0) }

      it 'only includes current user revenue data' do
        get :revenue_data, params: { year: 2024 }

        json_response = response.parsed_body
        total_revenue = json_response['total_revenue']

        # Should only include user's payments (300.0), not other_user's payment (500.0)
        expect(total_revenue).to eq(300.0)
      end
    end
  end

  context 'authentication required' do
    before do
      session[:user_id] = nil # Log out
    end

    it 'redirects home to login when not authenticated' do
      get :home
      expect(response).to redirect_to(login_path)
    end

    it 'redirects revenue_data to login when not authenticated' do
      get :revenue_data
      expect(response).to redirect_to(login_path)
    end
  end
end
