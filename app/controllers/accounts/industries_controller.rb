class Accounts::IndustriesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_account_admin
  before_action :set_industry, only: [:show, :edit, :update, :destroy]

  def index
    @pagy, @industries = pagy(current_account.industries)
  end

  def show
  end

  def new
    @industry = Industry.new
  end

  def create
    @industry = current_account.industries.new(industry_params)

    if @industry.save
      redirect_to account_industries_path(account_id: current_account.id), notice: "Industry was successfully created."
    else
      redirect_to account_industries_path(account_id: current_account.id), alert: "Unable to create industry. Errors: #{@industry.errors.full_messages.join(", ")}"
    end
  end

  def edit
  end

  def update
    if @industry.update(industry_params)
      redirect_to account_industry_path(@industry), notice: "Industry was successfully updated."
    else
      redirect_to account_industry_path(@industry, account_id: current_account.id), alert: "Unable to update industry. Errors: #{@industry.errors.full_messages.join(", ")}"
    end
  end

  def destroy
    @industry.destroy
    redirect_to account_industries_path, notice: "Industry was successfully destroyed."
  end

  private

  def set_industry
    @industry = current_account.industries.find(params[:id])
  end

  def industry_params
    params.require(:industry).permit(:title)
  end
end
