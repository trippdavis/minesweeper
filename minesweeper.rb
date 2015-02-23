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
        @board[row_i][col_i] = Tile.new(tiles.pop, @board)
      end
    end
  end

  def display
    @board.each do |row|
      row_display = []
      row.each do |space|

        row_display << space.type
      end
      p row_display
    end
  end

end

class Tile
  attr_accessor :state, :type

  def initialize(type, board)
    @state = "*" #revelead or unrevealed
    @type = type #bomb,flag,etc
    @board = board
  end



end

board = Board.new
board.populate_board
board.display
