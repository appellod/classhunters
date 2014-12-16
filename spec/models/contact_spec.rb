require 'spec_helper'

describe Contact do
  before do 
	  @contact = Contact.new(name: "Test User", email: "test@test.com", 
	  	school: "Test College", message: "This is a test message")
	end
  subject { @contact }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:school) }
  it { should respond_to(:message) }

  it { should be_valid }

  describe "when name is empty" do
  	before { @contact.name = "" }

  	it { should_not be_valid }
  end

  describe "when email is empty" do
  	before { @contact.email = "" }

  	it { should_not be_valid }
  end
end
