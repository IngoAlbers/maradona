class SquadsController < ApplicationController
  before_action :set_squad, only: [:show, :edit, :update]

  def new
    @squad = Squad.new
  end

  def show
    authorize @squad, :show?
  end

  def create
    @squad = Squad.new(squad_params)
    @squad.squad_members.new(
      user: current_user,
      invitation_sent_at: Time.zone.now,
      invitation_accepted_at: Time.zone.now,
      coach: true
    )

    if @squad.save
      redirect_to @squad, notice: 'Squad created'
    else
      move_parameterized_name_errors
      render :new
    end
  end

  def edit
    authorize @squad, :edit?
  end

  def update
    authorize @squad, :update?
    if @squad.update(squad_params)
      redirect_to @squad, notice: 'Squad updated'
    else
      render :edit
    end
  end

  private

  def squad_params
    params.require(:squad).permit(:name)
  end

  def set_squad
    @squad = Squad.find_by(parameterized_name: params[:parameterized_name])
  end

  def move_parameterized_name_errors
    return unless @squad.errors&.has_key?(:parameterized_name)
    @squad.errors.details[:parameterized_name].each do |error|
      next if @squad.errors.added?(:name, error.values.first)
      @squad.errors.add(:name, error.values.first)
    end
    @squad.errors.delete(:parameterized_name)
  end
end
