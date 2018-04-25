# frozen_string_literal: true

class EnableExtensions < ActiveRecord::Migration[5.2]
  def change
    # This installs the Postgres extension called `citext`.
    # It provides a new datatype which behaves like a string,
    # but is case-insensitive. This is handy for email addresses.
    # See more: https://www.postgresql.org/docs/current/static/citext.html
    enable_extension 'citext'
  end
end
