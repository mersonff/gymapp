require 'rails_helper'

RSpec.describe "Authentication", type: :request do
  let(:user) { create(:user) }

  describe "GET /login" do
    it "returns successful response" do
      get login_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /login" do
    context "with valid credentials" do
      it "logs in user and redirects" do
        post login_path, params: {
          session: {
            email: user.email,
            password: user.password
          }
        }
        
        expect(response).to have_http_status(:redirect)
        expect(session[:user_id]).to eq(user.id)
      end
    end

    context "with invalid credentials" do
      it "renders login form with error" do
        post login_path, params: {
          session: {
            email: user.email,
            password: "wrong_password"
          }
        }
        
        expect(response).to have_http_status(:redirect)
        expect(session[:user_id]).to be_nil
      end
    end
  end

  describe "DELETE /logout" do
    before do
      post login_path, params: {
        session: {
          email: user.email,
          password: user.password
        }
      }
    end

    it "logs out user and redirects" do
      delete logout_path
      
      expect(response).to have_http_status(:redirect)
      expect(session[:user_id]).to be_nil
    end
  end
end