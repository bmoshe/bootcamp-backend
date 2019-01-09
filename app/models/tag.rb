# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
#
#  id         :bigint(8)        not null, primary key
#  name       :citext           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_tags_on_name  (name) UNIQUE
#

class Tag < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  scope :search_by_name, lambda { |search_query|
    search_query = "%#{sanitize_sql_like(search_query)}%"
    where(arel_table[:name].matches(search_query))
  }
end
