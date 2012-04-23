# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery

  def index
  end

  private

  # return three columned array of categories
  def categories_three_columned
    roots_data = []
    source_collection.each do |croot|
      roots_data << { el: croot, weight: calculate_weight(croot) }
    end    
    place_in_columns_by_weight roots_data, 3
  end

  def calculate_weight (ctg, depth = 0)
    calc_weight = [3 - depth, 1].max
    if ctg[:children]
      ctg[:children].each do |cch|
        calc_weight += calculate_weight cch, depth + 1
      end
    end
    calc_weight
  end


  # Function places an element from {elwcollection} into {cols_count} columns by weight
  #  elwcollection - collection of hashes with elements and their weight
  #   example: [ {el: element, weight: 6}, {el: element_too, weight: 12}, ... ]
  #  cols_count - number of columns, integer  
  def place_in_columns_by_weight (elwcollection, cols_count)
    the_columns = []
    cols_count.times { the_columns << [] }
    columns_weights = Array.new cols_count, 0
    emptiest_column_index = 0
    
    elwcollection.sort! { |a,b| b[:weight] <=> a[:weight] }
    elwcollection.each do |one|
      # find the emptiest column
      emptiest_column_weight = -1
      columns_weights.each_with_index do |cw, ci|
        if (emptiest_column_weight > cw) || (emptiest_column_weight < 0)
          emptiest_column_weight = cw
          emptiest_column_index = ci
        end
        break if emptiest_column_weight == 0
      end

      the_columns[emptiest_column_index] << one[:el]
      columns_weights[emptiest_column_index] += one[:weight]
    end

    the_columns
  end

  def source_collection
    [
      { :name => "Средства связи и навигации", :children => [
        { :name => "Радиосвязь", :children => [
          { :name => "Радиостанции" },
          { :name => "Антенны" },
          { :name => "Аксессуары" },
          { :name => "Детекторы устройств" },
          { :name => "Разъемы" },
          { :name => "Переходники" }
        ] },
        { :name => "Спутниковое телевидение", :children => [
          { :name => "Антенны" },
          { :name => "Пассивные элементы" },
          { :name => "Приемники" },
          { :name => "Конверторы" }
        ] }
      ] },
      { :name => "Охранные системы", :children => [
        { :name => "Видеонаблюдение", :children => [
          { :name => "Комутационные изделия" },
          { :name => "Видеокамеры" },
          { :name => "Видеорегистраторы" },
          { :name => "Объективы" },
          { :name => "Усилители, распределители и т. д." },
          { :name => "Платы видеозахвата" }
        ] },
        { :name => "Системы контроля доступа", :children => [
          { :name => "Домофоны" },
          { :name => "Вызывные панели" },
          { :name => "Замки, доводчики" }
        ] },
        { :name => "Оборудование сигнализации" },
        { :name => "Отделочные материалы", :children => [
          { :name => "Приборы приемно-контрольные" },
          { :name => "Датчики и т. д." },
          { :name => "Громкоговорители" }
        ] }
      ] },
      { :name => "Автомобильные товары", :children => [
        { :name => "Автомобильная электроника", :children => [
          { :name => "Радар-детекторы" }
        ] }
      ] },
      { :name => "Бытовая техника", :children => [
        { :name => "Фонари", :children => [
          { :name => "Доводчики" }
        ] },
        { :name => "Аксессуары", :children => [
          { :name => "Блок питания" },
          { :name => "Батарейки" },
          { :name => "Зарядные устройства" },
          { :name => "Аккумуляторы" }
        ] }
      ] },
      { :name => "Строительство и ремонт", :children => [
        { :name => "Замки, доводчики, петли", :children => [
          { :name => "Доводчики" }
        ] },
        { :name => "Крепеж фасованный", :children => [
          { :name => "Дюбели" },
          { :name => "Ремешки-хомуты" },
          { :name => "Скобы для провода" },
          { :name => "Хомуты" },
          { :name => "Шурупы-саморезы" }
        ] },
        { :name => "Инструмент" },
        { :name => "Отделочные материалы", :children => [
          { :name => "Короб" },
          { :name => "Гофра, металлорукав" }
        ] },
        { :name => "Изолента, серпянка, скотч" }
      ] },
      { :name => "Электрооборудование", :children => [
        { :name => "Кабель, провод" },
        { :name => "Соединители, клеммные колодки" },
        { :name => "Трубка термоусадочная ТУТ" }
      ] }
    ]
  end

  helper_method :categories_three_columned

end
