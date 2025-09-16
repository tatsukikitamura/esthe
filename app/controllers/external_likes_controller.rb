class ExternalLikesController < ApplicationController
  before_action :authenticate_user!

  def create
    place_id = params[:place_id]
    name = params[:name]
    address = params[:address]
    rating = params[:rating]
    user_ratings_total = params[:user_ratings_total]

    current_user.external_likes.find_or_create_by!(
      place_id: place_id
    ) do |like|
      like.name = name
      like.address = address
      like.rating = rating
      like.user_ratings_total = user_ratings_total
    end

    redirect_back fallback_location: shops_path, notice: 'いいねしました。'
  end

  def destroy
    place_id = params[:place_id]
    like = current_user.external_likes.find_by(place_id: place_id)
    like&.destroy
    redirect_back fallback_location: shops_path, notice: 'いいねを解除しました。'
  end
end


