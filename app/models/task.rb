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

class Task < ApplicationRecord
  belongs_to :user

  validates :name, presence: true

  before_save :set_completed_at, if: -> { completed_changed?(to: true) }

private

  def set_completed_at
    self.completed_at = Time.current
  end
end
