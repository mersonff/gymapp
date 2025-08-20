require 'rails_helper'

RSpec.describe "Authentication", type: :system do
  let(:user) { create(:user) }

  describe "Login process" do
    it "allows user to log in with valid credentials" do
      visit login_path
      
      expect(page).to have_content("GymAPP")
      expect(page).to have_content("Acesso Administrativo")
      
      fill_in 'E-mail', with: user.email
      fill_in 'Senha', with: user.password
      click_button 'Acessar Sistema'
      
      expect(page).to have_current_path(home_path)
      expect(page).to have_content("Dashboard")
    end

    it "shows error message with invalid credentials" do
      visit login_path
      
      fill_in 'E-mail', with: user.email
      fill_in 'Senha', with: 'wrong_password'
      click_button 'Acessar Sistema'
      
      expect(page).to have_current_path(login_path)
      expect(page).to have_content("Há algo de errado com as informações fornecidas")
    end

    it "redirects to login when accessing protected pages" do
      visit clients_path
      
      expect(page).to have_current_path(login_path)
      expect(page).to have_content("Acesso Administrativo")
    end
  end

  describe "Logout process" do
    before { login_as(user) }

    it "allows user to log out" do
      # Find logout link in navigation
      within '.border-t.border-slate-700' do
        click_button 'Sair do sistema'
      end
      
      expect(page).to have_current_path(login_path)
      expect(page).to have_content("Acesso Administrativo")
    end
  end

  describe "Navigation after login" do
    before { login_as(user) }

    it "shows main navigation elements" do
      expect(page).to have_link("Clientes")
      expect(page).to have_link("Planos")
    end

    it "displays user information" do
      expect(page).to have_content(user.business_name)
    end
  end
end