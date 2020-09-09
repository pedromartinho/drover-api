class CarsController < ApplicationController
  def index
    render json: { message: 'ola' }, status: 200
  end
end
