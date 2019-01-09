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

require 'rails_helper'

RSpec.describe Tag, type: :model do
  subject { build(:tag) }

  it 'has a valid factory' do
    should be_valid
  end

  it 'is invalid without a name' do
    subject.name = nil
    should be_invalid
  end

  it 'is invalid when a tag exists with the same name' do
    create(:tag, name: subject.name)
    should be_invalid
  end
end
