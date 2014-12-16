require 'spec_helper'

describe Search do
  before do 
	  @search = Search.new()
	end
  subject { @search }

  it { should respond_to(:input) }
  it { should respond_to(:remote_ip) }
  it { should respond_to(:page) }

  it { should be_valid }
end
