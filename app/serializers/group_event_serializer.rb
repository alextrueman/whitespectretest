class GroupEventSerializer
  include FastJsonapi::ObjectSerializer

  attributes :name, :description, :duration, :location

  attribute :start_at do |object|
    object.start_at&.strftime('%m/%d/%Y')
  end
  attribute :end_at do |object|
    object.end_at&.strftime('%m/%d/%Y')
  end
end
