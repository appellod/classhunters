class AddCrawlTypeToSchools < ActiveRecord::Migration
  def change
  	add_column :schools, :crawl_type, :string
  end
end
