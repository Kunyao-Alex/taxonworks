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

RSpec.describe ObservationMatricesController, type: :controller do
  before(:each) {
    sign_in
  }

  # This should return the minimal set of attributes required to create a valid
  # Matrix. As you add validations to Matrix, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    strip_housekeeping_attributes(FactoryBot.build(:valid_observation_matrix).attributes)  
  }

  let(:invalid_attributes) {
    {name: nil} 
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # MatricesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe 'GET #index' do
    it 'assigns observation_matrices as @recent_objects' do
      observation_matrix = ObservationMatrix.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(assigns(:recent_objects)).to eq([observation_matrix])
    end
  end

  describe 'GET #show' do
    it 'assigns the requested matrix as @observation_matrix' do
      observation_matrix = ObservationMatrix.create! valid_attributes
      get :show, params: {id: observation_matrix.to_param}
      expect(assigns(:observation_matrix)).to eq(observation_matrix)
    end
  end

  describe 'GET #new' do
    it 'assigns a new matrix as @observation_matrix' do
      get :new, params: {}, session: valid_session
      expect(response).to redirect_to(new_matrix_task_path)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested matrix as @observation_matrix' do
      observation_matrix = ObservationMatrix.create! valid_attributes
      get :edit, params: {id: observation_matrix.to_param}, session: valid_session
      expect(assigns(:observation_matrix)).to eq(observation_matrix)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new ObservationMatrix' do
        expect {
          post :create, params: {observation_matrix: valid_attributes}, session: valid_session
        }.to change(ObservationMatrix, :count).by(1)
      end

      it 'assigns a newly created matrix as @observation_matrix' do
        post :create, params: {observation_matrix: valid_attributes}, session: valid_session
        expect(assigns(:observation_matrix)).to be_a(ObservationMatrix)
        expect(assigns(:observation_matrix)).to be_persisted
      end

      it 'redirects to the created matrix' do
        post :create, params: {observation_matrix: valid_attributes}, session: valid_session
        expect(response).to redirect_to(ObservationMatrix.last)
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved matrix as @observation_matrix' do
        post :create, params: {observation_matrix: invalid_attributes}, session: valid_session
        expect(assigns(:observation_matrix)).to be_a_new(ObservationMatrix)
      end

      it "re-renders the 'new' template" do
        post :create, params: {observation_matrix: invalid_attributes}, session: valid_session
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) {
        {name: 'new name'}
      }

      it 'updates the requested observation_matrix' do
        observation_matrix = ObservationMatrix.create! valid_attributes
        put :update, params: {id: observation_matrix.to_param, observation_matrix: new_attributes}, session: valid_session
        observation_matrix.reload
        expect(observation_matrix.name).to eq('new name')
      end

      it 'assigns the requested observation_matrix as @observation_matrix' do
        observation_matrix = ObservationMatrix.create! valid_attributes
        put :update, params: {id: observation_matrix.to_param, observation_matrix: valid_attributes}, session: valid_session
        expect(assigns(:observation_matrix)).to eq(observation_matrix)
      end

      it 'redirects to the observation_matrix' do
        observation_matrix = ObservationMatrix.create! valid_attributes
        put :update, params: {id: observation_matrix.to_param, observation_matrix: valid_attributes}, session: valid_session
        expect(response).to redirect_to(observation_matrix)
      end
    end

    context 'with invalid params' do
      it 'assigns the observation_matrix as @observation_matrix' do
        observation_matrix = ObservationMatrix.create! valid_attributes
        put :update, params: {id: observation_matrix.to_param, observation_matrix: invalid_attributes}, session: valid_session
        expect(assigns(:observation_matrix)).to eq(observation_matrix)
      end

      it "re-renders the 'edit' template" do
        observation_matrix = ObservationMatrix.create! valid_attributes
        put :update, params: {id: observation_matrix.to_param, observation_matrix: invalid_attributes}, session: valid_session
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested matrix' do
      observation_matrix = ObservationMatrix.create! valid_attributes
      expect {
        delete :destroy, params: {id: observation_matrix.to_param}, session: valid_session
      }.to change(ObservationMatrix, :count).by(-1)
    end

    it 'redirects to the observation_matrices list' do
      observation_matrix = ObservationMatrix.create! valid_attributes
      delete :destroy, params: {id: observation_matrix.to_param}, session: valid_session
      expect(response).to redirect_to(observation_matrices_url)
    end
  end

end
