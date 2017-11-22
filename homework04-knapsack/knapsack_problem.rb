# Solve Knapsack Problem with genetic algorithm

# Members of the population are going to be represented
# with array of '0' and '1'. Size of the array = items count.
# Example: For 6 items -> [0, 0, 1, 0, 1, 0]
# -> Only 3rd and 5th item are taken in the knapsack

require_relative 'data.rb'

# generate population with random filled members
def generate_population
  Array.new.tap do |population|
    Data::POPULATION_LENGTH.times do
      population.push(generate_random_member)
    end
  end
end

def generate_random_member
  member = []
  Data::ITEMS_COUNT.times { member.push(rand(2)) }
  fitness_function(member) ? member : generate_random_member
end

# heuristic
def fitness_function(child)
  return if weight_of(child) > Data::MAX_KG

  value_of(child)
end

def value_of(child)
  values = []
  # map values of initial data with used elements in the child
  child.each_with_index do |_, i|
    values.push(Data::ITEM_VALUES[i]) unless child[i] == 0
  end
  # returns sum of child's values
  values.reduce(0, :+)
end

def weight_of(child)
  weights = []
  # map weights of initial data with used elements in the child
  child.each_with_index do |_, i|
    weights.push(Data::ITEM_WEIGHTS[i]) unless child[i] == 0
  end
  # returns sum of child's weights
  weights.reduce(0, :+)
end

def mutate(child)
  # generate random position for mutation
  mutation = rand(Data::ITEMS_COUNT)

  # add/remove item from the child // actual mutation
  if child[mutation] == 0
    child[mutation] = 1
  else
    child[mutation] = 0
  end

  # returns mutated child
  child
end

def crossover(father, mother)
  # generate random separator
  separator = rand(Data::ITEMS_COUNT)

  # generate child from 2 parents => actual crossover
  child = father[0..separator] + mother[separator+1..Data::ITEMS_COUNT-1]

  # if newly generated child is not valid - crossover again
  crossover(father, mother) unless fitness_function(child)

  # return child
  child
end

def cross_and_mutate(father, mother)
  child = crossover(father, mother)

  # mutate in 5% of cases
  child = mutate(child) if rand(100) < 5

  fitness_function(child) ? child : cross_and_mutate(father, mother)
end

def best_members(population)
  best_values = population.map { |member| value_of member }.first((population.size / 5).round)
  population.select { |member| best_values.include? value_of member }
end

def random_member(population)
  population[rand(population.size)]
end

def selection_of(population)
  population = best_members(population)
  new_data = []

  Data::POPULATION_LENGTH.times do
    father = random_member(population)
    mother = random_member(population)
    child  = cross_and_mutate(father, mother)
    new_data.push(child)
  end
  best_members(new_data)
end

def solve_knapsack(n)
  result = []
  best = 0

  n.times do
    population = generate_population
    result.push(selection_of population)
  end

  result.map do |era|
    era.map! { |member| value_of member }
    new_best = era.sort.last
    best = new_best unless best > new_best
    p best # => output the best member in the era
  end
  best
end

