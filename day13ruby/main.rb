TILE_EMPTY = 0
TILE_HORIZ = 1
TILE_VERT = 2
TILE_CURVE_RIGHT =3
TILE_CURVE_LEFT = 4
TILE_INTERSECTION = 5

ORIENT_NORTH = 0
ORIENT_EAST = 1
ORIENT_SOUTH = 2
ORIENT_WEST = 3

CART_ORIENTS = ["^", ">", "v", "<"]

class Cart
  TURN_LEFT = 0
  TURN_NONE = 1
  TURN_RIGHT = 2

  TURN_MAPPING = {
    ORIENT_NORTH => [ORIENT_WEST, ORIENT_NORTH, ORIENT_EAST],
    ORIENT_WEST => [ORIENT_SOUTH, ORIENT_WEST, ORIENT_NORTH],
    ORIENT_SOUTH => [ORIENT_EAST, ORIENT_SOUTH, ORIENT_WEST],
    ORIENT_EAST => [ORIENT_NORTH, ORIENT_EAST, ORIENT_SOUTH]
  }

  TURNS = [TURN_LEFT, TURN_NONE, TURN_RIGHT]

  attr_accessor :orientation, :last_turn, :x, :y, :crashed

  def initialize(x, y, orientation)
    @x = x
    @y = y
    @orientation = orientation
    @last_turn = TURN_RIGHT
    @crashed = false
  end

  def turn!
    @last_turn = (@last_turn + 1) % TURNS.size
    @orientation =  TURN_MAPPING[orientation][@last_turn]
  end

  def <=>(other)
    if self.y == other.y
      self.x <=> other.x
    else
      self.y <=> other.y
    end
  end
end

class Map
  attr_reader :carts, :map

  def initialize(lines)
    @carts = []

    @map = Array.new(lines.map(&:length).max) { Array.new(lines.length, 0) }

    lines.each.with_index do |row, y|
      row.chars.each.with_index do |tile, x|
        @map[x][y] = decode_tile(tile)

        if CART_ORIENTS.include?(tile)
          @carts << Cart.new(x, y, CART_ORIENTS.index(tile))
        end
      end
    end
  end

  def tick(c)
    if c.orientation == ORIENT_NORTH
      c.y -= 1
      tile_next = map[c.x][c.y]
      carts = carts_at(c.x, c.y)

      if carts.size == 2
        crash!(carts)
      elsif tile_next == TILE_CURVE_RIGHT
        c.orientation = ORIENT_EAST
      elsif tile_next == TILE_CURVE_LEFT
        c.orientation = ORIENT_WEST
      elsif tile_next == TILE_INTERSECTION
        c.turn!
      end
    elsif c.orientation == ORIENT_WEST
      c.x -= 1
      tile_next = map[c.x][c.y]
      carts = carts_at(c.x, c.y)

      if carts.size == 2
        crash!(carts)
      elsif tile_next == TILE_CURVE_RIGHT
        c.orientation = ORIENT_SOUTH
      elsif tile_next == TILE_CURVE_LEFT
        c.orientation = ORIENT_NORTH
      elsif tile_next == TILE_INTERSECTION
        c.turn!
      end
    elsif c.orientation == ORIENT_SOUTH
      c.y += 1
      tile_next = map[c.x][c.y]
      carts = carts_at(c.x, c.y)

      if carts.size == 2
        crash!(carts)
      elsif tile_next == TILE_CURVE_RIGHT
        c.orientation = ORIENT_WEST
      elsif tile_next == TILE_CURVE_LEFT
        c.orientation = ORIENT_EAST
      elsif tile_next == TILE_INTERSECTION
        c.turn!
      end
    elsif c.orientation == ORIENT_EAST
      c.x += 1
      tile_next = map[c.x][c.y]
      carts = carts_at(c.x, c.y)

      if carts.size == 2
        crash!(carts)
      elsif tile_next == TILE_CURVE_RIGHT
        c.orientation = ORIENT_NORTH
      elsif tile_next == TILE_CURVE_LEFT
        c.orientation = ORIENT_SOUTH
      elsif tile_next == TILE_INTERSECTION
        c.turn!
      end
    end
  end

  def uncrashed_carts
    carts.reject(&:crashed).size
  end

  private

  def carts_at(x, y)
    carts.select do |c|
      c if !c.crashed && c.x == x && c.y == y
    end
  end

  def crash!(carts)
    carts.each do |c|
      c.crashed = true
    end
  end

  def decode_tile(tile)
    case tile
    when " " then TILE_EMPTY
    when "-", "<", ">" then TILE_HORIZ
    when "|", "^", "v" then TILE_VERT
    when "/" then TILE_CURVE_RIGHT
    when "\\" then TILE_CURVE_LEFT
    when "+" then TILE_INTERSECTION
    end
  end
end

map = Map.new(ARGF.to_a)

finished = false
loop do
  map.carts.sort.each do |cart|
    next if cart.crashed
    map.tick(cart)
    if cart.crashed
      puts "A crash happened at #{cart.x},#{cart.y}"
    end
  end

  if map.uncrashed_carts == 1
    uncrashed = map.carts.detect { |c| !c.crashed }
    puts "The last cart is located at #{uncrashed.x},#{uncrashed.y}"
    break
  end
end

