module Organizer
  class RankingsController < OrganizerController
    before_action :set_ranking, only: [:show, :edit, :update, :destroy]
    
    def new
      @ranking = Ranking.new
    end

    def create
      organization = current_user.organizations.last
      @ranking = organization.rankings.new(ranking_params)

      if @ranking.save
        redirect_to edit_organizer_ranking_path(@ranking)
      end
    end

    def edit
      
    end
    
    def update
      if @ranking.update(ranking_params)
        #binding.pry

        redirect_to organizer_dashboard_index_path, notice: 'Question was successfully updated.'
      else
        render :edit
      end
    end

    private

    def set_ranking
      @ranking = Ranking.find(params[:id])
    end

    def ranking_params
      params.require(:ranking).permit(:title, :description, 
                                  :start_date, :end_date, :crowd_content, :pre_moderation,
                                  :cover_image,
                                  rankable_items_attributes: [:id, :name, :_destroy] )
    end

  end
end