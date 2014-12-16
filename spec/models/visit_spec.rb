require 'spec_helper'

describe Visit do
  before do 
	  @visit = Visit.new()
	end
  subject { @visit }

  it { should respond_to(:remote_ip) }
  it { should respond_to(:referrer) }

  it { should be_valid }
end
