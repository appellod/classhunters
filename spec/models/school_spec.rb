require 'spec_helper'

describe School do
  before do 
	  @school = School.new(name: "Test User", website: "www.test.edu",
	  	address: "1 Test Street", latitude: 25, longitude: 25)
	end
  subject { @school }

  it { should respond_to(:name) }
  it { should respond_to(:website) }
  it { should respond_to(:address) }
  it { should respond_to(:latitude) }
  it { should respond_to(:longitude) }

  it { should be_valid }

  describe "when name is empty" do
  	before { @school.name = "" }

  	it { should_not be_valid }
  end

  describe "when address is empty" do
  	before { @school.address = "" }

  	it { should_not be_valid }
  end

  describe "when name is already taken" do
    before do
      school_with_same_name = @school.dup
      school_with_same_name.name = @school.name.upcase
      school_with_same_name.save
    end

    it { should_not be_valid }
  end
end
