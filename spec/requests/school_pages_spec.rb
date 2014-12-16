require 'spec_helper'

describe "School pages" do

  subject { page }

  describe "index" do

    let(:user) { FactoryGirl.create(:admin) }
    let!(:school) { FactoryGirl.create(:school) }

    before do
      sign_in user
      visit schools_path
    end

    it { should have_title('All Schools') }
    it { should have_content('All Schools') }

    describe "pagination" do

      before(:all) do 
        30.times { FactoryGirl.create(:school) }
      end
      after(:all)  { School.delete_all }

      it { should have_selector('div.pagination') }

      it "should list each school" do
        School.paginate(page: 1).each do |school|
          expect(page).to have_selector('li', text: school.name)
        end
      end
    end

    describe "delete links" do

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit schools_path
        end

        it { should have_link('Delete', href: school_path(School.first)) }
        it "should be able to delete school" do
          expect do
            click_link('Delete', match: :first)
          end.to change(School, :count).by(-1)
        end
      end
    end
  end

  describe "create" do

  	let(:user) { FactoryGirl.create(:admin) }

    before do 
    	sign_in user
    	visit new_school_path
    end

    let(:submit) { "Create School" }

    describe "with invalid information" do
      it "should not create a school" do
        expect { click_button submit }.not_to change(School, :count)
      end
    end

    describe "with valid information" do
      before do
        fill_in "Name",         with: "Test School"
        fill_in "Website",        with: "www.test.edu"
        fill_in "Address",     with: "1 Test Street"
      end

      it "should create a school" do
        expect { click_button submit }.to change(School, :count).by(1)
      end

      describe "after saving the school" do
        before { click_button submit }
        let(:school) { School.find_by(name: 'Test School') }

        it { should have_title(school.name) }
        it { should have_selector('div.alert.alert-success', text: 'School created') }
      end
    end
  end

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    let(:school) { FactoryGirl.create(:school) }
    before do
    	user.schools<<school
      sign_in user
      visit edit_school_path(school)
    end

    describe "page" do
      it { should have_content("Edit School") }
      it { should have_title("Edit School") }
    end

    describe "with invalid information" do
      before do
      	fill_in "Name", with: ""
      	click_button "Save changes"
      end

      it { should have_content('error') }
    end

    describe "with valid information" do
      let(:new_name)  { "New Name" }
      let(:new_address) { "New Street" }
      before do
        fill_in "Name",             with: new_name
        fill_in "Address",            with: new_address
        fill_in "Website",     with: school.website
        click_button "Save changes"
      end

      it { should have_title(new_name) }
      it { should have_selector('div.alert.alert-success') }
      specify { expect(school.reload.name).to  eq new_name }
      specify { expect(school.reload.address).to eq new_address }
    end
  end
end