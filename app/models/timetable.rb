class Timetable < ApplicationRecord
    belongs_to :course, foreign_key: "course_id"
end
