class TeamsController < Accounts::BaseController
  before_action :authenticate_user!
  before_action :set_account
  before_action :require_account_admin, except: [:index]
  before_action :set_team, only: [:edit, :update, :show, :destroy]

  def index
    @pagy, @teams = pagy(@account.teams)
  end

  def new
    @team = Team.new
  end

  def create
    @team = @account.teams.new(team_params)

    @team.save ?
      flash[:notice] = "Team was created successfully!" :
      flash[:alert] = "Unable to create team. Errors: #{@team.errors.full_messages.join(", ")}"

    redirect_to(teams_path)
  end

  def edit
  end

  def update
    @team.update(team_params) ?
      flash[:notice] = "Team was updated successfully!" :
      flash[:alert] = "Unable to update team. Errors: #{@team.errors.full_messages.join(", ")}"

    redirect_to(teams_path)
  end

  def show
    @pagy, @users = pagy(@team.users)
  end

  def destroy
    @team.destroy ?
      flash[:notice] = "Team was deleted successfully!" :
      flash[:alert] = "Unable to delete team!"
    redirect_to(teams_path)
  end

  private

  def set_account
    @account = current_account
  end

  def set_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name)
  end
end
