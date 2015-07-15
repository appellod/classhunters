class AddCrawlUrlToSchools < ActiveRecord::Migration
  def change
  	add_column :schools, :crawl_url, :text
  end
end
