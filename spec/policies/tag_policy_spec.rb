# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TagPolicy do
  subject { described_class }

  permissions :index? do
    it 'permits everyone to view tags' do
      should permit(nil, Tag)
    end
  end
end
