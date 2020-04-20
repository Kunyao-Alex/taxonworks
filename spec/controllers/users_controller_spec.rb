require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe UsersController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # User. As you add validations to User, be sure to
  # adjust the attributes here as well.

  let(:valid_attributes) { {name: 'uzer', password: '123aBc!!!', password_confirmation: '123aBc!!!', email: 'foo@example.com', created_by_id: 1, updated_by_id: 1} }
  let(:invalid_attributes) {{ 'email' => 'invalid value' }  } 

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # UsersController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe 'GET index' do
    before { 
      sign_in_administrator 
    } 

    it 'assigns all users as @users' do
      user = User.create!(valid_attributes)
      get :index, params: {}, session: valid_session
      expect(assigns(:users)).to eq(User.all.order(:name, :email))
    end
  end

  describe 'GET show' do
    before { sign_in_administrator } 
    it 'assigns the requested user as @user' do
      user = User.create!(valid_attributes)
      get :show, params: {id: user.to_param}, session: valid_session
      expect(assigns(:user)).to eq(user)
    end
  end

  describe 'GET new' do
    before { sign_in_administrator } 
    it 'assigns a new user as @user' do
      get :new, params: {}, session: valid_session
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe 'GET edit' do
    before { sign_in_administrator } 
    it 'assigns the requested user as @user' do
      user = User.create! valid_attributes
      get :edit, params: {id: user.to_param}, session: valid_session
      expect(assigns(:user)).to eq(user)
    end
  end

  describe 'POST create' do
    before { sign_in_project_administrator }
     
    describe 'with valid params' do
      it 'creates a new User' do
        expect {
          post :create, params: {user: valid_attributes}, session: valid_session
        }.to change(User, :count).by(1)
      end

      it 'assigns a newly created user as @user' do
        post :create, params: {user: valid_attributes}, session: valid_session
        expect(assigns(:user)).to be_a(User)
        expect(assigns(:user)).to be_persisted
      end
      
      it 'flags the newly created user for password reset when created by a superuser' do
        post :create, params: {user: valid_attributes, project_id: 1}
        expect(User.find_by_email(valid_attributes[:email]).is_flagged_for_password_reset).to be_truthy
      end

      # TODO: maybe not
      it 'redirects to the created user' do
        post :create, params: {user: valid_attributes}, session: valid_session
        expect(response).to redirect_to(root_path)
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved user as @user' do
        # Trigger the behavior that occurs when invalid params are submitted
        post :create, params: {user: invalid_attributes}, session: valid_session
        expect(assigns(:user)).to be_a_new(User)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        post :create, params: {user: invalid_attributes}, session: valid_session
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT update' do
    before { sign_in_administrator }  # update!

    let(:new_attributes) {
      {   'email' => 'fooa1@bar.com' }
    }

    describe 'with valid params' do
      it 'updates the requested user' do
        user = User.create! valid_attributes
        put :update, params: {id: user.to_param, user: new_attributes}, session: valid_session
        user.reload
        expect(user.email).to eq('fooa1@bar.com') 
      end

      it 'assigns the requested user as @user' do
        user = User.create! valid_attributes
        put :update, params: {id: user.to_param, user: valid_attributes}, session: valid_session
        expect(assigns(:user)).to eq(user)
      end

      it 'redirects to the user' do
        user = User.create! valid_attributes
        put :update, params: {id: user.to_param, user: valid_attributes}, session: valid_session
        expect(response).to redirect_to(user)
      end
    end

    describe 'with invalid params' do
      it 'assigns the user as @user' do
        user = User.create! valid_attributes
        put :update, params: {id: user.to_param, user: invalid_attributes}, session: valid_session
        expect(assigns(:user)).to eq(user)
      end

      it "re-renders the 'edit' template" do
        user = User.create! valid_attributes
        put :update, params: {id: user.to_param, user: invalid_attributes}, session: valid_session
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE destroy' do
    before { sign_in_administrator } 

    it 'destroys the requested user' do
      user = User.create! valid_attributes
      expect {
        delete :destroy, params: {id: user.to_param}, session: valid_session
      }.to change(User, :count).by(-1)
    end

    it 'redirects to the users list' do
      user = User.create! valid_attributes
      delete :destroy, params: {id: user.to_param}, session: valid_session
      expect(response).to redirect_to(root_path)
    end
  end
  
  describe 'GET forgot_password' do
    
    it 'renders password reset template' do
      get :forgot_password, params: {}, session: valid_session
      expect(response).to render_template(:forgot_password)
    end
    
  end
  
  describe 'POST send_password_reset' do
    
    context 'when e-mail not provided' do
      let(:examples) {[{}, {email: nil}, {email: ''}, {email: ' '}]}
      
      it 'redirects to forgot_password' do
        examples.each do |param|
          post :send_password_reset, params: param, session: valid_session
          expect(response).to redirect_to(:forgot_password)
        end
      end
      
      it 'notifies no e-mail was provided in flash[:notice]' do
        examples.each do |param|
          post :send_password_reset, params: param, session: valid_session
          expect(flash[:notice]).to match(/^No e-mail was given/)
        end
      end

    end
    
    context 'when e-mail does not exist' do
      before {post :send_password_reset, params: {email: 'non-existant@example.com'}, session: valid_session}
      
      it 'redirects to forgot_password' do
        expect(response).to redirect_to(:forgot_password)
      end
      
      it 'notifies the e-mail does not exist' do
        expect(flash[:notice]).to match(/^The supplied e-mail does not belong to a registered user/)
      end
    end
    
    context 'when valid e-mail' do
      let(:user) { FactoryBot.create(:valid_user) }
      
      describe 'response to browser' do
        before {post :send_password_reset, params: {email: user.email}, session: valid_session}

        it 'renders e-mail sent notification page' do
          expect(response).to render_template(:send_password_reset)
        end
      
        it 'does not set flash[:notice]' do
          expect(flash[:notice]).to be_nil
        end
      end
     
      describe 'mailing' do 
        it 'sends an e-mail' do
          count = ActionMailer::Base.deliveries.count + 1
          post :send_password_reset, params: {email: user.email}, session: valid_session
          expect(ActionMailer::Base.deliveries.count).to eq(count)
        end
      end
    end
  end
  
  describe 'GET password_reset' do

    context 'when invalid token' do
      it 'renders invalid token template' do
        get :password_reset, params: {token: 'INVALID'}
        expect(response).to render_template('users/invalid_token.html.erb')
      end
    end
    
    context 'when token expired' do
      let!(:token) do
        Current.user_id = 1
        user = User.find_by_id(Current.user_id)
        token = user.generate_password_reset_token
        user.save!
        token
      end
      
      it 'renders invalid token template' do
        Timecop.travel(1.day.from_now) do
          get :password_reset, params: {token: token}
          expect(response).to render_template('users/invalid_token.html.erb')
        end
      end
    end
    
  end

end
