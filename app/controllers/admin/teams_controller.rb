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
    end

    def edit 
    end

    def update
    end

    def destroy
    end

    private

    def set_account
      @account = Account.find(params[:account_id])      
    end

    def set_team
      @team = @account.teams.find(params[:id])
    end

    def team_params
      params.require(:team).permit(:name)      
    end
  end  
end