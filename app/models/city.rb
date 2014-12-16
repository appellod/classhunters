class City < ActiveRecord::Base
	searchable do
		text :zip, :state, :city
	end
end
