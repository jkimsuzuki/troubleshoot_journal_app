class TagsController < ApplicationController
  before_action :set_tag, only: %i[show edit update destroy]

  def index
    @query = params[:query]
    @usage = params[:usage]

    @tags = Tag.all.order(:name)

    if @query.present?
      @tags = @tags.where("name LIKE ?", "%#{@query}%")
    end

    if @usage == "used"
      @tags = @tags.joins(:issues).distinct
    elsif @usage == "unused"
      @tags = @tags.left_outer_joins(:issues).where(issues: { id: nil })
    end

    @total_tags = Tag.count
    @unused_tags = Tag.left_outer_joins(:issues).where(issues: { id: nil }).count
    @total_tagged_issues = Issue.joins(:tags).distinct.count
    @most_used_tag = Tag.left_joins(:issues).group(:id).order("COUNT(issues.id) DESC").first
  end

  def show
  end

  def new
    @tag = Tag.new
  end

  def edit
  end

  def create
    @tag = Tag.new(tag_params)

    if @tag.save
      redirect_to tags_path, notice: "Tag was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @tag.update(tag_params)
      redirect_to tags_path, notice: "Tag was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @tag.destroy
    redirect_to tags_path, notice: "Tag was successfully deleted."
  end

  private

    def set_tag
      @tag = Tag.find(params[:id])
    end

    def tag_params
      params.require(:tag).permit(:name)
    end
end
