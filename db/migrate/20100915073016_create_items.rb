class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.float :price
      t.string :title

      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
