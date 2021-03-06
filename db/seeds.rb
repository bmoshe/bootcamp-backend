# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the `rails db:seed` command (or created alongside the database with `db:setup`).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Here's a test User account. You'll be able to login with these credentials.
# You can replace the email with your own Platterz email, if you so choose.
User.find_or_create_by!(email: 'test@platterz.ca') do |user|
  user.password = 'password'
end

# Here we create some Tags for the system to use.
# They're stored in the database, and will be made available to the frontend.
%w[
  blocking
  fun
  important
  personal
  ponies
  urgent
].each do |name|
  Tag.find_or_create_by!(name: name)
end
