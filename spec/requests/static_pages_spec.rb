require 'spec_helper'

describe "StaticPages" do
	subject { page }

  describe "home page" do
  	before { visit root_path }
  	
  	it { should have_title(full_title("")) }
  	it { should have_content(site_name()) }
  end

  describe "about page" do
  	before { visit about_path }

  	it { should have_title(full_title("About")) }
  	it { should have_content("About") }
  end
end
