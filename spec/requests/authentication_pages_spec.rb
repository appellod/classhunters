require 'spec_helper'

describe "Authentication" do

  subject { page }

  describe "signin page" do
    before { visit signin_path }

    it { should have_content('Sign in') }
    it { should have_title('Sign in') }
  end

  describe "signin" do
    before { visit signin_path }

    describe "with invalid information" do
      before { click_button "Sign in" }

      it { should have_title('Sign in') }
      it { should have_selector('div.alert.alert-error') }

      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_selector('div.alert.alert-error') }
      end
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in user }

      it { should have_title("Dashboard") }
      it { should have_link('Sign Out',    href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }
    end
  end

  describe "authorization" do

    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      let(:school) { FactoryGirl.create(:school) }
      let(:course) { FactoryGirl.create(:course, school: school) }

      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          fill_in "Email",    with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

        describe "after signing in" do

          it "should render the desired protected page" do
            expect(page).to have_title('Edit User')
          end
        end
      end

      describe "in the Users controller" do

        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_title('Sign in') }
        end

        describe "submitting to the update action" do
          before { patch user_path(user) }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "visiting the user index" do
          before { visit users_path }
          it { should have_title('Sign in') }
        end
      end

      describe "in the Schools controller" do

        describe "visiting the edit page" do
          before { visit edit_school_path(school) }
          it { should have_title('Sign in') }
        end

        describe "submitting to the update action" do
          before { patch school_path(school) }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "visiting the school index" do
          before { visit schools_path }
          it { should have_title('Sign in') }
        end

        describe "visiting the new school page" do
          before { visit new_school_path }
          it { should have_title('Sign in') }
        end

        describe "submitting to the create action" do
          before { post schools_path }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end

      describe "in the Courses controller" do

        describe "visiting the edit page" do
          before { visit edit_school_course_path(school, course) }
          it { should have_title('Sign in') }
        end

        describe "submitting to the update action" do
          before { patch school_course_path(school, course) }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "visiting the school index" do
          before { visit school_courses_path(school) }
          it { should have_title('Sign in') }
        end

        describe "visiting the new school page" do
          before { visit new_school_course_path(school) }
          it { should have_title('Sign in') }
        end

        describe "submitting to the create action" do
          before { post school_courses_path(school) }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end
    end

    describe "as wrong user" do
      describe "for Users controller" do
        let(:user) { FactoryGirl.create(:user) }
        let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
        before { sign_in user, no_capybara: true }

        describe "submitting a GET request to the Users#edit action" do
          before { get edit_user_path(wrong_user) }
          specify { expect(response.body).not_to match(full_title('Edit user')) }
          specify { expect(response).to redirect_to(root_url) }
        end

        describe "submitting a PATCH request to the Users#update action" do
          before { patch user_path(wrong_user) }
          specify { expect(response).to redirect_to(root_url) }
        end
      end

      describe "for Schools controller" do
        let(:user) { FactoryGirl.create(:user) }
        let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
        let(:school) { FactoryGirl.create(:school) }
        before do
          user.schools<<school
          sign_in wrong_user, no_capybara: true
        end

        describe "submitting a GET request to the Schools#edit action" do
          before { get edit_school_path(school) }
          specify { expect(response.body).not_to match(full_title('Edit School')) }
          specify { expect(response).to redirect_to(root_url) }
        end

        describe "submitting a PATCH request to the Schools#update action" do
          before { patch school_path(school) }
          specify { expect(response).to redirect_to(root_url) }
        end

        describe "submitting a DELETE request to the Schools#destroy action" do
          before { delete school_path(school) }
          specify { expect(response).to redirect_to(root_url) }
        end
      end

      describe "for Courses controller" do
        let(:user) { FactoryGirl.create(:user) }
        let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
        let(:school) { FactoryGirl.create(:school) }
        let(:course) { FactoryGirl.create(:course, school: school) }
        before do
          user.schools<<school
          sign_in wrong_user, no_capybara: true
        end

        describe "submitting a GET request to the Courses#edit action" do
          before { get edit_school_course_path(school, course) }
          specify { expect(response.body).not_to match(full_title('Edit Course')) }
          specify { expect(response).to redirect_to(root_url) }
        end

        describe "submitting a PATCH request to the Courses#update action" do
          before { patch school_course_path(school, course) }
          specify { expect(response).to redirect_to(root_url) }
        end

        describe "submitting a DELETE request to the Schools#destroy action" do
          before { delete school_course_path(school, course) }
          specify { expect(response).to redirect_to(root_url) }
        end
      end
    end

    describe "as non-admin user" do
      describe "for Users controller" do
        let(:user) { FactoryGirl.create(:user) }
        let(:non_admin) { FactoryGirl.create(:user) }

        before { sign_in non_admin, no_capybara: true }

        describe "submitting a DELETE request to the Users#destroy action" do
          before { delete user_path(user) }
          specify { expect(response).to redirect_to(root_url) }
        end
      end

      describe "for Schools controller" do
        let(:user) { FactoryGirl.create(:user) }
        let(:non_admin) { FactoryGirl.create(:user) }
        let(:school) { FactoryGirl.create(:school) }

        before do
          user.schools<<school
          sign_in non_admin, no_capybara: true
        end

        describe "submitting a DELETE request to the Schools#destroy action" do
          before { delete school_path(school) }
          specify { expect(response).to redirect_to(root_url) }
        end
      end
    end
  end
end