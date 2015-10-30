class CreateRankings < ActiveRecord::Migration
  def change
    create_table :rankings do |t|
      t.string :apptype
      t.integer :rank
      t.string :appname
      t.text :link
      t.timestamps
    end
  end
end
