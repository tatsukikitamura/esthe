class ShopsController < ApplicationController
  def show
    @shops = Shop.all
  end
end
