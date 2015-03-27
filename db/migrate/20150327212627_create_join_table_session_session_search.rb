class CreateJoinTableSessionSessionSearch < ActiveRecord::Migration
  def change
    create_join_table :sessions, :session_searches do |t|
      # t.index [:session_id, :session_search_id]
      # t.index [:session_search_id, :session_id]
    end
  end
end
