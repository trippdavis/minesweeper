require 'byebug'
require 'yaml'

MOVES = [[-1, 0], [-1, 1], [0, 1], [1, 1], [1, 0], [1, -1], [0, -1], [-1, -1]]

class Minesweeper
  attr_reader :board

  def initialize
    @board = Board.new
    nil
  end

  def play
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
        picked_tile.flag = true
        next
      when picked_tile.type == "B" && !picked_tile.revealed
        puts 'You lose!'
        return
      when picked_tile.bomb_count >= 0
        picked_tile.reveal
      end


    end

    puts "You won!"
  end

  def won?
    board.board.each do |row|
      row.each do |space|
        return false if space.type == "S" && !space.revealed?
      end
    end

    true
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
    nil
  end

  def populate_board
    tiles = ["B"] * 3 + ["S"] * 78
    tiles.shuffle!
    @board.each_with_index do |row, row_i|
      row.each_with_index do |col, col_i|
        @board[row_i][col_i] = Tile.new(tiles.pop, @board, [row_i, col_i])
      end
    end

    nil
  end

  def out_of_bounds?(arr)
    arr[0] < 0 || arr[1] > 8 || arr[0] > 8 || arr[1] < 0
  end

  def display
    p "[ ][0][1][2][3][4][5][6][7][8]"
    @board.each_with_index do |row, row_i|
      row_display = ""
      row.each do |space|
        case
        when space.revealed? && space.bomb_count == 0
          row_display << "[_]"
        when space.revealed? && space.bomb_count > 0
          row_display << "[#{space.bomb_count}]"
        when space.flagged?
          row_display << "[F]"
        else
          row_display << "[*]"
        end
      end
      p "[#{row_i}]" + row_display
    end

    nil
  end

end

class Tile
  attr_accessor :state, :type, :revealed, :flag
  attr_reader :board, :pos

  def initialize(type, board, pos)
    @pos = pos
    @revealed = false
    @flag = false
    @type = type
    @board = board
  end

  def bomb_count
    bomb_count = 0
    MOVES.each do |move|
      if (pos[0] + move[0]) >= 0 && (pos[0] + move[0]) < 9 &&
        (pos[1] + move[1]) >= 0 && (pos[1] + move[1]) < 9

        bomb_count += 1 if board[pos[0] + move[0]][pos[1] + move[1]].type == "B"
      end
    end
    bomb_count
  end

  def neighbors
    MOVES.map do |move|
      if (pos[0] + move[0]) >= 0 && (pos[0] + move[0]) < 9 &&
        (pos[1] + move[1]) >= 0 && (pos[1] + move[1]) < 9

        board[pos[0] + move[0]][pos[1] + move[1]]
      end
    end.compact
  end

  def reveal
    return if revealed
    self.revealed = true
    if bomb_count == 0
      neighbors.each do |neighbor|
        neighbor.reveal
      end
    end
  end
  def revealed?
    revealed
  end


  def flagged?
    @flag
  end
end
