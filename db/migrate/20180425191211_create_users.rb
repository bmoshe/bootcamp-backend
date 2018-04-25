# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    # Here we create a table called `users`. The `User` model reads from and writes to this table.
    # More information: http://edgeguides.rubyonrails.org/active_record_migrations.html#creating-a-table
    create_table :users do |t|
      t.citext :email, null: false, index: { unique: true }
      t.string :password_digest, null: false
      t.timestamps
    end
  end
end
