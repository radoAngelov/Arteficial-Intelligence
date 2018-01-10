# Given: 2N+1 nodes(frogs)- 1 for "rock", N for ">" and N for "<".
# Frogs can move in the direction they are looking to.
# One frog can jump over another.
# Problem: Change the direction of frogs using DFS.
LEFT_FROG  = '>' # looks to right
RIGHT_FROG = '<' # looks to left

PLUS_ONE_POSITION   = 1
MINUS_ONE_POSITION  = -1
PLUS_TWO_POSITIONS  = 2
MINUS_TWO_POSITIONS = -2

# generating pole with n frogs
def generate_frogs_pole(n, left, right)
  Array.new.tap do |pole|
    n.times { pole.push left }
    pole.push '_'
    n.times { pole.push right }
  end
end

def move_rock(frogs, rock_index, place_to_go, paths)
  # check for correct arguments
  return if rock_index < 0 || place_to_go < 0
  return if rock_index >= frogs.size || place_to_go >= frogs.size
  return if defined?(solution_found) && solution_found

  temp = frogs[rock_index]
  frogs[rock_index] = frogs[place_to_go]
  frogs[place_to_go] = temp

  path = frogs.join('  ')
  paths.push path

  if is_solution?(frogs)
    print_solution paths
    solution_found = true
    return
  end

  current_rock_place = rock_index

  frog = rock_index + MINUS_ONE_POSITION
  if can_move?(frogs, frog, LEFT_FROG)
    recursion(frogs, frog, current_rock_place, paths)
  end

  frog = rock_index + MINUS_TWO_POSITIONS
  if can_move?(frogs, frog, LEFT_FROG)
    recursion(frogs, frog, current_rock_place, paths)
  end

  frog = rock_index + PLUS_ONE_POSITION
  if can_move?(frogs, frog, RIGHT_FROG)
    recursion(frogs, frog, current_rock_place, paths)
  end

  frog = rock_index + PLUS_TWO_POSITIONS
  if can_move?(frogs, frog, RIGHT_FROG)
    recursion(frogs, frog, current_rock_place, paths)
  end
end

def recursion(frogs, rock_index, place_to_go, paths)
  paths_copy = paths.dup
  frogs_copy = frogs.dup
  move_rock(frogs_copy, rock_index, place_to_go, paths_copy)
end

def can_move?(frogs, frog, direction)
  return false if frog < 0 || frog >= frogs.size
  frogs[frog] == direction
end

def is_solution?(pole)
  frogs_number = pole.size / 2
  final_pole = generate_frogs_pole(frogs_number, RIGHT_FROG, LEFT_FROG)

  pole == final_pole
end

def print_solution(moves)
  moves.each { |move| p move }
end

puts "Please enter frogs number:"
n = gets
frogs = n.to_i
if frogs <= 0
  p "Please enter a postive number"
  exit
else
  initial_pole = generate_frogs_pole(frogs, LEFT_FROG, RIGHT_FROG)
  paths = []
  paths.push(initial_pole.join('  '))
  move_rock(initial_pole, frogs - 1, frogs, paths)
end

