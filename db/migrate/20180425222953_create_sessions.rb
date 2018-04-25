# frozen_string_literal: true

class CreateSessions < ActiveRecord::Migration[5.2]
  def change
    # Here we're creating a table called `sessions`. It's connected to the `Session` model.
    # We define that a Session references a User. This creates a `user_id` column, which
    # relates to a record in the `users` table. We're also asking Rails to create a foreign key.
    # See more:
    # http://edgeapi.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference
    create_table :sessions do |t|
      t.references :user, foreign_key: true, null: false
      t.string     :token, null: false, index: { unique: true }
      t.timestamp  :expires_at, null: false
      t.timestamps
    end
  end
end
