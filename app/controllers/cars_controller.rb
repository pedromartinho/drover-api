class CarsController < ApplicationController
  before_action :ensure_self_params, only: %i[update]
  before_action :ensure_index_params, only: %i[index]
  before_action :ensure_sort_params, only: %i[index]
  before_action :ensure_create_params, only: %i[create]
  before_action :ensure_update_params, only: %i[update]

  ####################################################################################################
  # GET /cars

  # Description
  ### Endpoint to get the list of cars. By default it returns the first 20 cars ordered by price ASC
  ### Cars that are only available after 3 months, are filtered.

  # Pagination (limit, page)
  ### Allows pagination with the parameters page and limit.

  # Sort (order, field)
  ### Allows sorted results by sending the params field (available_from, year, price and maker_n)
  ### and order (descend or ascend).

  # Filters (color_id, maker_id, min_months)
  ### You can filter the results by color, maker and min_months (number of months availability
  ### thershold)

  # Result
  ### message - info message
  ### cars - array of cars according to the filters and pagination
  ### total - total of cars found respecting the filters conditions
  ### color - array of possible colors
  ### model - array of possible models
  ### makers - array of possible makers
  ####################################################################################################

  def index
    limit = index_params[:limit].present? ? index_params[:limit].to_i : 20
    offset = index_params[:page].present? ? (index_params[:page].to_i - 1) * limit : 0
    min_months = index_params[:min_months].present? ? index_params[:min_months] : 3
    sql = "
      SELECT
        c.id AS id,
        c.license_plate AS license_plate,
        c.year AS year,
        c.price AS price,
        CASE
          WHEN c.available_from IS NULL THEN CURRENT_DATE
          ELSE c.available_from
        END AS available_from,
        co.name AS color_n,
        m.name AS model_n,
        ma.name AS maker_n

      FROM cars c
        INNER JOIN models m
          ON c.model_id = m.id
        INNER JOIN makers ma
          ON m.maker_id = ma.id
        INNER JOIN colors co
          ON c.color_id = co.id
      WHERE ((((DATE_PART('year', c.available_from) - DATE_PART('year', CURRENT_DATE)) * 12) +
          (DATE_PART('month', c.available_from) - DATE_PART('month', CURRENT_DATE)) <= #{min_months})
        OR c.available_from IS NULL)
    "

    sql += " AND c.model_id = #{index_params[:model_id]} " if index_params[:model_id].present?
    sql += " AND c.color_id = #{index_params[:color_id]}" if index_params[:color_id].present?

    sql += if sort_params[:field].present?
             sort_params[:order] == 'descend' ? " ORDER BY #{sort_params[:field]} desc " : "ORDER BY #{sort_params[:field]} asc "
           else
             ' ORDER BY price asc '
           end

    total = Car.find_by_sql(sql).count

    sql += " OFFSET #{offset}
      LIMIT #{limit}"

    cars = Car.find_by_sql(sql)

    colors = Color.select('id, name')
    models = Model.select('id, name, maker_id')
    makers = Maker.select('id, name')

    render json: {
      message: "Found #{total} cars.",
      total:   total,
      cars:    cars,
      colors:  colors,
      models:  models,
      makers:  makers
    }, status: 200
  end

  ####################################################################################################
  # POST /cars

  # Description
  ### Endpoint for the car creation.

  # Input
  ### color_id* - id of the car color
  ### model_id* - id of the car model
  ### license_plate* - car license plate
  ### available_from* - date from which the car become available
  ### price* - car monthly subscription price
  ### year* - car year

  # Return
  ### message - info message
  ### car - object with car basic information
  ####################################################################################################
  def create
    car = Car.create!(create_update_params)
    render json: {
      message: "Car #{car.license_plate} created!",
      car:     {
        id:             car.id,
        license_plate:  car.license_plate,
        year:           car.year,
        available_from: car.available_from,
        color_name:     car.color.name,
        model_name:     car.model.name,
        maker_name:     car.maker.name
      }
    }, status: 201
  rescue StandardError => e
    render json: {
      message: 'Something went wrong in the car creation.',
      error:   e.message
    }, status: 400
  end

  ####################################################################################################
  # PUT /cars/:id

  # Description
  ### Endpoint for the car update.

  # Input (at least one of the fields must be sent for the update)
  ### color_id - id of the car color
  ### model_id - id of the car model
  ### license_plate - car license plate
  ### available_from - date from which the car become available
  ### price - car monthly subscription price
  ### year - car year

  # Return
  ### message - info message
  ### car - object with car basic information
  ####################################################################################################
  def update
    @car.update!(create_update_params)
    render json: {
      message: "Car #{@car.id} udpated!",
      car:     {
        id:             @car.id,
        license_plate:  @car.license_plate,
        year:           @car.year,
        available_from: @car.available_from,
        color_name:     @car.color.name,
        model_name:     @car.model.name,
        maker_name:     @car.maker.name
      }
    }, status: 200
  rescue StandardError => e
    render json: {
      message: 'Something went wrong in the car update.',
      error:   e.message
    }, status: 400
  end

  private

  def self_params
    params.permit(:id)
  end

  # Ensure the specified car exists in the database
  def ensure_self_params
    @car = Car.find_by(id: self_params[:id].to_i)
    if @car.nil?
      render json: {
        message: "Car with give id (#{self_params}) not found."
      }, status: 404
    end
  end

  def sort_params
    params.permit(:field, :order)
  end

  # Ensure the sort params are within the expected values
  def ensure_sort_params
    available_fields = %w[available_from price year maker_n]
    if sort_params[:field].present? && !available_fields.include?(sort_params[:field])
      return render json: {
        message: "Column #{sort_params[:field]} not available for sorting. The possible values are #{available_fields.join(', ')}"
      }, status: 400
    end
    if sort_params[:order].present? && sort_params[:order] != 'ascend' && sort_params[:order] != 'descend'
      render json: {
        message: "The order query param value must 'ascend' or 'descend'"
      }, status: 400
    end
  end

  def index_params
    params.permit(:color_id, :model_id, :page, :limit, :min_months)
  end

  # Ensure the pagination parameters are valid
  def ensure_index_params
    if index_params[:limit].present? && !index_params[:limit].to_i.positive?
      return render json: {
        message: 'Limit value must be greated than 0.'
      }, status: 400
    end
    if index_params[:page].present? && !index_params[:page].to_i.positive?
      render json: {
        message: 'Page value must be greated than 0.'
      }, status: 400
    end
  end

  def create_update_params
    params.permit(:color_id, :model_id, :license_plate, :available_from, :price, :year)
  end

  # Ensure all te parameters are valid for the car creation. Validate if the given ids correspond
  # to objects that are in the database or the inputs have a valid format
  def ensure_create_params
    required_params = %w[color_id model_id license_plate available_from price year]
    missing_fields = required_params - create_update_params.keys

    if missing_fields.present?
      return render json: {
        message: "The fields #{missing_fields.join(',')} must be provided for the car creation."
      }, status: 400
    end

    color = Color.find_by(id: create_update_params[:color_id])
    if color.nil?
      return render json: {
        message: "Color with given id (#{create_update_params[:color_id]}) not found."
      }, status: 404
    end

    model = Model.find_by(id: create_update_params[:model_id])
    if model.nil?
      return render json: {
        message: "Model with given id (#{create_update_params[:color_id]}) not found."
      }, status: 404
    end

    unless model.colors.pluck(:id).include?(color.id)
      return render json: {
        message: "Color is not a valid for the #{model.name}. The colors available for this model are #{model.colors.pluck(:name).join(', ')}"
      }, status: 400
    end

    unless valide_license_plate?(create_update_params[:license_plate])
      return render json: {
        message: 'License Plate must have one of the following formats AA-00-00, 00-AA-00 or 00-00-AA.'
      }, status: 400
    end

    if create_update_params[:available_from].present?
      unless valid_date?(create_update_params[:available_from])
        return render json: {
          message: 'Available From must have the following format YY-mm-dd and be higher or equal to today.'
        }, status: 400
      end
    end

    if create_update_params[:year] < 1886 || create_update_params[:year] > 2020
      render json: {
        message: 'The year of the car must be between 1886 and 2020.'
      }, status: 400
    end
  end

  # Ensure all te parameters are valid for the car update. Validate if the given ids correspond
  # to objects that are in the database or the inputs have a valid format
  def ensure_update_params
    considered_params = %w[color_id model_id license_plate available_from price year]
    intersect_fields = considered_params & create_update_params.keys
    model = @car.model
    color = @car.color

    if intersect_fields.blank?
      return render json: {
        message: "At least one of the car fields is required to have an update (#{considered_params.join(', ')})."
      }, status: 400
    end

    if create_update_params[:model_id].present?
      model = Model.find_by(id: create_update_params[:model_id])
      if model.nil?
        return render json: {
          message: "Model with given id (#{create_update_params[:color_id]}) not found."
        }, status: 404
      end
    end

    if create_update_params[:color_id].present?
      color = Color.find_by(id: create_update_params[:color_id])
      if color.nil?
        return render json: {
          message: "Color with given id (#{create_update_params[:color_id]}) not found."
        }, status: 404
      end
    end

    unless model.colors.pluck(:id).include?(color.id)
      return render json: {
        message: "Color is not a valid for the #{model.name}. The colors available for this model are #{model.colors.pluck(:name).join(', ')}"
      }, status: 400
    end

    if create_update_params[:license_plate].present?
      unless valide_license_plate?(create_update_params[:license_plate])
        return render json: {
          message: 'License Plate must have one of the following formats AA-00-00, 00-AA-00 or 00-00-AA.'
        }, status: 400
      end
    end

    if create_update_params[:license_plate].present?
      unless valid_date?(create_update_params[:available_from])
        return render json: {
          message: 'Available Drom must have the following format YY-mm-dd.'
        }, status: 400
      end
    end

    if create_update_params[:year].present?
      if create_update_params[:year] < 1886 || create_update_params[:year] > 2020
        render json: {
          message: 'The year of the car must be between 1886 and 2020.'
        }, status: 400
      end
    end
  end

  # Validate if the license has one of the formats 'AA-00-00', '00-AA-00' or '00-00-AA'
  def valide_license_plate?(license_plate)
    number_strings = 0
    return false if license_plate.length != 8
    return false unless license_plate[2] == '-' && license_plate[5] == '-'

    number_strings += 1 if is_string?(license_plate[1..0])
    number_strings += 1 if is_string?(license_plate[3..4])
    number_strings += 1 if is_string?(license_plate[6..7])

    number_strings == 1
  end

  # Validate if string is integer or not
  def is_string?(str)
    false if Integer(str)
  rescue StandardError => e
    true
  end

  # Validate the date format is YY-mm-dd and is bigger than the current date
  def valid_date?(date_str)
    date = Date.strptime(date_str, '%Y-%m-%d')
    date >= Date.today
  rescue StandardError => e
    false
  end
end
