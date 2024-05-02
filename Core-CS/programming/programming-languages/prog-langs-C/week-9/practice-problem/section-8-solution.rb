require_relative './section-8-provided'

class Character
  def initialize hp
    @hp = hp
  end

  def resolve_encounter enc
    if !is_dead?
      play_out_encounter enc
    end
  end

  def is_dead?
    @hp <= 0
  end

  private

  def play_out_encounter enc
    enc.play_out self
  end
end

class Knight < Character
  def initialize(hp, ap)
    super hp
    @ap = ap
  end

  def to_s
    "HP: " + @hp.to_s + " AP: " + @ap.to_s
  end

  def damage dam
    if @ap == 0
      Knight.new(@hp - dam, 0)
    else
      if dam > @ap then Knight.new(@hp, 0).damage(dam - @ap) else Knight.new(@hp, @ap - dam) end
    end
  end

  def play_out_trap trap
    damage trap.dam
  end

  def play_out_monster monster
    damage monster.dam
  end

  def play_out_potion potion
    Knight.new(@hp + potion.hp, @ap)
  end

  def play_out_armor ar
    Knight.new(@hp, @ap + ar.ap)
  end
end

class Wizard < Character
  def initialize(hp, mp)
    super hp
    @mp = mp
  end

  def to_s
    "HP: " + @hp.to_s + " MP: " + @mp.to_s
  end

  def is_dead?
    @hp <= 0 || @mp < 0
  end
  
  def play_out_trap trap
    if @mp > 0 then Wizard.new(@hp, @mp - 1) else Wizard.new(@hp - trap.dam, @mp) end
  end

  def play_out_monster monster
    Wizard.new(@hp, @mp - monster.hp)
  end

  def play_out_potion potion
    Wizard.new(@hp + potion.hp, @mp + potion.mp)
  end

  def play_out_armor armor
    self
  end
end

class FloorTrap < Encounter
  attr_reader :dam

  def initialize dam
    @dam = dam
  end

  def to_s
    "A deadly floor trap dealing " + @dam.to_s + " point(s) of damage lies ahead!"
  end

  def play_out character
    character.play_out_trap self
  end
end

class Monster < Encounter
  attr_reader :dam, :hp

  def initialize(dam, hp)
    @dam = dam
    @hp = hp
  end

  def to_s
    "A horrible monster lurks in the shadows ahead. It can attack for " +
        @dam.to_s + " point(s) of damage and has " +
        @hp.to_s + " hitpoint(s)."
  end

  def play_out character
    character.play_out_monster self
  end
end

class Potion < Encounter
  attr_reader :hp, :mp

  def initialize(hp, mp)
    @hp = hp
    @mp = mp
  end

  def to_s
    "There is a potion here that can restore " + @hp.to_s +
        " hitpoint(s) and " + @mp.to_s + " mana point(s)."
  end

  def play_out character
    character.play_out_potion self
  end
end

class Armor < Encounter
  attr_reader :ap

  def initialize ap
    @ap = ap
  end

  def to_s
    "A shiny piece of armor, rated for " + @ap.to_s +
        " AP, is gathering dust in an alcove!"
  end

  def play_out character
    character.play_out_armor self
  end
end


sir_foldalot = Knight.new(15, 3)
knight_of_lambda_calculus = Knight.new(10, 10)
sir_pinin_for_the_fjords = Knight.new(0, 15)
alonzo_the_wise = Wizard.new(3, 50)
dhuwe_the_unready = Wizard.new(8, 5)

dungeon_of_mupl = [
    Monster.new(1, 1),
    FloorTrap.new(3),
    Monster.new(5, 3),
    Potion.new(5, 5),
    Monster.new(1, 15),
    Armor.new(10),
    FloorTrap.new(5),
    Monster.new(10, 10)
    ]
the_dark_castle_of_proglang = [
    Potion.new(3, 3),
    Monster.new(1, 1),
    Monster.new(2, 2),
    Monster.new(4, 4),
    FloorTrap.new(3),
    Potion.new(3, 3),
    Monster.new(4, 4),
    Monster.new(8, 8),
    Armor.new(5),
    Monster.new(3, 5),
    Monster.new(6, 6),
    FloorTrap.new(5)
    ]


if __FILE__ == $0
  puts "\-----Knight-----\n\n"
  Adventure.new(Stdout.new, sir_foldalot, the_dark_castle_of_proglang).play_out
  puts "\n\n-----WIZARD-----\n\n"
  Adventure.new(Stdout.new, alonzo_the_wise, dungeon_of_mupl).play_out
end
