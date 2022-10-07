class Event < ApplicationRecord
  belongs_to :user
  belongs_to :course
  belongs_to :activity, optional: true
end
