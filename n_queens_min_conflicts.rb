class Queen
  def initialize(n)
    @queens = Array.new(n, 0)
    @n = n
    resolve_conflicts(@queens)
  end

  attr_accessor :n

  def draw
    result = ''
    @queens.each do |q|
      row = ['_ '] * n
      row[q] = 'Q '
      result += "#{row.join}\n"
    end
    print result
  end

  def resolve_conflicts(queens, steps = 200)
    steps.times do
      conflicts = array_of_conflicts
      return queens if conflicts.sum == 0
      col = random_position(conflicts, lambda { |x| x > 0 })
      vertical_conflicts = []
      n.times { |row| vertical_conflicts.push(find_conflicts(queens, col, row)) }
      queens[col] = random_position(vertical_conflicts, lambda { |x| x == vertical_conflicts.min })
    end
    # raise "Incomplete solution: try more iterations."
  end

  def random_position(array, func)
    i = rand(array.size)
    if func.call(array[i])
      return array[i]
    else
      random_position(array, func)
    end
  end

  def array_of_conflicts
    conflicts = []
    n.times { |i| conflicts.push(find_conflicts(@queens, i, @queens[i]))}
    conflicts
  end

  def find_conflicts(queens, col, row)
    conflicts = 0
    queens.each_with_index do |q, i|
      next if q == col

      if q == row || (q - row).abs == (i - col).abs
        conflicts += 1
      end
    end
    conflicts
  end
end

print 'Enter queens amount: '
n = gets
if n.to_i > 3
  q = Queen.new(n.to_i)
  q.draw
else
  p 'Numbers below 3 are not valid!'
end
