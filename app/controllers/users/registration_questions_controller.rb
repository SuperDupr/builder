class Users::RegistrationQuestionsController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:fallback] == "story_creation"
      flash[:alert] = "Please answer some basic questions to lead up the story building process!"
    end
    
    @industries = current_account.industries.map { |industry| [industry.title, industry.id] }
  end

  def update_data
    if params[:fallback] == "story_creation"
      fallback_path = story_builders_path
      notice = "Click Start Building link against the builder to get started with your story."
    else
      fallback_path = registration_questions_path
      notice = "Profile updated successfully!"
    end

    if current_user.update(registration_params)
      redirect_to(fallback_path, notice: notice)
    else
      redirect_to(registration_questions_path, alert: current_user.errors.full_messages.join(", "))
    end
  end

  private

  def registration_params
    params.require(:user).permit(:industry_id, :work_role, :focus_of_communication)
  end
end
