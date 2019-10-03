class CreateGroupEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :group_events do |t|
      t.string   :name
      t.string   :location
      t.text     :description
      t.integer  :status, default: 0
      t.integer  :duration
      t.datetime :start_at
      t.datetime :end_at

      t.timestamps
    end
  end
end
