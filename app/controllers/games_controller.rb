require 'open-uri'

class GamesController < ApplicationController
  protect_from_forgery with: :null_session

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    @letters = []
    grid_size.times do |_n|
      @letters << ('a'..'z').to_a.sample
    end
  end

  # def update_score(number)
  #   # Incrémenter le score
  #   session[:score] ||= 0
  #   session[:score] += number
  #   render json: { score: session[:score] }
  # end

  def run_game()
    # TODO: runs the game and
    # return detailed hash of result (with `:score`, `:message`)
    url = "https://dictionary.lewagon.com/#{params[:text]}"
    user_serialized = URI.parse(url).read
    user = JSON.parse(user_serialized)
    @results = {}
    letters = params[:hidden_tab].split(" ")
    letters.map!(&:downcase)
    if !user["found"] # non-english word
      @results[:message] = "Sorry but #{params[:text]} does not seem to be a valid English word..."
      @results[:score] = 0
    else # english word
      # test if the given word is in the grid or not
      exist_within_grid = true
      myattemptarray = params[:text].scan(/./)
      myattemptarray.each do |val|
        unless letters.include?(val)
          exist_within_grid = false
          break
        end
      end
      if !exist_within_grid # given word not in the grid
        @results[:message] = "#{params[:text]} is not in the grid!"
        @results[:score] = 0
      else # given word is in the grid
        tmpgrid =  letters
        overused_within_grid = false
        myattemptarray.each do |val|
          tmp = tmpgrid.each_index.select { |i| tmpgrid[i] == val }
          if tmpgrid.include?(val)
            tmpgrid.delete_at(tmp[0])
          else
            overused_within_grid = true
            break
          end
        end
        if overused_within_grid # some letters are overused
          @results[:message] = "#{params[:text]} has the correct letters but some letters are overused; #{params[:text]}.uppercase is not in the grid"
          @results[:score] = 0
        else # NO letters are overused
          @results[:message] = "Congratulations! #{params[:text]} is a valid English word!"
          @results[:score] = user["length"]
        end
      end
    end
    # update_score(@results[:score].to_i)
  end

  def new
    # session[:score] = 0
    generate_grid(10)
  end

  def score
    run_game
  end
end
