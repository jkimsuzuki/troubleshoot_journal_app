class TagsController < ApplicationController
  def index
    @tags = Tag.all.order(:name)
  end

  def show
    @tag = Tag.find(params[:id])
  end
end
