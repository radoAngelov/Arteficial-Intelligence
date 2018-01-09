require 'csv'

def normalize_data
  data = CSV.read('./breast_cancer_data.csv')

  data.each { |feature| feature[-1] = feature[-1] == "'recurrence-events'" ? 1 : 0 }
  data
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

# Calculates the entropy of the given data set for the target attribute
def entropy(data, target_attr):
  val_freq     = {}
  data_entropy = 0.0

  # Calculate the frequency of each of the values in the target attr
  data.each do |record|
    if val_freq.has_key? record[target_attr]
      val_freq[record[target_attr]] += 1.0
    else
      val_freq[record[target_attr]] = 1.0
    end
  end

  # Calculate the entropy of the data for the target attribute
  val_freq.each_value { |freq| data_entropy += (-freq / data.size) * Math.log2(freq / data.size) }

  data_entropy
end

# Calculates the information gain wchich comes from splitting the data of attr
def gain(data, attr, target_attr):
  val_freq       = {}
  subset_entropy = 0.0

  # Calculate the frequency of each of the values in the attribute
  data.each do |record|
    if val_freq.has_key? record[attr]
      val_freq[record[attr]] += 1.0
    else
      val_freq[record[attr]] = 1.0
    end
  end

  # Calculate the sum of the entropy for each subset of records weighted
  # by their probability of occuring in the training set.
  val_freq.each_key do |val|
    val_prob        = val_freq[val] / val_freq.values.sum
    data_subset     = data.collect { |record| record[attr] == val }
    subset_entropy += val_prob * entropy(data_subset, target_attr)
  end

  # Subtract the entropy of the chosen attribute from the entropy of the
  # whole data set with respect to the target attribute (and return it)
  entropy(data, target_attr) - subset_entropy
end

def create_decision_tree(data, attributes, target_attr, fitness_func):
    data    = data[:]
    vals    = data.map { |record| record[target_attr] }
    default = majority_value(data, target_attr)

    # If the dataset is empty or the attributes list is empty, return the
    # default value. When checking the attributes list for emptiness, we
    # need to subtract 1 to account for the target attribute.
    if not data or (len(attributes) - 1) <= 0:
        return default
    # If all the records in the dataset have the same classification,
    # return that classification.
    elif vals.count(vals[0]) == len(vals):
        return vals[0]
    else:
        # Choose the next best attribute to best classify our data
        best = choose_attribute(data, attributes, target_attr,
                                fitness_func)

        # Create a new decision tree/node with the best attribute and an empty
        # dictionary object--we'll fill that up next.
        tree = {best:{}}

        # Create a new decision tree/sub-node for each of the values in the
        # best attribute field
        for val in get_values(data, best):
            # Create a subtree for the current value under the "best" field
            subtree = create_decision_tree(
                get_examples(data, best, val),
                [attr for attr in attributes if attr != best],
                target_attr,
                fitness_func)

            # Add the new subtree to the empty dictionary object in our new
            # tree/node we just created.
            tree[best][val] = subtree

    return tree
