require 'rails_helper'

RSpec.describe PlansController do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:plan) { create(:plan, user: user) }
  let(:other_plan) { create(:plan, user: other_user) }

  describe 'GET #index' do
    context 'when user is logged in' do
      before { session[:user_id] = user.id }

      it 'returns a successful response' do
        get :index
        expect(response).to be_successful
      end

      it "assigns user's plans" do
        user_plan = create(:plan, user: user)
        other_user_plan = create(:plan, user: other_user)
        get :index
        expect(assigns(:plans)).to include(user_plan)
        expect(assigns(:plans)).not_to include(other_user_plan)
      end

      it 'paginates results' do
        6.times { create(:plan, user: user) }
        get :index
        expect(assigns(:plans)).to respond_to(:current_page) # WillPaginate collection
      end
    end

    context 'when user is not logged in' do
      it 'raises error due to nil current_user' do
        expect { get :index }.to raise_error(NoMethodError)
      end
    end
  end

  describe 'GET #new' do
    context 'when user is logged in' do
      before { session[:user_id] = user.id }

      it 'returns a successful response' do
        get :new
        expect(response).to be_successful
      end

      it 'assigns a new plan' do
        get :new
        expect(assigns(:plan)).to be_a_new(Plan)
      end
    end

    context 'when user is not logged in' do
      it 'redirects to login' do
        get :new
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe 'GET #edit' do
    context 'when user is logged in and owns the plan' do
      before { session[:user_id] = user.id }

      it 'returns a successful response' do
        get :edit, params: { id: plan.id }
        expect(response).to be_successful
      end

      it 'assigns the requested plan' do
        get :edit, params: { id: plan.id }
        expect(assigns(:plan)).to eq(plan)
      end
    end

    context 'when user is not logged in' do
      it 'redirects to login' do
        get :edit, params: { id: plan.id }
        expect(response).to redirect_to(login_path)
      end
    end

    context "when accessing another user's plan" do
      before { session[:user_id] = other_user.id }

      it 'redirects to root' do
        get :edit, params: { id: plan.id }
        expect(response).to redirect_to(root_path)
      end

      it 'sets flash danger message' do
        get :edit, params: { id: plan.id }
        expect(flash[:danger]).to eq('Você não possui acesso a esse dado')
      end
    end

    context 'when plan does not exist' do
      before { session[:user_id] = user.id }

      it 'redirects to plans index' do
        get :edit, params: { id: 99_999 }
        expect(response).to redirect_to(plans_path)
      end

      it 'sets flash danger message' do
        get :edit, params: { id: 99_999 }
        expect(flash[:danger]).to eq('Plano não encontrado')
      end
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) do
      {
        description: 'Plano Teste',
        value: 150.00,
      }
    end

    context 'when user is logged in' do
      before { session[:user_id] = user.id }

      context 'with valid parameters' do
        it 'creates a new plan' do
          expect do
            post :create, params: { plan: valid_attributes }
          end.to change(Plan, :count).by(1)
        end

        it 'assigns the plan to the current user' do
          post :create, params: { plan: valid_attributes }
          expect(assigns(:plan).user).to eq(user)
        end

        it 'redirects to plans index' do
          post :create, params: { plan: valid_attributes }
          expect(response).to redirect_to(plans_path)
        end

        it 'sets flash success message' do
          post :create, params: { plan: valid_attributes }
          expect(flash[:success]).to eq('Plano criado com sucesso')
        end
      end

      context 'with invalid parameters' do
        it 'does not create a new plan' do
          expect do
            post :create, params: { plan: { description: '' } }
          end.not_to change(Plan, :count)
        end

        it 'redirects to new plan path' do
          post :create, params: { plan: { description: '' } }
          expect(response).to redirect_to(new_plan_path)
        end

        it 'sets flash danger message' do
          post :create, params: { plan: { description: '' } }
          expect(flash[:danger]).to include('Erro ao criar plano')
        end
      end
    end

    context 'when user is not logged in' do
      it 'redirects to login' do
        post :create, params: { plan: valid_attributes }
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe 'PATCH #update' do
    let(:new_attributes) { { description: 'Plano Atualizado', value: 200.00 } }

    context 'when user is logged in and owns the plan' do
      before { session[:user_id] = user.id }

      context 'with valid parameters' do
        it 'updates the requested plan' do
          patch :update, params: { id: plan.id, plan: new_attributes }
          plan.reload
          expect(plan.description).to eq('Plano Atualizado')
          expect(plan.value).to eq(200.00)
        end

        it 'redirects to plans index' do
          patch :update, params: { id: plan.id, plan: new_attributes }
          expect(response).to redirect_to(plans_path)
        end

        it 'sets flash success message' do
          patch :update, params: { id: plan.id, plan: new_attributes }
          expect(flash[:success]).to eq('Plano atualizado com sucesso')
        end
      end

      context 'with invalid parameters' do
        it 'does not update the plan' do
          original_description = plan.description
          patch :update, params: { id: plan.id, plan: { description: '' } }
          plan.reload
          expect(plan.description).to eq(original_description)
        end

        it 'redirects to edit plan path' do
          patch :update, params: { id: plan.id, plan: { description: '' } }
          expect(response).to redirect_to(edit_plan_path(plan))
        end

        it 'sets flash danger message' do
          patch :update, params: { id: plan.id, plan: { description: '' } }
          expect(flash[:danger]).to include('Erro ao atualizar plano')
        end
      end
    end

    context 'when user is not logged in' do
      it 'redirects to login' do
        patch :update, params: { id: plan.id, plan: new_attributes }
        expect(response).to redirect_to(login_path)
      end
    end

    context "when accessing another user's plan" do
      before { session[:user_id] = other_user.id }

      it 'redirects to root' do
        patch :update, params: { id: plan.id, plan: new_attributes }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when user is logged in and owns the plan' do
      before { session[:user_id] = user.id }

      it 'destroys the requested plan' do
        plan_to_delete = create(:plan, user: user)
        expect do
          delete :destroy, params: { id: plan_to_delete.id }
        end.to change(Plan, :count).by(-1)
      end

      it 'redirects to plans index' do
        delete :destroy, params: { id: plan.id }
        expect(response).to redirect_to(plans_path)
      end

      it 'sets flash success message' do
        delete :destroy, params: { id: plan.id }
        expect(flash[:success]).to eq('Plano deletado com sucesso')
      end

      context 'when plan deletion fails' do
        before do
          allow_any_instance_of(Plan).to receive(:destroy).and_return(false)
        end

        it 'sets flash danger message' do
          delete :destroy, params: { id: plan.id }
          expect(flash[:danger]).to eq('Erro ao deletar o plano')
        end
      end
    end

    context 'when user is not logged in' do
      it 'redirects to login' do
        delete :destroy, params: { id: plan.id }
        expect(response).to redirect_to(login_path)
      end
    end

    context "when accessing another user's plan" do
      before { session[:user_id] = other_user.id }

      it 'redirects to root' do
        delete :destroy, params: { id: plan.id }
        expect(response).to redirect_to(root_path)
      end

      it 'does not delete the plan' do
        plan_id = plan.id
        delete :destroy, params: { id: plan_id }
        expect(Plan.find_by(id: plan_id)).to be_present
      end
    end

    context 'when plan does not exist' do
      before { session[:user_id] = user.id }

      it 'redirects to plans index' do
        delete :destroy, params: { id: 99_999 }
        expect(response).to redirect_to(plans_path)
      end

      it 'sets flash danger message for not found plan' do
        delete :destroy, params: { id: 99_999 }
        expect(flash[:danger]).to eq('Plano não encontrado')
      end
    end
  end

  describe 'authorization' do
    context 'when user is not logged in' do
      it 'redirects new to login' do
        get :new
        expect(response).to redirect_to(login_path)
      end

      it 'redirects edit to login' do
        get :edit, params: { id: plan.id }
        expect(response).to redirect_to(login_path)
      end

      it 'redirects create to login' do
        post :create, params: { plan: { description: 'Test' } }
        expect(response).to redirect_to(login_path)
      end

      it 'redirects update to login' do
        patch :update, params: { id: plan.id, plan: { description: 'Test' } }
        expect(response).to redirect_to(login_path)
      end

      it 'redirects destroy to login' do
        delete :destroy, params: { id: plan.id }
        expect(response).to redirect_to(login_path)
      end
    end
  end
end
