class Certificate < ApplicationRecord
  include Ransackable
  belongs_to :student
  enum :certificate_type, {
    degree: 1,       # Bằng Cấp
    certificate: 2,  # Chứng Chỉ
    certification: 3 # Chứng Nhận
  }

  # Metadata attributes for form handling
  attr_accessor :metadata_issuer, :metadata_description, :metadata_image_path

  # Degree metadata attributes
  attr_accessor :metadata_degree_level, :metadata_degree_major, :metadata_degree_specialization,
                :metadata_degree_grade, :metadata_degree_graduation_year

  # Certificate metadata attributes
  attr_accessor :metadata_certificate_provider, :metadata_certificate_field,
                :metadata_certificate_score, :metadata_certificate_level

  # Certification metadata attributes
  attr_accessor :metadata_certification_event, :metadata_certification_achievement,
                :metadata_certification_duration, :metadata_certification_organizer

  validates :code, presence: true, uniqueness: true
  validates :title, presence: true
  validates :certificate_type, presence: true, inclusion: { in: Certificate.certificate_types.keys }

  validates :issue_date, presence: true

  # Fix: Change the enum syntax to use hash syntax

  # Callback để đảm bảo metadata_id được set
  after_create :ensure_metadata_created
  # Xử lý metadata sau khi certificate được lưu
  after_create :process_pending_metadata
  before_destroy :cleanup_metadata

  # Phương thức để truy cập metadata
  def metadata
    return nil if metadata_id.blank?

    CertificateMetadata.find(metadata_id)
  end

  # Phương thức để cập nhật metadata
  def metadata=(metadata_attributes)
    return if metadata_attributes.blank?

    if new_record?
      @pending_metadata = metadata_attributes
    elsif metadata_id.present? && metadata
      metadata.update(metadata_attributes)
    else
      meta = CertificateMetadata.create(metadata_attributes.merge(certificate_id: id.to_s,
                                                                  certificate_type: certificate_type))
      update_column(:metadata_id, meta.id.to_s)
    end
  end

  def process_pending_metadata
    return if @pending_metadata.blank?

    meta = CertificateMetadata.create(@pending_metadata.merge(certificate_id: id.to_s,
                                                              certificate_type: certificate_type))
    update_column(:metadata_id, meta.id.to_s)
    @pending_metadata = nil
  end

  private

  def ensure_metadata_created
    return if metadata_id.present?

    metadata = CertificateMetadata.create!(
      certificate_id: id.to_s,
      certificate_type: certificate_type
    )
    update_column(:metadata_id, metadata.id.to_s)
  end

  def cleanup_metadata
    CertificateMetadata.where(certificate_id: id.to_s).destroy_all if metadata_id.present?
  end
end
