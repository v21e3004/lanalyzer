class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :enrollments, class_name: "Enrollment", foreign_key: "user_id", dependent: :destroy
  has_many :courses, through: :enrollments, source: :course
  has_many :events
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
