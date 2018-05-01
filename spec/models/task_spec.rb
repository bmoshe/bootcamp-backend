# frozen_string_literal: true
# == Schema Information
#
# Table name: tasks
#
#  id           :bigint(8)        not null, primary key
#  user_id      :bigint(8)        not null
#  name         :string           not null
#  completed    :boolean          default(FALSE), not null
#  completed_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_tasks_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

require 'rails_helper'

RSpec.describe Task, type: :model do
  subject { build(:task) }

  it 'has a valid factory' do
    should be_valid
  end

  it 'is invalid without a user' do
    subject.user = nil
    should be_invalid
  end

  it 'is invalid without a name' do
    subject.name = nil
    should be_invalid
  end

  it 'sets a completed-at timestamp when it becomes completed' do
    subject.completed = true
    expect { subject.save }.to change { subject.completed_at }
  end
end
