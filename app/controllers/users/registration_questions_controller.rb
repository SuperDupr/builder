class Users::RegistrationQuestionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @industries = current_account.industries.map { |industry| [industry.title, industry.id] }
  end

  def update_data
    if current_user.update(registration_params)
      redirect_to(registration_questions_path, notice: "Profile updated successfully!")
    else
      redirect_to(registration_questions_path, alert: current_user.errors.full_messages.join(", "))
    end
  end

  private

  def registration_params
    params.require(:user).permit(:industry_id, :work_role, :focus_of_communication)
  end
end
