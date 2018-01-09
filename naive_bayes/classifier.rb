# Simple ruby Classifier using Naive Bayes algorithm
# Tests are done with K-fold cross validation (K = 10)
# Data presents the vote between 'republicans' and 'democrats'
# 2 classes has 16 attrubutes with values 'y', 'n' and '?'
# 'y' = yes, 'n' = no, '?' = missing

require 'csv'
# used for mean, standard deviation
require 'descriptive_statistics'

def normalize_data
  vote_data = CSV.read('./vote.csv')

  vote_data.each do |feature|
    feature.map! do |class_value|
      case class_value
      when "'y'"
        1.0
      when "'n'"
        0.0
      when "?"
        0.5
      else
        class_value
      end
    end
  end
end

def class_separator(data)
  classes = {}
  data.each do |feature|
    class_name = feature[-1]
    classes[class_name] = [] unless classes.has_key? class_name
    classes[class_name].push(feature[0..-2])
  end
  classes
end

def feature_probability(feature_set, value)
  # statistical properties of the feature set
  std  = feature_set.standard_deviation
  mean = feature_set.mean
  var  = feature_set.variance

  # deal with the edge case of a 0 standard deviation
  if std == 0
    return mean == value ? 1 : 0
  end

  # calculate the gaussian probability
  exp = -((value - mean) ** 2) / ( 2 * var)

  (1.0 / (Math.sqrt(2 * Math::PI * var))) * (Math::E ** exp)
end

# use above method!!!!
def class_probability(class_data, test_instance)
  probs = {}
  class_data.each do |class_name, data|
    probs[class_name] = 1
    data.each_with_index do |value, index|
      mean, std = value
      val = test_instance[index]
      probs[class_name] *= probability(val, mean, std)
    end
  end
  probs
end


def predictions(training_value, test_set)
  test_set.map { |i| predict(training_value, i) }
end

def predict(class_data, test_instance)
  probabilities = class_probability(class_data, test_instance)
  best = -1
  prediction = nil

  probabilities.each do |class_name, probability|
    if probability > best || prediction.nil?
      best = probability
      prediction = class_name
    end
  end
  prediction
end

def accuracy(feature_set, predictions)
  correct = 0
  feature_set.size.times { |i| correct += 1 if feature_set[i][-1] == predictions[i] }

  (correct / feature_set.size) * 100
end

# split into K folds
def cross_validation_split(dataset, n_folds = 10):
  dataset_split = []
  dataset_copy = dataset.dup
  fold_size = (dataset.size / n_folds).to_i

  n_folds.size.times do |i|
    fold = []
    while fold.size < fold_size:
      index = rand(dataset_copy.size)
      fold.push(dataset_copy.pop(index))
    end
    dataset_split.push(fold)
  end

  dataset_split
end
