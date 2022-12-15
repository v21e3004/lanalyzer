class Event < ApplicationRecord
  belongs_to :user
  belongs_to :course
  belongs_to :activity, optional: true
  
  # validates :activity_id, uniqueness: true
end
