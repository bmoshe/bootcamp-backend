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

class TaskSerializer < ApplicationSerializer
  attribute :id
  attribute :name
  attribute :completed
  attribute :completed_at
end
