require 'rubygems'
require 'json'

class Categories < Array

  def initialize(input = [], level = 0)
    super(
      input.map do |element|
        element.is_a?(Category) ? element : Category.new(element["name"], element["children"], level)
      end
    )
  end

  # Returns categories in the columns which are nearly equal by their height
  def in_equal_height_columns(number_of_columns = 3)
    sorted_columns = Categories.new
    number_of_columns.times { sorted_columns << Categories.new }
    self.inject(sorted_columns) do |sorted_columns, column|
      element_with_min_height(sorted_columns) << column
      sorted_columns
    end
  end

  # Returns height of all Category instances in the collection
  def height
    self.map(&:height).inject(0) { |sum, height| sum += height || 0 }
  end

  # It returns Array by default, so need to wrap it
  def sort_by(*args)
    self.class.new(super)
  end

  private

    def element_with_min_height(columns)
      min_height = columns.map { |col| col.height }.min
      columns.detect { |col| col.height == min_height }
    end
end


class Category < Struct.new(:name, :children, :level)
  HEIGHTS = [36, 24, 12].freeze
  DEEPNESS = 3

  def initialize(name, children, level)
    super
    self.children = Categories.new(children || [], level + 1)
  end

  def height
    HEIGHTS[level] + children.height
  end

  # It outputs the category taking its height into account. So, it will output
  # the first-level category like:
  #
  #  #
  #  #
  #  # Category name
  #
  # the second level category like:
  #
  #  ##
  #  ## Category name
  #
  # etc... I did that for easier comparing of heights of different columns
  def to_s
    prefix = "#" * (level + 1)
    "#{prefix}\n" * (DEEPNESS - 1 - level) + prefix + " " + ([name] + children.map(&:to_s)).join("\n")
  end
end


# The little explanation how it works:
# There are 2 classes, Categories (which is a collection, subclassed from Array) and
# Category (which is just a Struct). Both classes contain the method #height, which
# returns the height of the category and its subcategories or (in case of collection)
# the height of all categories in a collection.
#
# So, the algorithm is following:
# 1. From the input data (JSON) we create instances of the Category class.
# 2. Sort all root categories by height in reverse order (we don't need to sort inner categories too,
#    since we will position only the root categories, we need to take nested categories
#    into account only for calculating heights of the root categories).
# 3. Create 3 (or more) instances of Categories class (these are columns),
#    and then just put every Category into these collections, each Category to
#    the collection with the smallest height (that's why it is useful to have
#    Categories#height)
# 4. Output these collections in STDOUT.
input = JSON.parse(File.read("input.json"))
Categories.new(input).sort_by { |e| -e.height }.in_equal_height_columns.each do |col|
  puts col
  puts
end
