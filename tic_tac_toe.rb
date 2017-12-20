# Tic-Tac-Toe game using Minimax algorithm and Alpha-Beta prunning

class GameState
  attr_accessor :current_player, :board, :moves, :rank

  def initialize(current_player, board)
    @current_player = current_player
    @board = board
    @moves = []
  end

  def rank
    @rank ||= final_state_rank || intermediate_state_rank
  end

  def next_move
    @moves.max { |a, b| a.rank <=> b.rank }
  end

  def final_state_rank
    if final_state?
      return 0 if draw?
      winner == "X" ? 1 : -1
    end
  end

  def final_state?
    winner || draw?
  end

  def draw?
    @board.compact.size == 9 && winner.nil?
  end

  def intermediate_state_rank
    ranks = @moves.collect{ |game_state| game_state.rank }

    @current_player == 'X' ? ranks.max : ranks.min
  end

  def winner
    @winner ||= [
     # horizontal wins
     [0, 1, 2],
     [3, 4, 5],
     [6, 7, 8],

     # vertical wins
     [0, 3, 6],
     [1, 4, 7],
     [2, 5, 8],

     # diagonal wins
     [0, 4, 8],
     [6, 4, 2]
    ].collect { |positions|
      ( @board[positions[0]] == @board[positions[1]] &&
        @board[positions[1]] == @board[positions[2]] &&
        @board[positions[0]] ) || nil
    }.compact.first
  end
end

class GameTree
  def generate
    initial_game_state = GameState.new(get_player_choice, Array.new(9))
    generate_moves(initial_game_state)
    initial_game_state
  end

  private

  def get_player_choice
    puts "Press 1 for starting first\nPress 2 for starting second"
    choice = gets
    choice.to_i == 1 ? 'O' : 'X'
  end

  def generate_moves(game_state)
    next_player = (game_state.current_player == 'X' ? 'O' : 'X')

    game_state.board.each_with_index do |player_at_position, position|
      unless player_at_position
        next_board = game_state.board.dup
        next_board[position] = game_state.current_player

        next_game_state = GameState.new(next_player, next_board)
        game_state.moves << next_game_state
        generate_moves(next_game_state)
      end
    end
  end
end

class Game
  def initialize
    @game_state = GameTree.new.generate
  end

  def turn
    if @game_state.final_state?
      print_game_result
      exit
    end

    if @game_state.current_player == 'X'
      @game_state = @game_state.next_move
      puts "X's move:"
      turn
    else
      render_board
      get_human_move
      turn
    end
  end

  def render_board
    output = ""
    0.upto(8) do |position|
      output << " #{@game_state.board[position] || position} "
      case position % 3
      when 0, 1 then output << "|"
      when 2 then output << "\n-----------\n" unless position == 8
      end
    end
    puts "#{output}\n"
  end

  def get_human_move
    puts "Enter square # to place your 'O' in:"
    position = gets

    move = @game_state.moves.find{ |state| state.board[position.to_i] == 'O' }

    if move
      @game_state = move
    else
      puts "That's not a valid move"
      get_human_move
    end
  end

  def print_game_result
    if @game_state.draw?
      puts "It was a draw!"
    elsif @game_state.winner == 'X'
      puts "X won!"
    else
      puts "O won!"
    end
  end
end

Game.new.turn
