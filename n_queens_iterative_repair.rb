# Solve N Queens problem with iterative repairing algorithm

# Used recourse: https://en.wikipedia.org/wiki/Min-conflicts_algorithm

# queens are going to be represented with array
# Example: [0, 0, 1, 2, 4]
# -> 1st element here means "Q on 1st row is on 1st column"
# [Q, +, +, +, +]
# [Q, +, +, +, +]
# [+, Q, +, +, +]
# [+, +, Q, +, +]
# [+, +, +, +, Q]

class Queen
  def initialize(n)
    @size = n
    @rows = Array.new(n) { |q| q = rand(n) } # generates random queens positions
  end

  attr_accessor :rows

  def resolve_conflicts
    steps = 0
    new_queens = []

    while true
      max_conflicts = 0
      new_queens.clear

      @size.times do |queen_col|
        col_conflicts = find_conflicts(@rows[queen_col], queen_col)

        new_queens.push(queen_col) if col_conflicts == max_conflicts

        if col_conflicts > max_conflicts
          max_conflicts = col_conflicts
          new_queens.clear
          new_queens.push(queen_col)
        end
      end
      # @rows.each_with_index do |queen_row, queen_col|
      #   col_conflicts = find_conflicts(queen_row, queen_col)

      #   new_queens.push(queen_col) if col_conflicts == max_conflicts

      #   if col_conflicts > max_conflicts
      #     max_conflicts = col_conflicts
      #     new_queens.clear
      #     new_queens.push(queen_col)
      #   end
      # end

      break if max_conflicts.zero?

      random_max_conflict_col = new_queens[rand(new_queens.size)]
      min_conflicts = @size
      new_queens.clear

      @size.times do |queen_row|
        row_conflicts = find_conflicts(queen_row, random_max_conflict_col)

        new_queens.push(queen_col) if row_conflicts == min_conflicts

        if row_conflicts < min_conflicts
          min_conflicts = row_conflicts
          new_queens.clear
          new_queens.push(queen_row)
        end
      end
      # @rows.each_with_index do |queen_row, queen_col|
      #   row_conflicts = find_conflicts(queen_row, random_max_conflict_col)

      #   new_queens.push(queen_col) if row_conflicts == min_conflicts

      #   if row_conflicts < min_conflicts
      #     min_conflicts = row_conflicts
      #     new_queens.clear
      #     new_queens.push(queen_row)
      #   end
      # end

      if new_queens.empty?
        @rows[random_max_conflict_col] = new_queens[rand(new_queens.size)]
      end
    end
  end

  def draw
    board = ''
    @rows.each do |q|
      board_row = Array.new(@size) { |i| i = '_' }
      board_row[q] = 'Q'
      board += "#{board_row.join(' ')}\n"
    end
    print board
  end

  def find_conflicts(row, column)
    conflicts = 0
    @size.times do |queen_col|
      next if queen_col == column

      queen_row = @rows[queen_col]
      if queen_row == row || (queen_row - row).abs == (queen_col - column).abs
        conflicts += 1
      end
    end
    conflicts
  end

print 'Enter queens amount: '
n = gets
if n.to_i > 3
  queens = Queen.new(n.to_i)
  queens.resolve_conflicts
  queens.draw
else
  p 'Numbers below 3 are not valid!'
end

