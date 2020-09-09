namespace :populate do
  task all: :environment do
    system('rails db:migrate')
    system('rails populate:makers_colors_models')
    system('rails populate:cars')
  end

  task makers_colors_models: :environment do
    ActiveRecord::Base.transaction do
      makers.each do |maker|
        maker_ar = Maker.find_by(name: maker[:name])
        maker_ar = Maker.create!(name: maker[:name]) if maker_ar.nil?
        maker[:models].each do |model|
          model_ar = Model.find_by(name: model[:name])
          if model_ar.nil?
            model_ar = Model.create!(
              name:     model[:name],
              maker_id: maker_ar.id
            )
          end
          model[:colors].each do |color|
            color_ar = Color.find_by(name: color[:name])
            if color_ar.nil?

              color_ar = Color.create!(
                name:     color[:name],
                hex_code: color[:hex_code]
              )
            end
            model_ar.colors << color_ar unless model_ar.colors.pluck(:id).include?(color_ar.id)
          end
        end
      end
    end
  end

  task cars: :environment do
    ActiveRecord::Base.transaction do
      Model.find_each do |model|
        model.colors.each do |color|
          (0..12).each do |month|
            date = nil
            if month.positive?
              month_str = month.to_s.length < 10 ? "0#{month}" : month.to_s
              date = "2021-#{month_str}-01"
            end
            Car.create!(
              color_id:       color.id,
              model_id:       model.id,
              license_plate:  "#{month + 10}-#{color.name[0]}#{model.name[0]}-#{50 + (month % 5)}",
              price:          300 + month,
              year:           2016 + (month % 5),
              available_from: date
            )
          end
        end
      end
    end
  end

  def makers
    [
      {
        name:   'BMW',
        models: [
          {
            name:   'Series3',
            colors: [
              {
                name:     'Alpine White',
                hex_code: '#FFFEE9'
              },
              {
                name:     'Jet Black',
                hex_code: '#0A0A0A'
              },
              {
                name:     'Mocha',
                hex_code: '#bea493'
              }
            ]
          },
          {
            name:   'X1',
            colors: [
              {
                name:     'Alpine White',
                hex_code: '#fffee9'
              },
              {
                name:     'Jet Black',
                hex_code: '#0a0a0a'
              },
              {
                name:     'Mocha',
                hex_code: '#bea493'
              }
            ]
          }
        ]
      },
      {
        name:   'Toyota',
        models: [
          {
            name:   'Yaris',
            colors: [
              {
                name:     'Wildfire Red',
                hex_code: '#961a1b'
              },
              {
                name:     'Pearl White',
                hex_code: '#fafbf5'
              },
              {
                name:     'Silver Metallic',
                hex_code: '#d0d2d1'
              }
            ]
          },
          {
            name:   'RAV4',
            colors: [
              {
                name:     'Wildfire Red',
                hex_code: '#961a1b'
              },
              {
                name:     'Pearl White',
                hex_code: '#fafbf5'
              },
              {
                name:     'Silver Metallic',
                hex_code: '#d0d2d1'
              }
            ]
          }
        ]
      },
      {
        name:   'Renault',
        models: [
          {
            name:   'Clio',
            colors: [
              {
                name:     'Arctic White',
                hex_code: '#aaacb5'
              },
              {
                name:     'Steel Blue',
                hex_code: '#4682b4'
              },
              {
                name:     'Mercury',
                hex_code: '#f6f6f8'
              }
            ]
          },
          {
            name:   'Megane',
            colors: [
              {
                name:     'Arctic White',
                hex_code: '#aaacb5'
              },
              {
                name:     'Steel Blue',
                hex_code: '#4682b4'
              },
              {
                name:     'Mercury',
                hex_code: '#f6f6f8'
              }
            ]
          }
        ]
      }
    ]
  end
end
