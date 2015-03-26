class School < ActiveRecord::Base
	has_and_belongs_to_many :users
	has_many :courses, dependent: :destroy
	has_many :instructors, dependent: :destroy
	has_many :course_searches
	has_many :session_searches

	before_validation :strip_attributes

	validates :name, presence: true, uniqueness: { case_sensitive: false }
	validates :address, presence: true

	geocoded_by :address do |obj,results|
	  if geo = results.first
	  	obj.latitude = geo.latitude
	  	obj.longitude = geo.longitude
	    obj.address = geo.address
	    obj.city = geo.city
	    obj.state = geo.state
	    obj.zip = geo.postal_code
	  end
	end
	after_validation :geocode, :if => :address_changed? 

	before_save { self.url = self.name.parameterize }

	searchable do
		text :name, boost: 2.0
		text :address, :phone, :website, :city, :state, :zip
	end

	def strip_attributes
		self.name = self.name.strip
		self.website = self.website.strip unless self.website.nil?
		self.address = self.address.strip unless self.address.nil?
		self.phone = self.phone.strip unless self.phone.nil?
	end

	def to_param
    url
  end

  def self.find(input)
    input.to_i == 0 ? find_by_url(input) : super
  end

	def self.import(file, category)
	  spreadsheet = open_spreadsheet(file)
	  header = spreadsheet.row(1)
	  (2..spreadsheet.last_row).each do |i|
	    row = Hash[[header, spreadsheet.row(i)].transpose]
	    school = School.where(name: row["name"].strip)

	    if school.count == 1
	    	school.first.update_attributes(name: row['name'], address: row['address'], phone: row['phone'], website: row['website'], category: category)
	    else
	      school = School.create!(name: row['name'], address: row['address'], phone: row['phone'], website: row['website'], category: category)
	    end
	    sleep 0.2
	  end
	end

	def self.open_spreadsheet(file)
	  case File.extname(file.original_filename)
	  when ".csv" then Roo::CSV.new(file.path, file_warning: :ignore)
	  when ".xls" then Roo::Excel.new(file.path, file_warning: :ignore)
	  when ".xlsx" then Roo::Excelx.new(file.path, file_warning: :ignore)
	  else raise "Unknown file type: #{file.original_filename}"
	  end
	end
end
