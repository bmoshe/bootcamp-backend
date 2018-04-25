# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    # This installs the Postgres extension called `citext`.
    # It provides a new datatype which behaves like a string, but is case-insensitive.
    # This is handy for making sure that email addresses are unique.
    # See more: https://www.postgresql.org/docs/current/static/citext.html
    enable_extension 'citext'

    # Here we create a table called `users`. The `User` model reads from and writes to this table.
    # Rails will automatically add a surrogate Primary Key (called `id`) to tables we create this way.
    # We also create columns to store the email address and password hash for the user.
    # Lastly, `.timestamps` adds `created_at` and `updated_at` timestamp columns, which Rails manages.
    # More information: http://edgeguides.rubyonrails.org/active_record_migrations.html#creating-a-table
    create_table :users do |t|
      t.citext :email, null: false, index: { unique: true }
      t.string :password_digest, null: false
      t.timestamps
    end
  end
end
