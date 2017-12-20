# K-nearest-neighbours algorithm implented in ruby.
# Data fetched from IRIS.
# K is global variable that can be changed.
# Based on tests best value for k is 3.
# To test with other values - just change the global variable.

require 'csv'

SPLIT_RATIO = 0.75
K_VALUE = 3

class Classifier
  def initialize
    @train_set_x, @train_set_y, @test_set_x, @test_set_y = [], [], [], []

    @predictions = nil
    @mistakes = []

    manage_data
  end

  attr_accessor :mistakes

  # reciprocally returns distance between 2 entities
  def distance_between(vector_x, vector_y)
    raise ArgumentError, 'Vectors with different length!' unless vector_x.size == vector_y.size

    d = 0
    vector_x.zip(vector_y).each { |x, y| d += (x - y) ** 2 }

    # add 1e-4 to distance to protect from vectors without distance between them
    1.0 / Math.sqrt(d + 0.0001)
  end

  # returns first k nearest neighbours to the entity
  def nearest_neighbours(entity)
    distances = []

    @train_set_x.each_with_index do |train_entity, i|
      d = distance_between(train_entity, entity)
      distances.push([d, i])
    end

    sorted = distances.sort! { |i, j| i[0] <=> j[0] }.reverse
    sorted.first(K_VALUE)
  end

  def predict
    @predictions = @test_set_x.map { |entity| prediction_for(entity) }
  end

  def prediction_for(entity)
    neighbours = nearest_neighbours(entity)

    neighbours_classes = neighbours.map { |_, i| @train_set_y[i] }

    max_occurencies_in neighbours_classes
  end

  def max_occurencies_in(array)
    array.max_by { |x| array.count(x) }
  end

  # percent matches predictions from test examples
  def accuracy
    raise ArgumentError, 'No predictions yet' if @predictions.nil?

    matches = 0
    @predictions.zip(@test_set_y).each do |predict_value, real_value|
      if predict_value == real_value
        matches += 1
      else
        @mistakes.push("Predicted is: #{predict_value} - Real value is: #{real_value}")
      end
    end

    test_y_size = @test_set_y.size.to_f
    accuracy = (matches / test_y_size) * 100.0
    accuracy.round(4)
  end

  private

  # provide data frame to work with
  def manage_data
    data = CSV.read('./data.csv')
    processed_data = data_to_float(data)

    processed_data.each_with_index do |row, x|
      row[0..-2].each_with_index do |feature, y|
        @normalized_data[x][y] = feature

        if rand < SPLIT_RATIO
          @train_set_x.push(row[0..-2])
          @train_set_y.push(row[-1])
        else
          @test_set_x.push(row[0..-2])
          @test_set_y.push(row[-1])
        end
      end
    end
  end

  def data_to_float(data)
    @normalized_data = data.dup

    features = []
    iterrations = @normalized_data[0].size - 1
    iterrations.times { features.push([]) }

    @normalized_data.each do |row|
      iterrations.times do |i|
        features[i].push(row[i].to_f)
      end
    end

    max_features = features.map { |f| f.max }

    @normalized_data.each_with_index do |row, x|
      iterrations.times do |y|
        @normalized_data[x][y] = row[y].to_f / max_features[y]
      end
    end

    @normalized_data
  end
end

a = Classifier.new
a.predict
print "#{a.accuracy}\n"
a.mistakes.each { |m| p m } unless a.mistakes.empty?
