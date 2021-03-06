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

class TagSerializer < ApplicationSerializer
  attribute :id
  attribute :name
end
