class GroupEventsController < ApplicationController
  before_action :set_group_event, only: %i[show update publish destroy]

  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: { message: e.message }, status: :not_found
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    render json: { message: e.message }, status: :unprocessable_entity
  end

  def index
    @group_events = GroupEvent.published

    render json: GroupEventSerializer.new(@group_events), status: :ok
  end

  def show
    render json: GroupEventSerializer.new(@group_event), status: :ok
  end

  def update
    @group_event.update(group_event_params)

    head :no_content
  end

  def create
    @group_event = GroupEvent.create!(group_event_params)
    
    render json: GroupEventSerializer.new(@group_event), status: :created
  end

  def publish
    @group_event.update(status: GroupEvent.statuses[:published])

    head :no_content
  end

  def destroy
    @group_event.update(status: GroupEvent.statuses[:archived])

    head :no_content
  end

  private

  def group_event_params
    params.permit(:name, :description, :start_at, :end_at, :duration, :location)
  end

  def set_group_event
    @group_event = GroupEvent.where(status: %w[published draft]).find(params[:id])
  end
end
