require 'byebug'

class Minesweeper
  def initialize
    @board = Board.new
  end
end

class Board
  attr_accessor :board

  def initialize
    @board = Array.new(9) { Array.new(9) }
  end

  def populate_board
    tiles = ["B"] * 9 + ["S"] * 72
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

  def get_move
    puts "What tile do you want to pick?"
    pick = gets.chomp.split(',') # ex. [1,2]
  end



  def play
    #player picks
    #game checks spot
    #decide if winner
    until won?
      display
      pick = get_move
      tile_x = pick[1].to_i
      tile_y = pick[2].to_i
      picked_tile = @board[tile_x][tile_y]

      next if picked_tile.flagged?
      if pick[0] == "f"
        picked_tile.state = "F"
        next
      end

      if picked_tile.type == "B" && picked_tile.state == "*"
        #end of game
        puts 'You lose!'
        return
      end

      if picked_tile.bomb_count > 0
        picked_tile.reveal
      end

      if picked_tile.bomb_count == 0
        reveal_bomb_count(picked_tile)
      end
    end

    puts "You won!"
  end





  def won?
    @board.each do |row|
      row.each do |space|
          return false if space.type == "S" && space.state == "*"
      end
    end

    true
  end

  def reveal_bomb_count(picked_tile)
    moves = [[-1, 0],[-1, 1],[0, 1], [1, 1], [1,0], [1,-1], [0,-1],[-1,-1]]
    neighbors = [picked_tile]
    until neighbors.empty?
      new_neighbors = []

      neighbors.each do |tile|
        next unless tile.state == "*"
        tile.reveal
        moves.each do |move|
          move_x = tile.pos[0] + move[0]
          move_y = tile.pos[1] + move[1]
          unless out_of_bounds?([move_x, move_y])
            neighbor_tile = @board[move_x][move_y]
            if tile.bomb_count == 0
              new_neighbors << neighbor_tile
            end
          end
        end
      end

      neighbors = new_neighbors
    end
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
    moves = [[-1, 0],[-1, 1],[0, 1], [1, 1], [1,0], [1,-1], [0,-1],[-1,-1]]
    moves.each do |move|
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
