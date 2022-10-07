class Course < ApplicationRecord
    # has_many :user_courses, dependent: :destroy
    # has_many :users, through: :user_courses
    has_many :enrollments, class_name: "Enrollment", foreign_key: "course_id", dependent: :destroy
    has_many :users, through: :enrollments, source: :user
    has_many :events
    has_many :activities
    
    validates :course_code, uniqueness: true
    validates :course_code, :name, presence: true
end
