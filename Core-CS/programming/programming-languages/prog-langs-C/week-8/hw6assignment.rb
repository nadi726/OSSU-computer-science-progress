# University of Washington, Programming Languages, Homework 6, hw6runner.rb

class MyPiece < Piece
  All_My_Pieces = All_Pieces + [
                  rotations([[0, 0], [1, 0], [0, 1], [1, 1], [2, 1]]), # ::. shape
                  [[[0, 0], [-1, 0], [1, 0], [2, 0], [-2, 0]], # 5 long (only needs two)
                   [[0, 0], [0, -1], [0, 1], [0, 2], [0, -2]]],
                  rotations([[0, 0], [0, 1], [1, 1]]) # :. shape
                  ]
  Cheat_Piece = [[[0, 0]]]

  # get the piece's size - the number of blocks it contains
  def size
    current_rotation.size
  end

  # CHANGED: uses MyPiece instead of Piece, account for cheat piece
  def self.next_piece (board, cheat:false)
    new_piece = if cheat then Cheat_Piece else All_My_Pieces.sample end
    MyPiece.new(new_piece, board)
  end
  
end

class MyBoard < Board
  # CHANGED: uses MyPiece instead of Piece, account for cheat piece
  def initialize (game)
    @grid = Array.new(num_rows) {Array.new(num_columns)}
    @current_block = MyPiece.next_piece(self)
    @score = 0
    @game = game
    @delay = 500
    @cheat = false
  end

  # rotates the current piece 180 degrees
  def rotate_180_degrees
    if !game_over? and @game.is_running?
      @current_block.move(0, 0, 2)
    end
    draw
  end

  # make the next piece a cheat piece if the conditions are met
  def use_cheat_piece
    if not @cheat and @score >= 100
      @score -= 100
      @cheat = true
    end
  end

  # CHANGED: uses MyPiece instead of Piece, account for cheat piece
  def next_piece
    @current_block = MyPiece.next_piece(self, cheat: @cheat)
    @current_pos = nil
    @cheat = false
  end

  # CHANGED: accounts for the different length of the added pieces
  def store_current
    locations = @current_block.current_rotation
    displacement = @current_block.position
    size = @current_block.size
    (0..(size-1)).each{|index| 
      current = locations[index];
      @grid[current[1]+displacement[1]][current[0]+displacement[0]] = 
      @current_pos[index]
    }
    remove_filled
    @delay = [@delay - 2, 80].max
  end
end

class MyTetris < Tetris
  # CHANGED: uses MyBoard instead of Board
  def set_board
    @canvas = TetrisCanvas.new
    @board = MyBoard.new(self)
    @canvas.place(@board.block_size * @board.num_rows + 3,
                  @board.block_size * @board.num_columns + 6, 24, 80)
    @board.draw
  end

  def key_bindings
    super
    @root.bind("u", proc {@board.rotate_180_degrees})
    @root.bind("c", proc {@board.use_cheat_piece})
  end

end
