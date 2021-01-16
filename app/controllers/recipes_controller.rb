class RecipesController < ApplicationController

  def index
    @recipes = Recipe.all.order(:created_at: :desc)

    render :json => {
      recipes: @recipes
    }
  end

  def show
    @recipe = Recipe.find params[:recipe_id]

    render :json => {
      recipe: @recipe
    }
  end

  def create
    @recipe = Recipe.create(recipe_params)
    @ingredients = @recipe.recipe_ingredients.create(ingredient_params)
    @recipe.ingredients = @ingredients.map {|ingredient| Ingredient.find(ingredient.ingredient_id)}

    render :json => {
      recipe: @recipe
      ingredients: @ingredients
    }
  end

  def search_recipes
    if params.include :flavour_id
      @recipes = Recipe.where("flavour_id = ?", params[:flavour_id])
    if params.include :parent_id
      @recipes = Recipe.where("parent_id = ?", params[:parent_id])
    if params.include :ingredient_id
      @recipe_ids = RecipeIngredient.select(:recipe_id).where("ingredient_id = ?", params[:ingredient_id])
      @recipes = @recipe_ids.map { |recipe_id| Recipe.find(recipe_id) }
    end

    render :json => {
      recipes: @recipes
    }
  end


  private
    def recipe_params
      params.require(:recipe).permit(
        :name,
        :parent_id,
        :flavour_id,
        :user_id,
        :image_url,
        :summary,
        :instructions,
      )
    end

    def ingredient_params
      params.reqire(:ingredient).permit(
        :ingredient_id
        :amount
      )
    end
end
