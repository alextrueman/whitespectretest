FactoryBot.define do
  factory :group_event do
    trait :ready_for_publish do
      sequence(:name) { |n| "group event #{n}" }
      description { 'some description' }
      location { 'some street' }
      start_at { Time.zone.now } 
      end_at { Time.zone.now + 30.days } 
      duration { 31 } 
    end

    trait :published do
      sequence(:name) { |n| "group event #{n}" }
      description { 'some description' }
      location { 'some street' }
      status { GroupEvent.statuses[:published] }
      start_at { Time.zone.now } 
      end_at { Time.zone.now + 30.days } 
      duration { 31 } 
    end

    trait :draft do
      status { GroupEvent.statuses[:draft] }
    end

    trait :archived do
      status { GroupEvent.statuses[:archived] }
    end
  end 
end
