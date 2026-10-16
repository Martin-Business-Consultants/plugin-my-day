# My day's tables, prefixed with its key. A bundle is one person's (the core's users, by id); its
# pins point at the core's todos by id, in the order to do them. A todo deleted or converted in the
# core just drops out of its bundles.
class CreateMyDay < ActiveRecord::Migration[8.1]
  def change
    create_table :my_day_bundles do |t|
      t.integer :user_id, null: false, index: true
      t.string :name, null: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    create_table :my_day_pins do |t|
      t.references :bundle, null: false, foreign_key: { to_table: :my_day_bundles }
      t.integer :todo_id, null: false, index: true
      t.integer :position, null: false, default: 0
      t.timestamps
      t.index %i[bundle_id todo_id], unique: true
    end
  end
end
