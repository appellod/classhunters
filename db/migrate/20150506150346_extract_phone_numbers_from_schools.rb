class ExtractPhoneNumbersFromSchools < ActiveRecord::Migration
  def change
  	School.all.each do |school|
  		school.phone_numbers.create(name: nil, number: school.phone)
  	end
  	remove_column :schools, :phone
  end
end
