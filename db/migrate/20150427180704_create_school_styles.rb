class CreateSchoolStyles < ActiveRecord::Migration
  def change
    create_table :school_styles do |t|
      t.string :foreground
      t.string :background
      t.references :school, index: true

      t.timestamps
    end
  end
end
