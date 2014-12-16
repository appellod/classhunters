class School < ActiveRecord::Base
	has_and_belongs_to_many :users
	has_many :courses, dependent: :destroy
	has_many :instructors, dependent: :destroy

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
	after_validation :geocode

	searchable do
		text :name, :address, :phone, :website, :city, :state, :zip
	end

	def self.import(file)
	  spreadsheet = open_spreadsheet(file)
	  header = spreadsheet.row(1)
	  (2..spreadsheet.last_row).each do |i|
	    row = Hash[[header, spreadsheet.row(i)].transpose]
	    school = School.where(name: row["name"])

	    if school.count == 1
	      school.first.update_attributes(row)
	    else
	      School.create!(row)
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
