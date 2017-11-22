# Solve N-queens problem with simulated annealing

# queens are going to be represented with array
# Example: [0, 0, 1, 2, 4]
# -> 1st element here means "Q on 1st row is on 1st column"
# [Q, +, +, +, +]
# [Q, +, +, +, +]
# [+, Q, +, +, +]
# [+, +, Q, +, +]
# [+, +, +, +, Q]

# Used recourse: http://letstalkdata.com/2013/12/n-queens-part-2-more-algorithms/

ANNEALING_RATE = 0.95
MAX_TRIES = 10 ** 6

class Blacksmith
  def initialize(queens_places, temperature)
    @queens_places = queens_places
    @temp = temperature
  end

  def annealing
    queens_places = @queens_places
    heuristic = get_collisions(@queens_places)
    tries = 0

    while heuristic > 0
      queens_places, heuristic = make_annealing_move(queens_places, heuristic)
      # Make sure temp doesn't get impossibly low - stabilizing
      @temp = [@temp * ANNEALING_RATE, 0.01].max

      # check for highlands
      if tries >= MAX_TRIES
        p 'STUCKED!!!!'
        queens_places = nil
        break
      end
      tries += 1
    end
    queens_places
  end

  private

  # returns number of collisions
  def get_collisions(queens_places)
    collisions = 0
    i = 0

    while i < queens_places.size
      j = i + 1
      while j < queens_places.size
        collisions += 1 if queens_places[i] == queens_places[j]

        collisions += 1 if collisions_on_diagonal?(queens_places, i, j)

        j += 1
      end
      i += 1
    end
    collisions
  end

  def collisions_on_diagonal?(array, row, col)
    margin = col - row
    array[row] == array[col] - margin || array[row] == array[col] + margin
  end

  # move queen in random row
  def move_random_queen(queens_places)
    row = rand(queens_places.size)
    queen = rand(queens_places.size)

    queens_places[row] = queen

    queens_places
  end

  def make_annealing_move(queens_places, heuristic)
    found_move = false

    while not found_move
      queens_places_copy = queens_places.dup
      # move queens randomly
      new_queens_places = move_random_queen(queens_places_copy)
      # check newly generated collisions
      new_heuristic = get_collisions(new_queens_places)

      if new_heuristic >= heuristic
        # difference in collisions
        delta = heuristic - new_heuristic
        temp = @temp
        accept_probability = [1, Math::exp(delta / temp)].min
        # there is chance to accept the bad job of blacksmith even with higher heuristic
        found_move = accept_probability >= rand
      else
        found_move = true
      end
    end
    [new_queens_places, new_heuristic]
  end
end

class Board
  def initialize(n)
    @size = n
    @size_of_empty_boxes = n ** 2
    @queens_locator = []
    initial_board = generate_board

    @blacksmith = Blacksmith.new(@queens_locator, @size_of_empty_boxes)
  end

  def solve_n_queens_problem
    solution = @blacksmith.annealing
    board = solution.nil? ? nil : draw_solution(solution)
    # board.each { |row| p row } if board
    # print "\n\n\n\n\n"
  end

  private

  def generate_board
    board = draw_empty_board

    board.each do |row|
      queen = rand(row.size)
      row[queen] = 'Q'
      # locate the place of queen
      @queens_locator.push(queen)
    end
    board
  end

  def draw_empty_board
    empty_boxes = []
    board = []
    @size_of_empty_boxes.times { empty_boxes.push('_') }

    @size.times do
      board.push(empty_boxes[0..@size - 1])
      empty_boxes = empty_boxes[@size..empty_boxes.size]
    end

    board
  end

  def draw_solution(solution)
    board = draw_empty_board

    solution.each_with_index { |row, queen| board[row][queen] = 'Q' }

    board
  end
end
