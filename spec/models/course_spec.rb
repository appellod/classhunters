require 'spec_helper'

describe Course do
	let(:school) { FactoryGirl.create(:school) }
  before do 
	  @course = school.courses.build(name: "Test Class", description: "A test class",
	  	department: "Test", number: "1")
	end
  subject { @course }

  it { should respond_to(:name) }
  it { should respond_to(:description) }
  it { should respond_to(:department) }
  it { should respond_to(:number) }
  its(:school) { should eq school }

  it { should be_valid }

  describe "when name is empty" do
  	before { @course.name = "" }

  	it { should_not be_valid }
  end

  describe "when description is empty" do
  	before { @course.description = "" }

  	it { should_not be_valid }
  end
end
