module Admin
  class TeamsController < Admin::ApplicationController
    before_action :set_account
    before_action :set_team, only: [:show, :edit, :update, :destroy]

    def index
      @teams = @account.teams
    end

    def show
    end

    def new
      @team = @account.teams.new
    end

    def create
      @team = @account.teams.new(team_params)

      @team.save ?
        flash[:notice] = "Team was created successfully!" :
        flash[:alert] = "Unable to create team. Errors: #{@team.errors.full_messages.join(", ")}"

      redirect_to(admin_teams_path(account_id: @account.id))
    end

    def edit
    end

    def update
      @team.update(team_params) ?
        flash[:notice] = "Team was updated successfully!" :
        flash[:alert] = "Unable to update team. Errors: #{@team.errors.full_messages.join(", ")}"

      redirect_to(admin_teams_path(account_id: @account.id))
    end

    def destroy
      @team.destroy ?
        flash[:notice] = "Team was deleted successfully!" :
        flash[:alert] = "Unable to delete team!"
      redirect_to(admin_teams_path(account_id: @account.id))
    end

    private

    def set_account
      @account = Account.find(params[:account_id] || params[:team][:account_id])
    end

    def set_team
      @team = @account.teams.find(params[:id])
    end

    def team_params
      params.require(:team).permit(:name, :account_id)
    end
  end
end
