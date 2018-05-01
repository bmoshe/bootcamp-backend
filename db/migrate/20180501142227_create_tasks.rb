# frozen_string_literal: true

class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.references :user, foreign_key: true, null: false
      t.string     :name, null: false
      t.boolean    :completed, null: false, default: false
      t.timestamp  :completed_at
      t.timestamps
    end
  end
end
