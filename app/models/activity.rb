class Activity < ApplicationRecord
    belongs_to :course, foreign_key: "course_id"
    has_many :events
    # belongs_to :event, foreign_key: "activity_id"
    validates :activity_id, uniqueness: true
end
