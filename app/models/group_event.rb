class GroupEvent < ApplicationRecord
  enum status: %i[draft published archived]

  before_validation :set_duration_or_end_at
  
  with_options if: -> { end_at || duration } do
    validates :start_at, presence: true
  end
  with_options if: -> { start_at && end_at && duration } do
    validate :validate_duration
  end

  with_options if: -> { published? } do
    validates(
      :name, 
      :description, 
      :start_at, 
      :end_at, 
      :duration, 
      :location, 
      presence: true,
    )
  end

  private

  def set_duration_or_end_at
    set_duration if start_at && end_at && !duration
    set_end_at   if start_at && duration && !end_at
  end 

  def set_duration
    self.duration = (start_at.to_datetime..end_at.to_datetime).to_a.size
  end

  def set_end_at
    self.end_at = start_at + (duration - 1).days
  end
  
  def validate_duration
    return if duration == (start_at.to_datetime..end_at.to_datetime).to_a.size

    errors.add(:duration, 'is not valid')
  end
end
