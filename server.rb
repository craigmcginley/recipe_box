require 'sinatra'
require 'pg'

def db_connection
  begin
    connection = PG.connect(dbname: 'recipe_box')
    yield(connection)
  ensure
    connection.close
  end
end

def get_all_recipes
  #get list of all recipes, sorted alphabetically
  db_connection do |conn|
    conn.exec("SELECT recipes.name, recipes.id FROM recipes
                ORDER BY name ASC")
  end
end

def get_recipe(id)
  #get recipe from list where id matches argument
  #get name, description, instructions
  db_connection do |conn|
    conn.exec_params("SELECT recipes.name, recipes.instructions, recipes.description
                FROM recipes
                WHERE recipes.id = $1", [id])
  end
end

def recipe_ingredients(id)
  #get all ingredients needed for recipe where id matches argument
  db_connection do |conn|
    conn.exec_params("SELECT ingredients.name FROM ingredients
                WHERE ingredients.recipe_id = $1", [id])
  end
end

get '/' do
  redirect '/recipes'
end

get '/recipes' do
  @recipes = get_all_recipes

  erb :'/recipes/index'
end

get '/recipes/:id' do
  @id = params[:id]
  @recipe = get_recipe(@id)
  @ingredients = recipe_ingredients(@id)

  erb :'/recipes/show'
end
