require 'rails_helper'

RSpec.describe GroupEvent, type: :model do
  it { should have_db_column(:name).of_type(:string) }
  it { should have_db_column(:description).of_type(:text) }
  it { should have_db_column(:location).of_type(:string) }
  it { should have_db_column(:start_at).of_type(:datetime) }
  it { should have_db_column(:end_at).of_type(:datetime) }
  it { should have_db_column(:duration).of_type(:integer) }
  it do 
    should(
      have_db_column(:status)
        .of_type(:integer)
        .with_options(default: 'draft')
    )
  end

  it { should define_enum_for(:status).with_values(%i[draft published archived]) }

  describe 'validate start_at' do
    it 'should return error if start_at is blank' do
      params = { name: 'some_name', end_at: Time.zone.now + 2.days }

      group_event = described_class.new(params)

      expect(group_event.valid?).to eq(false)
      expect(group_event.errors[:start_at]).to include("can't be blank")
    end
  end

  describe 'validate duration' do
    it 'should return error if duration not between start_at and end_at' do
      params = { name: 'some_name', start_at: Time.zone.now, end_at: Time.zone.now + 2.days, duration: 2 }

      group_event = described_class.new(params)

      expect(group_event.valid?).to eq(false)
      expect(group_event.errors[:duration]).to include('is not valid')
    end
  end

  describe '#publish' do
    it 'should return errors for blank fields' do
      subject.status = described_class.statuses[:published]

      expect(subject.valid?).to eq(false)

      expect(subject.errors[:name]).to eq(["can't be blank"])
      expect(subject.errors[:description]).to eq(["can't be blank"])
      expect(subject.errors[:location]).to eq(["can't be blank"])
      expect(subject.errors[:start_at]).to eq(["can't be blank"])
      expect(subject.errors[:end_at]).to eq(["can't be blank"])
    end

    it 'should return true for all filled fields' do
      group_event = create(:group_event, :ready_for_publish)

      group_event.status = described_class.statuses[:published]

      expect(group_event.valid?).to eq(true)
    end
  end
end 
