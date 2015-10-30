class CreateAppreviews < ActiveRecord::Migration
  def change
    create_table :appreviews do |t|
      t.string :appname
      t.integer :star
      t.text :title
      t.text :author
      t.text :content
      t.string :date
      t.string :country
      t.string :version

      t.references :appdetail

      t.timestamps
    end
  end
end
