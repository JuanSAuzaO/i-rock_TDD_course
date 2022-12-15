require 'rails_helper'

describe AchievementsController do
  let(:user) { FactoryBot.create(:user) }
  
  shared_examples "public access to achievements" do
    describe "GET index" do
      
      it "renders :index template" do
        get :index
        expect(response).to render_template(:index)
      end
      
      it "assigns only public achievements to template" do
        public_achievement = FactoryBot.create(:public_achievement, user: user)
        private_achievement = FactoryBot.create(:private_achievement, user: user)
        get :index
        expect(assigns(:achievements)).to match_array([public_achievement])
      end
    end
    
    describe "GET show" do
      let(:achievement) { FactoryBot.create(:public_achievement, user: user)  }
       
      it "renders :show template" do
        get :show, params: {id: achievement}
        expect(response).to render_template(:show)
      end
       
      it "assigns requested achievement to @achievement" do
        get :show, params: {id: achievement}
        expect(assigns(:achievement)).to eq(achievement)
      end
    end
  end
  
  describe "guest user" do
    
    it_behaves_like "public access to achievements"
    
    describe "GET new" do
      it "redirects to login page" do
        get :new
        expect(response).to redirect_to(new_user_session_url)
      end
    end
    
    describe "POST create" do
      it "redirects to login page" do
        post :create, params: { achievement: FactoryBot.attributes_for(:public_achievement) }
        expect(response).to redirect_to(new_user_session_url)
    end
  end
    
    describe "GET edit" do
      it "redirects to login page" do
        get :edit, params: { id: FactoryBot.create(:public_achievement, user: user) }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
    
    describe "PUT update" do
      it "redirects to login page" do
        put :update, params: { id: FactoryBot.create(:public_achievement, user: user), achievement: FactoryBot.attributes_for(:public_achievement, title: "New Title")  }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
    
    describe "DELETE destroy" do
      it "redirects to login page" do
        delete :destroy, params: { id: FactoryBot.create(:public_achievement, user: user) }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
end

  describe "authenticated user" do
    let(:user) { FactoryBot.create(:user) }
    let(:user2) { FactoryBot.create(:user) }
    before do
      sign_in(user)
    end
    
    it_behaves_like "public access to achievements"
    
    describe "GET new" do
    
    it "renders :new template" do
      get :new
      expect(response).to render_template(:new)
    end
    
    it "assigns new Achievement to @achievement" do
      get :new
      expect(assigns(:achievement)).to be_a_new(Achievement)
    end
  end
    
    describe "POST create", :vcr do
    
    context "valid data" do
      let(:valid_data) { FactoryBot.attributes_for(:public_achievement) }
      it "redirects to achievements#show" do
       post :create, params: { achievement: valid_data }
       expect(response).to redirect_to(achievement_path(assigns[:achievement]))
      end
      
      it "creates new achievement in database" do
        expect {
          post :create, params: { achievement: valid_data }
        }.to change(Achievement, :count).by(1)
      end
    end
    
    context "invalid data" do
      let(:invalid_data) { FactoryBot.attributes_for(:public_achievement, title: '') }
      
      it "renders :new template" do
        post :create, params: { achievement: invalid_data }
        expect(response).to render_template(:new) 
      end
      
      it "doesn't create new achievement in the database" do
        expect {
          post :create, params: { achievement: invalid_data }
        }.not_to change(Achievement, :count)
      end
    end
  end
  
  context "is not the owner of the achievement" do
    describe "GET edit" do
      it "redirects to achievements page" do
        get :edit, params: { id: FactoryBot.create(:public_achievement, user: user2) }
        expect(response).to redirect_to(achievements_path)
      end
    end
    
    describe "PUT update" do
      it "redirects to achievements page" do
        put :update, params: { id: FactoryBot.create(:public_achievement, user: user2), achievement: FactoryBot.attributes_for(:public_achievement, title: "New Title")  }
        expect(response).to redirect_to(achievements_path)
      end
    end
    
    describe "DELETE destroy" do
      it "redirects to achievements page" do
        delete :destroy, params: { id: FactoryBot.create(:public_achievement, user: user2) }
        expect(response).to redirect_to(achievements_path)
      end
    end
  end
  context "is the owner of the achievement" do
    let (:achievement) { FactoryBot.create(:public_achievement, user: user) }
    
    describe "GET edit" do
    it "renders :edit template" do
      get :edit, params: { id: achievement }
      expect(response).to render_template(:edit)
    end
    it "assigns the requested achievement to template" do
      get :edit, params: { id: achievement }
      expect(assigns(:achievement)).to eq(achievement)
    end
  end
  
  describe "PUT update" do

    context "valid data" do
      let(:valid_data) { FactoryBot.attributes_for(:public_achievement, title: "New Title")}
      
      it "redirects to achievements#show" do
        put :update, params: { id: achievement, achievement: valid_data }
        expect(response).to redirect_to(achievement)
      end
      
      it "updates achievement in the database" do
        put :update, params: { id: achievement, achievement: valid_data }
        achievement.reload
        expect(achievement.title).to eq("New Title")
      end
    end
    
    context "invalid data" do
      let (:invalid_data) { FactoryBot.attributes_for(:public_achievement, title:"", description: 'new')}
      
      it "renders :edit template" do
        put :update, params: { id: achievement, achievement: invalid_data }
        expect(response).to render_template(:edit)
      end
      it "doesn't update achievement in the database" do
        put :update, params: { id: achievement, achievement: invalid_data  }
        
        expect(achievement.description).not_to eq('new')
      end
    end
  end
  
  describe "DELETE destroy" do
    
    it "redirects to achievements#index" do
      delete :destroy, params: { id: achievement }
      expect(response).to redirect_to(achievements_path)
    end
    it "deletes achievements from database" do
      delete :destroy, params: { id: achievement }
      expect(Achievement.exists?(achievement.id)).to be_falsy
    end
  end
  end
end
end