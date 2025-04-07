class StudentMetadata
  include Mongoid::Document
  include Mongoid::Timestamps
  include HasStorage

  field :student_id, type: String
  field :phone, type: String
  field :major, type: String
  field :specialization, type: String
  index({ student_id: 1 }, { unique: true })

  validates :student_id, presence: true, uniqueness: true
end
