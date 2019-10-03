require 'rails_helper'

RSpec.describe 'Group Events API', type: :request do
  describe 'GET /group_events' do
    it 'returns status 200' do
      get '/group_events'

      expect(response.status).to eq(200)
    end

    it 'returns published group events' do
      create_list(:group_event, 5, :published)
      create_list(:group_event, 2, name: 'some foo')

      get '/group_events'

      expect(parsed_body).not_to be_empty
      expect(parsed_body.size).to eq 5
    end
  end

  describe 'GET /group_events/:id' do
    context 'when group_event exists and published' do
      it 'returns the group_event' do
        group_event = create(:group_event, :published)

        get "/group_events/#{group_event.id}"

        expect(parsed_body).not_to be_empty
        expect(parsed_body['id'].to_i).to eq(group_event.id)
      end

      it 'returns status 200' do
        group_event = create(:group_event, :published)

        get "/group_events/#{group_event.id}"

        expect(response.status).to eq(200)
      end
    end

    # There are might be different rules from buisnes side,
    # but let's say we decided to return drafted group event.
    # And not return 'archived'(removed).
    context 'when group_event exists and draft' do
      it 'returns the group_event' do
        group_event = create(:group_event, :draft)

        get "/group_events/#{group_event.id}"

        expect(parsed_body).not_to be_empty
        expect(parsed_body['id'].to_i).to eq(group_event.id)
      end

      it 'returns status 200' do
        group_event = create(:group_event, :draft)

        get "/group_events/#{group_event.id}"

        expect(response.status).to eq(200)
      end
    end

    context 'when group_event exists and archived' do
      it 'returns status 404' do
        group_event = create(:group_event, :archived)

        get "/group_events/#{group_event.id}"

        expect(response.status).to eq(404)
      end

      it 'returns a not found message' do
        group_event = create(:group_event, :archived)

        get "/group_events/#{group_event.id}"

        expect(response.body).to match(/Couldn't find GroupEvent/)
      end
    end

    context 'when group_event does not exist' do
      it 'returns status 404' do
        get "/group_events/#{rand(10)}"

        expect(response.status).to eq(404)
      end

      it 'returns a not found message' do
        get "/group_events/#{rand(10)}"

        expect(response.body).to match(/Couldn't find GroupEvent/)
      end
    end
  end

  describe 'POST /group_events' do
    context 'when user passes start_at and end_at' do
      it 'creates a group event' do
        group_event = build(:group_event, :ready_for_publish)

        post '/group_events', params: group_event.attributes

        parsed_attributes = parsed_body['attributes']
        expect(parsed_attributes['name']).to eq(group_event.name)
        expect(parsed_attributes['description']).to eq(group_event.description)
        expect(parsed_attributes['start_at']).to(
          eq(format_date(group_event.start_at))
        )
        expect(parsed_attributes['end_at']).to(
          eq(format_date(group_event.end_at))
        )
      end

      it 'returns status 201' do
        group_event = build(:group_event, :ready_for_publish)

        post '/group_events', params: group_event.attributes

        expect(response.status).to eq(201)
      end
    end

    context 'when user passes start_at and duration' do
      it 'creates a group event' do
        params = { name: 'some name', start_at: Time.zone.now, duration: 11 }
        expected_end_at = params[:start_at] + (params[:duration] - 1).days

        post '/group_events', params: params

        parsed_attributes = parsed_body['attributes']

        expect(parsed_attributes['name']).to eq(params[:name])
        expect(parsed_attributes['start_at']).to(
          eq(format_date(params[:start_at]))
        )
        expect(parsed_attributes['end_at']).to(
          eq(format_date(expected_end_at))
        )
        expect(parsed_attributes['duration']).to eq(params[:duration])
      end

      it 'returns status 201' do
        params = { name: 'some name', start_at: Time.zone.now, duration: 10 }

        post '/group_events', params: params

        expect(response.status).to eq(201)
      end
    end

    context 'when user passes end_at and duration' do
      it 'returns a validation error message' do
        params = { name: 'some name', end_at: DateTime.now, duration: 10 }

        post '/group_events', params: params

        expect(response.body)
          .to match(/Start at can't be blank/)
      end
    end

    context 'when user passes start_at, end_at and duration' do
      it 'creates a group event if params is valid' do
        params = {
          name: 'some name',
          start_at: Time.zone.now,
          end_at: Time.zone.now + 9.days, 
          duration: 10
        }

        post '/group_events', params: params

        parsed_attributes = parsed_body['attributes']

        expect(parsed_attributes['name']).to eq(params[:name])
        expect(parsed_attributes['start_at']).to(
          eq(format_date(params[:start_at]))
        )
        expect(parsed_attributes['end_at']).to(
          eq(format_date(params[:end_at]))
        )
        expect(parsed_attributes['duration']).to eq(params[:duration])
      end

      it 'returns a validation error message if duration is invalid' do
        params = {
          name: 'some name',
          start_at: DateTime.now,
          end_at: DateTime.now + 10.days, 
          duration: 10
        }

        post '/group_events', params: params

        expect(response.body)
          .to match(/Validation failed: Duration is not valid/)
      end
    end
  end

  describe 'PUT /group_events/:id' do
    context 'when group event exists' do
      it 'updates record' do
        group_event = create(:group_event, :published)
        params = { name: 'some new name' }

        put "/group_events/#{group_event.id}", params: params

        expect(response.body).to be_empty
      end

      it 'return status 204' do
        group_event = create(:group_event, :published)
        params = { name: 'some new name' }

        put "/group_events/#{group_event.id}", params: params

        expect(response.status).to eq(204)
      end
    end
  end

  describe 'PUT /group_events/:id/publish' do
    context 'when group event ready for publish' do
      it 'should change status of group event to published' do
        group_event = create(:group_event, :ready_for_publish)

        expect { put("/group_events/#{group_event.id}/publish") }.to(
          change { group_event.reload.status }
            .from('draft')
            .to('published')
        )
        expect(response.body).to be_empty
      end

      it 'should return status 204' do
        group_event = create(:group_event, :ready_for_publish)

        put "/group_events/#{group_event.id}/publish"

        expect(response.status).to eq(204)
      end
    end
  end

  describe 'DELETE /group_events/:id' do
    context 'when group event exists' do
      it 'change status of group event to archived' do
        group_event = create(:group_event, :published)

        delete "/group_events/#{group_event.id}"

        expect(group_event.reload.archived?).to eq(true)
      end

      it 'return status 204' do
        group_event = create(:group_event, :published)

        delete "/group_events/#{group_event.id}"

        expect(response.status).to eq(204)
      end
    end
  end

  def parsed_body
    JSON.parse(response.body).dig('data')
  end

  def format_date(date)
    date.strftime('%m/%d/%Y')
  end

end
