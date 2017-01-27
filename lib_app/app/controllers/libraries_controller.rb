class LibrariesController < ApplicationController

  before_action :require_login, only: [:new, :create]

  # display list of libraries
  def index
    @libraries = Library.all
    render :index
  end

  def show
    @library = Library.find(params[:id])
    render :show
  end

  # display the library creation form
  def new
    @library = Library.new
    render :new
  end

  # process library creation form data & create new library
  def create
    @library = Library.create(library_params)
    redirect_to libraries_path
  end

  private

  # whitelist permitted form data
  def library_params
    params.require(:library).permit(:name, :floor_count, :floor_area)
  end

end
