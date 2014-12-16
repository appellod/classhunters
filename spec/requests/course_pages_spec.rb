require 'spec_helper'

describe "CoursePages" do

	subject { page }

  describe "create" do

  	let(:user) { FactoryGirl.create(:user) }
  	let(:school) { FactoryGirl.create(:school)}
  	let(:course) { FactoryGirl.create(:course, school: school) }

    before do
    	sign_in user
    	visit new_school_course_path(school)
    end

    let(:submit) { "Create Course" }

    describe "with invalid information" do
      it "should not create a course" do
        expect { click_button submit }.not_to change(Course, :count)
      end
    end

    describe "with valid information" do
      before do
        fill_in "Name",         with: "Test School"
        fill_in "Description",        with: "Test Description"
        fill_in "Department",     with: "Test"
        fill_in "Number", with: "25"
      end

      it "should create a course" do
        expect { click_button submit }.to change(Course, :count).by(1)
      end

      describe "after saving the course" do
        before { click_button submit }
        let(:course) { Course.find_by(name: 'Test School') }

        it { should have_title(course.name) }
        it { should have_selector('div.alert.alert-success', text: 'Course created') }
      end
    end
  end

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    let(:school) { FactoryGirl.create(:school) }
    let(:course) { FactoryGirl.create(:course, school: school) }
    before do
    	user.schools<<school
      sign_in user
      visit edit_school_course_path(school, course)
    end

    describe "page" do
      it { should have_content("Edit Course") }
      it { should have_title("Edit Course") }
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
      let(:new_description) { "New Description" }
      before do
        fill_in "Name",             with: new_name
        fill_in "Description",            with: new_description
        fill_in "Department",     with: course.department
        fill_in "Number", with: course.number
        click_button "Save changes"
      end

      it { should have_title(new_name) }
      it { should have_selector('div.alert.alert-success') }
      specify { expect(course.reload.name).to  eq new_name }
      specify { expect(course.reload.description).to eq new_description }
    end
  end
end
