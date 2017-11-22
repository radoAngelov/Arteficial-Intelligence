# Given: 2N+1 nodes(frogs). 1 for "start", N for ">" and N for "<".
# Frogs can move in the direction they are looking to.
# One frog can jump over another.
# Problem: Change the direction of frogs using DFS.

LEFT_LOOKING_FROG = '<'
RIGHT_LOOKING_FROG = '>'

MOVE_TO_LEFT = 1
MOVE_TO_RIGHT = 2
MOVE_TO_RIGHT_WITH_JUMP = 3
MOVE_TO_LEFT_WITH_JUMP = 4

MOVES_COST = {
  MOVE_TO_LEFT: -1,
  MOVE_TO_RIGHT: 1,
  MOVE_TO_RIGHT_WITH_JUMP: -2,
  MOVE_TO_LEFT_WITH_JUMP: 2
}

# generating pole with frogs
def pole_serializer(frogs_count, left, right)
  return if !frogs_count.is_a?(Numeric) || frogs_count < 1

  pole = ''

  frogs_count.times { |frog| pole += left }
  pole += '_'
  frogs_count.times { |frog| pole += right }

  pole.chars
end

# validations for frog moves
def check_pole(pole, move)
  start_position = pole.index('_')
  new_position = start_position + move

  return if new_position > pole.length-1 || new_position < 0

  if new_position < start_position
    check_left(pole, new_position)
  else
    check_right(pole, new_position)
  end
end

def check_left(pole, frog)
  pole[frog] == RIGHT_LOOKING_FROG
end

def check_right(pole, frog)
  pole[frog] == LEFT_LOOKING_FROG
end

def move_start_position(pole, move)
  start_position = pole.index('_')

  pole[start_position] = pole[start_position + move]
  pole[start_position + move] = '_'

  pole
end

def dfs(pole, mapper)
  visited = []
  target = []

  if pole == mapper
    target.push(pole)
    return target
  else
    MOVES_COST.values.each do |move|
      if check_pole(pole, move)
        visited.push(pole)
        reordered_pole = move_start_position(pole, move)
        visited.push(reordered_pole) unless visited.include? reordered_pole
        dfs(visited.pop, mapper)
      else
        dfs(visited.pop, mapper)
      end
    end
  end
end

def order_frogs(frogs)
  initial_pole = pole_serializer(frogs, RIGHT_LOOKING_FROG, LEFT_LOOKING_FROG)
  ordered_pole = pole_serializer(frogs, LEFT_LOOKING_FROG, RIGHT_LOOKING_FROG)

  cluster = dfs(initial_pole, ordered_pole)
  cluster
end

p order_frogs(2)
