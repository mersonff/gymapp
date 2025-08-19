require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'test'
    end
  end

  let(:user) { create(:user) }

  describe '#current_user' do
    context 'when user is logged in' do
      before { session[:user_id] = user.id }

      it 'returns the current user' do
        get :index
        expect(controller.current_user).to eq(user)
      end
    end

    context 'when user is not logged in' do
      it 'returns nil' do
        get :index
        expect(controller.current_user).to be_nil
      end
    end

    context 'when user_id is invalid' do
      before { session[:user_id] = 999999 }

      it 'returns nil' do
        allow(User).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
        get :index
        expect(controller.current_user).to be_nil
      end
    end
  end

  describe '#logged_in?' do
    context 'when user is logged in' do
      before { session[:user_id] = user.id }

      it 'returns true' do
        get :index
        expect(controller.logged_in?).to be true
      end
    end

    context 'when user is not logged in' do
      it 'returns false' do
        get :index
        expect(controller.logged_in?).to be false
      end
    end
  end

  describe '#require_user' do
    controller do
      before_action :require_user

      def index
        render plain: 'authenticated'
      end
    end

    context 'when user is logged in' do
      before { session[:user_id] = user.id }

      it 'allows access' do
        get :index
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq('authenticated')
      end
    end

    context 'when user is not logged in' do
      it 'redirects to login page' do
        allow(controller).to receive(:login_path).and_return('/login')
        get :index
        expect(response).to redirect_to('/login')
      end

      it 'sets flash danger message' do
        allow(controller).to receive(:login_path).and_return('/login')
        get :index
        expect(flash[:danger]).to eq('You need to be logged in to perform that action')
      end
    end
  end

  describe 'helper methods' do
    before { session[:user_id] = user.id }

    it 'makes current_user available to views' do
      get :index
      expect(controller.helpers.current_user).to eq(user)
    end

    it 'makes logged_in? available to views' do
      get :index
      expect(controller.view_context.logged_in?).to be true
    end
  end

  describe 'session management' do
    it 'maintains session across requests' do
      session[:user_id] = user.id
      get :index
      expect(session[:user_id]).to eq(user.id)
    end

    it 'handles nil session gracefully' do
      session[:user_id] = nil
      get :index
      expect(controller.current_user).to be_nil
    end
  end
end