require 'rails_helper'

RSpec.describe 'Turbo Stream Interactions' do
  let(:user) { create(:user) }
  let(:plan) { create(:plan, user: user) }
  let(:client) { create(:client, user: user, plan: plan) }

  before do
    login_as(user)
  end

  describe 'Adding measurements via Turbo Stream' do
    it 'adds new measurement without page reload', :skip do
      skip 'Turbo Stream testing requires JavaScript driver'
      visit client_path(client)

      click_link 'Nova Medição'

      # Form should appear
      expect(page).to have_css('#measurement_form')

      within '#measurement_form' do
        fill_in 'Altura', with: '180'
        fill_in 'Peso', with: '75'
        fill_in 'Peito', with: '105'
        fill_in 'Braço esquerdo', with: '35'
        fill_in 'Braço direito', with: '35'
        fill_in 'Cintura', with: '85'
        fill_in 'Abdômen', with: '90'
        fill_in 'Quadril', with: '100'
        fill_in 'Coxa esquerda', with: '60'
        fill_in 'Coxa direita', with: '60'

        click_button 'Salvar'
      end

      # Success message should appear
      expect(page).to have_content('Medida adicionada com sucesso')

      # Form should disappear
      expect(page).not_to have_css('#measurement_form')

      # New measurement should appear in list
      expect(page).to have_content('180 cm')
      expect(page).to have_content('75 kg')

      # Verify in database
      expect(client.measurements.count).to eq(1)
      expect(client.measurements.last.height).to eq(180)
    end

    it 'shows validation errors without page reload', :skip do
      skip 'Turbo Stream testing requires JavaScript driver'
      visit client_path(client)

      click_link 'Nova Medição'

      within '#measurement_form' do
        fill_in 'Altura', with: '-10' # invalid height
        fill_in 'Peso', with: '-5' # invalid weight
        click_button 'Salvar'
      end

      # Form should still be visible with errors
      expect(page).to have_css('#measurement_form')
      expect(page).to have_content('erro') # error message

      # No measurement should be created
      expect(client.measurements.count).to eq(0)
    end
  end

  describe 'Adding payments via Turbo Stream' do
    it 'adds new payment without page reload', :skip do
      skip 'Turbo Stream testing requires JavaScript driver'
      visit client_path(client)

      click_link 'Novo Pagamento'

      expect(page).to have_css('#payment_form')

      within '#payment_form' do
        fill_in 'Valor', with: '150.00'
        fill_in 'Data do pagamento', with: Date.current.strftime('%Y-%m-%d')
        click_button 'Salvar'
      end

      expect(page).to have_content('Pagamento registrado com sucesso')
      expect(page).not_to have_css('#payment_form')
      expect(page).to have_content('R$ 150,00')

      expect(client.payments.count).to eq(1)
      expect(client.payments.last.value).to eq(150.00)
    end
  end

  describe 'Adding skinfolds via Turbo Stream' do
    it 'adds new skinfold measurement without page reload', :skip do
      skip 'Turbo Stream testing requires JavaScript driver'
      visit client_path(client)

      click_link 'Novas Dobras'

      expect(page).to have_css('#skinfold_form')

      within '#skinfold_form' do
        fill_in 'Peito', with: '10.5'
        fill_in 'Axilar média', with: '8.2'
        fill_in 'Subescapular', with: '12.1'
        fill_in 'Bíceps', with: '6.8'
        fill_in 'Tríceps', with: '9.4'
        fill_in 'Abdominal', with: '15.3'
        fill_in 'Supra-ilíaca', with: '11.7'
        fill_in 'Coxa', with: '14.2'
        fill_in 'Panturrilha', with: '8.9'

        click_button 'Salvar'
      end

      expect(page).to have_content('Dobras cutâneas adicionadas com sucesso')
      expect(page).not_to have_css('#skinfold_form')
      expect(page).to have_content('10.5') # chest measurement

      expect(client.skinfolds.count).to eq(1)
      expect(client.skinfolds.last.chest).to eq(10.5)
    end
  end

  describe 'Client search with Turbo Stream' do
    let!(:client1) { create(:client, name: 'João Silva', user: user, plan: plan) }
    let!(:client2) { create(:client, name: 'Maria Santos', user: user, plan: plan) }

    it 'filters clients in real-time', :skip do
      skip 'Turbo Stream testing requires JavaScript driver'
      visit clients_path

      expect(page).to have_content('João Silva')
      expect(page).to have_content('Maria Santos')

      fill_in 'search', with: 'João'

      # Wait for Turbo Stream response
      expect(page).to have_content('João Silva')
      expect(page).not_to have_content('Maria Santos')
    end
  end

  describe 'Client deletion with Turbo Stream' do
    let!(:client_to_delete) { create(:client, name: 'Cliente para Deletar', user: user, plan: plan) }

    it 'removes client without page reload', :skip do
      skip 'Turbo Stream testing requires JavaScript driver'
      visit clients_path

      expect(page).to have_content('Cliente para Deletar')

      within("#client_#{client_to_delete.id}") do
        accept_confirm do
          click_link 'Excluir'
        end
      end

      # Client should disappear from list
      expect(page).not_to have_content('Cliente para Deletar')

      # Success message should appear
      expect(page).to have_content('Cliente deletado com sucesso')

      # Statistics should update
      expect(page).to have_content('Total') # stats section should be updated

      # Verify in database
      expect(Client.find_by(id: client_to_delete.id)).to be_nil
    end
  end

  describe 'Form validation with Turbo Stream' do
    it 'shows client creation errors without page reload', :skip do
      skip 'Turbo Stream testing requires JavaScript driver'
      visit clients_path
      click_link 'Novo Cliente'

      # Submit empty form
      click_button 'Criar Cliente'

      # Should show validation errors
      expect(page).to have_content('erro')

      # Form should still be visible
      expect(page).to have_css('form')

      # URL should remain the same
      expect(page).to have_current_path(clients_path)
    end
  end
end
