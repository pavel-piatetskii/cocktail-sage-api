require '/vagrant/finals/cocktail-sage-api/app/helpers/paginator.rb'
class Api::RecipesController < Api::ApplicationController

  def index
    #@recipes = Recipe.all.order(created_at: :desc)
    @recipes_ids = Recipe.all.order(created_at: :desc).ids
    @pages = paginate(@recipes_ids)
    @current = @pages[1].map { |id| 
      { recipe: Recipe.find(id),
        rating: Rating.where(recipe_id: id).average(:value),
        ingredients: RecipeIngredient.where(recipe_id: id).map { |ingredient|
          { ingredient.ingredient_id => 
            { Ingredient.find(ingredient.ingredient_id).name => ingredient.amount }
          } 
        },
        comments: Comment.where(recipe_id: id),
        users_favourited: Favorite.where(recipe_id: id).map {|favorite|
          favorite.user_id }
      }
    }
    @pages["current"] = @current

    render :json => {
      recipes: @pages
    }
  end

  def show
    @recipe = Recipe.find(params[:id])

    render :json => {
      recipe: @recipe
    }
  end

  def create
    @recipe = Recipe.create(recipe_params)
    @ingredients = @recipe.recipe_ingredients.create(ingredient_params)
    @recipe.ingredients = @ingredients.map {|ingredient| Ingredient.find(ingredient.ingredient_id)}

    render :json => {
      recipe: @recipe,
      ingredients: @ingredients
    }
  end

  def search_recipes
    if params.include :flavour_id
      @recipes = Recipe.where("flavour_id = ?", params[:flavour_id])
    end
    if params.include :parent_id
      @recipes = Recipe.where("parent_id = ?", params[:parent_id])
    end
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
        :ingredient_id,
        :amount
      )
    end
end
