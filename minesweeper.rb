require 'byebug'
require 'yaml'


MOVES = [[-1, 0],[-1, 1],[0, 1], [1, 1], [1,0], [1,-1], [0,-1],[-1,-1]]
class Minesweeper
  attr_reader :board

  def initialize
    @board = Board.new
  end

  def play
    #player picks
    #game checks spot
    #decide if winner
    until won?
      board.display
      pick = get_move
      unless pick
        puts "Invalid pick"
        next
      end
      tile_x = pick[1].to_i
      tile_y = pick[2].to_i
      picked_tile = @board.board[tile_x][tile_y]

      case
      when picked_tile.flagged?
        next
      when pick[0] == "f"
        picked_tile.state = "F"
        next
      when picked_tile.type == "B" && picked_tile.state == "*"
        puts 'You lose!'
        return
      when picked_tile.bomb_count > 0
        picked_tile.reveal
      when picked_tile.bomb_count == 0
        reveal_bomb_count(picked_tile)
      end


    end

    puts "You won!"
  end

  def won?
    board.board.each do |row|
      row.each do |space|
          return false if space.type == "S" && space.state == "*"
      end
    end

    true
  end

  def reveal_bomb_count(picked_tile)

    neighbors = [picked_tile]
    until neighbors.empty?
      # new_neighbors = []
      this_tile = neighbors.shift
      next unless this_tile.state == "*"
      this_tile.reveal
      MOVES.each do |move|
        move_x = this_tile.pos[0] + move[0]
        move_y = this_tile.pos[1] + move[1]
        unless @board.out_of_bounds?([move_x, move_y])
          neighbor_tile = @board.board[move_x][move_y]
          if this_tile.bomb_count == 0
            neighbors << neighbor_tile
          end
        end
      end
    end
  end

  def get_move
    puts "What tile do you want to pick? (type s to save game)"
    pick = gets.chomp.split(',') # ex. [1,2]
    if pick[0] == "s"
      save
      abort
    end
    return false unless pick.count == 3
    pick
  end

  def save
    File.open('minesweeper.yml', 'w') do |f|
      f.puts self.to_yaml
    end
  end

  def self.load
    game = YAML::load_file('minesweeper.yml')
    game.play
  end

end

class Board
  attr_accessor :board

  def initialize
    @board = Array.new(9) { Array.new(9) }
    populate_board
  end

  def populate_board
    tiles = ["B"] * 3 + ["S"] * 78
    tiles.shuffle!
    @board.each_with_index do |row, row_i|
      row.each_with_index do |col, col_i|
        @board[row_i][col_i] = Tile.new(tiles.pop, @board, [row_i, col_i])
      end
    end
    @board.each_with_index do |row, row_i|
      row.each_with_index do |col, col_i|
        @board[row_i][col_i].populate_bombs
      end
    end

    nil
  end

  def out_of_bounds?(arr)
    arr[0] < 0 || arr[1] > 8 || arr[0] > 8 || arr[1] < 0
  end

  def display
    @board.each do |row|
      row_display = []
      row.each do |space|

        row_display << space.type
      end
      p row_display
    end
    p ""
    @board.each do |row|
      row_display = []
      row.each do |space|

        row_display << space.state.to_s
      end
      p row_display
    end

    return nil
  end

end

class Tile
  attr_accessor :state, :type
  attr_reader :board, :pos, :bomb_count

  def initialize(type, board, pos)
    @pos = pos
    @state = "*" #revelead or unrevealed
    @type = type #bomb,flag,etc
    @board = board
    @bomb_count = 0
  end

  def populate_bombs

    MOVES.each do |move|
      if (pos[0] + move[0]) >= 0 && (pos[0] + move[0]) < 9 &&
         (pos[1] + move[1]) >= 0 && (pos[1] + move[1]) < 9

         @bomb_count += 1 if board[pos[0] + move[0]][pos[1] + move[1]].type == "B"
       end
    end
  end

  def reveal
    if @bomb_count > 0
      @state = @bomb_count
    else
      @state = "_"
    end
  end

  def flagged?
    @state == "F"
  end
end

# board = Board.new
# board.populate_board
# board.display
# board.play
