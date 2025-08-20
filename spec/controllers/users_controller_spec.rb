require 'rails_helper'

RSpec.describe UsersController do
  let(:user) { create(:user) }
  let(:admin_user) { create(:user, admin: true) }
  let(:other_user) { create(:user) }

  describe 'GET #index' do
    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns paginated users' do
      create_list(:user, 6)
      get :index
      expect(assigns(:users)).to respond_to(:current_page) # WillPaginate collection
    end
  end

  describe 'GET #new' do
    it 'returns a successful response' do
      get :new
      expect(response).to be_successful
    end

    it 'assigns a new user' do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end

    it 'uses auth layout' do
      get :new
      expect(response).to render_template(layout: 'auth')
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) do
      {
        username: 'testuser',
        business_name: 'Test Gym',
        email: 'test@example.com',
        password: 'password123',
        password_confirmation: 'password123',
      }
    end

    context 'when user is admin' do
      before { session[:user_id] = admin_user.id }

      context 'with valid parameters' do
        it 'creates a new user' do
          expect do
            post :create, params: { user: valid_attributes }
          end.to change(User, :count).by(1)
        end

        it 'logs in the new user' do
          post :create, params: { user: valid_attributes }
          expect(session[:user_id]).to eq(assigns(:user).id)
        end

        it 'redirects to root path' do
          post :create, params: { user: valid_attributes }
          expect(response).to redirect_to(root_path)
        end

        it 'sets welcome flash message' do
          post :create, params: { user: valid_attributes }
          expect(flash[:success]).to include('Bem-vindo ao GymApp')
        end
      end

      context 'with invalid parameters' do
        it 'does not create a new user' do
          expect do
            post :create, params: { user: { username: '' } }
          end.not_to change(User, :count)
        end

        it 'redirects to signup path' do
          post :create, params: { user: { username: '' } }
          expect(response).to redirect_to(signup_path)
        end

        it 'sets error flash message' do
          post :create, params: { user: { username: '' } }
          expect(flash[:danger]).to include('Erro ao criar usuário')
        end
      end
    end

    context 'when user is not admin' do
      before { session[:user_id] = user.id }

      it 'redirects to root path' do
        post :create, params: { user: valid_attributes }
        expect(response).to redirect_to(root_path)
      end

      it 'sets permission error flash message' do
        post :create, params: { user: valid_attributes }
        expect(flash[:danger]).to eq('Você não possui permissão para essa ação')
      end
    end

    context 'when user is not logged in' do
      it 'creates a new user' do
        expect do
          post :create, params: { user: valid_attributes }
        end.to change(User, :count).by(1)
      end
    end
  end

  describe 'GET #show' do
    context 'when viewing own profile' do
      before { session[:user_id] = user.id }

      it 'returns a successful response' do
        get :show, params: { id: user.id }
        expect(response).to be_successful
      end

      it 'assigns the requested user' do
        get :show, params: { id: user.id }
        expect(assigns(:user)).to eq(user)
      end

      it 'assigns user plans' do
        plan1 = create(:plan, user: user)
        plan2 = create(:plan, user: user)
        get :show, params: { id: user.id }
        expect(assigns(:user_plans)).to include(plan1, plan2)
      end
    end

    context 'when viewing another user profile' do
      before { session[:user_id] = other_user.id }

      it 'redirects to root path' do
        get :show, params: { id: user.id }
        expect(response).to redirect_to(root_path)
      end

      it 'sets permission error flash message' do
        get :show, params: { id: user.id }
        expect(flash[:danger]).to eq('Você só pode editar sua própria conta')
      end
    end
  end

  describe 'GET #edit' do
    context 'when editing own profile' do
      before { session[:user_id] = user.id }

      it 'returns a successful response' do
        get :edit, params: { id: user.id }
        expect(response).to be_successful
      end

      it 'assigns the requested user' do
        get :edit, params: { id: user.id }
        expect(assigns(:user)).to eq(user)
      end
    end

    context 'when admin edits another user' do
      before { session[:user_id] = admin_user.id }

      it 'returns a successful response' do
        get :edit, params: { id: user.id }
        expect(response).to be_successful
      end
    end

    context 'when non-admin tries to edit another user' do
      before { session[:user_id] = other_user.id }

      it 'redirects to root path' do
        get :edit, params: { id: user.id }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'PATCH #update' do
    let(:new_attributes) { { username: 'newusername', business_name: 'New Gym' } }

    context 'when updating own profile' do
      before { session[:user_id] = user.id }

      context 'with valid parameters' do
        it 'updates the requested user' do
          patch :update, params: { id: user.id, user: new_attributes }
          user.reload
          expect(user.username).to eq('newusername')
          expect(user.business_name).to eq('New Gym')
        end

        it 'redirects to the user' do
          patch :update, params: { id: user.id, user: new_attributes }
          expect(response).to redirect_to(user_path(user))
        end

        it 'sets success flash message' do
          patch :update, params: { id: user.id, user: new_attributes }
          expect(flash[:success]).to eq('Sua conta foi atualizada com sucesso')
        end
      end

      context 'with invalid parameters' do
        it 'does not update the user' do
          original_username = user.username
          patch :update, params: { id: user.id, user: { username: '' } }
          user.reload
          expect(user.username).to eq(original_username)
        end

        it 'redirects to edit user path' do
          patch :update, params: { id: user.id, user: { username: '' } }
          expect(response).to redirect_to(edit_user_path(user))
        end

        it 'sets error flash message' do
          patch :update, params: { id: user.id, user: { username: '' } }
          expect(flash[:danger]).to include('Erro ao atualizar usuário')
        end
      end
    end

    context 'when admin updates another user' do
      before { session[:user_id] = admin_user.id }

      it 'updates the requested user' do
        patch :update, params: { id: user.id, user: new_attributes }
        user.reload
        expect(user.username).to eq('newusername')
      end
    end

    context 'when non-admin tries to update another user' do
      before { session[:user_id] = other_user.id }

      it 'redirects to root path' do
        patch :update, params: { id: user.id, user: new_attributes }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when admin deletes user' do
      before { session[:user_id] = admin_user.id }

      it 'destroys the requested user' do
        user_to_delete = create(:user)
        expect do
          delete :destroy, params: { id: user_to_delete.id }
        end.to change(User, :count).by(-1)
      end

      it 'redirects to users index' do
        delete :destroy, params: { id: user.id }
        expect(response).to redirect_to(users_path)
      end

      it 'sets deletion flash message' do
        delete :destroy, params: { id: user.id }
        expect(flash[:danger]).to eq('Usuário e Planos criados por ele foram deletados')
      end
    end

    context 'when non-admin tries to delete user' do
      before { session[:user_id] = user.id }

      it 'redirects to root path' do
        delete :destroy, params: { id: other_user.id }
        expect(response).to redirect_to(root_path)
      end

      it 'does not delete the user' do
        user_id = other_user.id
        delete :destroy, params: { id: user_id }
        expect(User.find_by(id: user_id)).to be_present
      end
    end

    context 'when not logged in' do
      it 'redirects to users path due to require_admin' do
        delete :destroy, params: { id: user.id }
        expect(response).to redirect_to(users_path)
      end
    end
  end

  describe 'authorization methods' do
    describe '#require_admin' do
      context 'when user is admin' do
        before { session[:user_id] = admin_user.id }

        it 'allows access to admin actions' do
          post :create, params: { user: { username: 'test' } }
          expect(response).not_to redirect_to(root_path)
        end
      end

      context 'when user is not admin' do
        before { session[:user_id] = user.id }

        it 'redirects admin actions to root' do
          post :create, params: { user: { username: 'test' } }
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end
end
