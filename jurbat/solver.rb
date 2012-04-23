# -*- encoding : utf-8 -*-
# http://en.wikipedia.org/wiki/Partition_problem
# http://www.americanscientist.org/issues/id.3278,y.2002,no.3,content.true,page.1,css.print/issue.aspx
# http://www8.cs.umu.se/kurser/TDBAfl/VT06/algorithms/BOOK/BOOK2/NODE45.HTM
# http://ru.wikipedia.org/wiki/%D0%9B%D0%B8%D0%BD%D0%B5%D0%B9%D0%BD%D0%BE%D0%B5_%D0%BF%D1%80%D0%BE%D0%B3%D1%80%D0%B0%D0%BC%D0%BC%D0%B8%D1%80%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D0%B5
# http://www.rubyquiz.com/quiz65.html

require 'pp'
require './source_array'

menues = SourceAry # came from 'source_array.rb'

# Classes Monkeypatching, wierd idea at all
class Hash
  def overall_children_count
    return 0 unless self[:children]
    self[:children].inject(self[:children].count) do |sum, ch|
      sum + ch.overall_children_count
    end
  end
end

class Array
  def overall_weight
    reduce(0){ |acc, el| acc+el[:overall_children_count] }
  end
end

class Solver
  attr_reader :result

  def initialize groups
    @result = groups.times.map{ Array.new }
  end

  def add elm
    @result[find_ary_index_with_min_weight] << elm
  end

  def find_ary_index_with_min_weight
    min = @result.first.overall_weight
    idx = 0
    @result.each_with_index do |elm, i|
      weight = elm.overall_weight
      idx, min = i, weight if weight < min
    end
    idx
  end

end

groups_count = 3

menues = menues.
  map{ |h| h[:overall_children_count] = h.overall_children_count+1; h }.
  sort_by{ |el| el[:overall_children_count] }.
  reverse
solver = Solver.new groups_count
menues.each{ |elm| solver.add elm }
pp solver.result
