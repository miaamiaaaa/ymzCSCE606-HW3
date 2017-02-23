class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = ['G', 'PG', 'PG-13', 'R']
    
    redirect = false
    
    if params[:bubble]
      @bubble = params[:bubble]
      session[:bubble] = params[:bubble]
    elsif session[:bubble]
      @bubble = session[:bubble]
      redirect = true
    else
      @bubble = nil
    end
    
    if params[:commit] == 'Refresh' and params[:ratings].nil?
      @ratings = nil
      session[:ratings] = nil
    elsif params[:ratings]
      @ratings = params[:ratings]
      session[:ratings] = params[:ratings]
    elsif session[:ratings]
      @ratings = session[:ratings]
      redirect = true
    else
      @ratings = nil
    end

    if redirect
      flash.keep
      redirect_to movies_path :bubble=>@bubble, :ratings=>@ratings
    end
    
    if @ratings and @bubble 
      @movies = Movie.where(:rating => @ratings.keys).order(@bubble)
    elsif @ratings
      @movies = Movie.where(:rating => @ratings.keys)
    elsif @bubble
      @movies = Movie.order(@bubble)
    else 
      @movies = Movie.all
    end

  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  helper do
    def my_func(cls)
      return params[:bubble] == cls ? 'hilite' : nil
    end
  end

end
