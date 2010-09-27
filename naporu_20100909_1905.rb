#######################################################
#
# demo-ruboto.rb (by Takashi Fujiwara)
#
# A simple look at how to generate and 
# use a RubotoActivity.
#
#######################################################

require "pp"
require "ruboto.rb"
confirm_ruboto_version(4)

#
# ruboto_import_widgets imports the UI widgets needed
# by the activities in this script. ListView and Button 
# come in automatically because those classes get extended.
#

ruboto_import_widgets :LinearLayout, :EditText, :TextView

#
# $activity is the Activity that launched the 
# script engine. The start_ruboto_activity
# method creates a new RubotoActivity to work with.
# After launch, the new activity can be accessed 
# through the $ruboto_demo (in this case) global.
# You man not need the global, because the block
# to start_ruboto_activity is executed in the 
# context of the new activity as it initializes. 
#
$activity.start_ruboto_activity "$ruboto_demo" do
  #
  # setup_content uses methods created through
  # ruboto_import_widgets to build a UI. All
  # code is executed in the context of the 
  # activity.
  #
  #cards = "[sK][sJ][s9][s8][h8][dA][d4][d2][c8][c6][c5][c0]"
  @cards = %w[sK sJ s9 s8 h8 dA d4 d2 c8 c6 c5 c0]
  
  setup_content do
    linear_layout(:orientation => LinearLayout::VERTICAL) do
      linear_layout do
        @et = edit_text
        button :text => "Play", :width => :wrap_content
      end
      @tv = text_view :text => ""
    end
  end

   #@tv.append "#{cards}"
   
  #
  # Another callback method for OnClick. Buttons
  # automatically get the activity as a handler.
  #
  handle_click do |view|
    case view.getText
      when "dummy"
      else
        my_click(view.getText)
    end
  end

  #
  # Extra singleton methods for this activity
  # need to be declared with self. This one 
  # handles some of the button and menu clicks.
  # 
  def self.my_click(text)
    $android_out = ""
    input_card = @et.getText
    card = "#{input_card}"
    #toast "#{@cards.size}"
    card = card.suit + card.number.upcase
    @cards.delete("#{card}")
    #toast card
    #toast "#{@cards.size}"
    #@tv.append "\n#{text}"
    my_cards =""
    @cards.each do |c|
      my_cards += "[#{c}]"
    end
    #naporu
    napo
    toast "End"
  end
  
  def napo
    print_s "test"
    p_s "TEST"
    human_player_count = 0
    player_count = 4
    t = Table.new(human_player_count, player_count)
    t.shuffle
    toast t.all_cards.size
    
   
    
    
    
    draw
  end
  
  def naporu
    human_player_count = 0
    player_count = 4
    ans = 'n'
    while(ans != 'n')
      t = Table.new(human_player_count, player_count)
      t.shuffle
      t.first_deal
      t.real_declaration
      t.election
      t.assign_lieut
      t.players.each do |p|
        p.exchange(t) if p.role == 'napoleon'
        t.winner_id = p.id if p.role == 'napoleon'
      end
      catch(:game_over) do
        t.play
      end
    end  
  end 
  
end
  
### Extentions for Napo ###

module Kernel
  ##
  def print_s(text)
    $android_out << "#{text}"
  end
  
  def p_s(text)
    $android_out << "#{text}\n"
  end
  
  def draw
    @tv.setText "#{$android_out}\n"
  end
  
end
  
class String
  # Defining class Card has more overheads so that choose extending String class
  def suit
    self.slice(0,1)
  end
  
  def reverse
    case self
    when 's'
      'c'
    when 'h'
      'd'
    when 'd'
      'h'
    when 'c'
      's'
    else
      'o'
    end
  end
  
  def order
    case self
    when 's'
      4
    when 'h'
      3
    when 'd'
      2
    when 'c'
      1
    else
      0
    end
  end
  
  def number
    self.slice(1,1)
  end
  
  def value
    case self.number
    when 'A'
      if self.suit == 's'
        50
      else
        15
      end
    when 'K'
      14
    when 'Q'
      if self.suit == 'h'
        13
      else
        12
      end
    when 'J'
      11 
    when '0'
      10
    when 'o'
      11
    when '#'
      0
    else
      self.number.to_i
    end
  end
  
  def normalize
    if self == 'jo'
      'Jo'
    elsif self == 'Jo'
      'Jo'
    else
      self.suit + self.slice(1,1).upcase
    end
  end
  
  def pict?
    if self.value >= 10 && self != 'Jo'
      true
    elsif self.value < 10 || self == 'Jo'
      false
    end
  end
  
  def two? 
    self.number == '2' 
  end
 
  def joker? 
    self == 'Jo' 
  end
 
  def yoro? 
    self == 'hQ'
  end
 
  def mighty? 
    self == 'sA'
  end
 
  # Defining class Target has more overheads so that choose extending String class
  def target
    self.slice(1,2).to_i
  end
  
  def plus_1
    dec_target = self.target + 1
    self.suit + dec_target.to_s
  end
  
  def plus_2
    dec_target = self.target + 2
    self.suit + dec_target.to_s
  end
  
end

class Array
   
  def max_value_card
    card_values = []
    max_value_cards = []
    this_card = ''
    self.each do |card|
      card_values << card.value
    end
    card_max_value = card_values.max
    self.each do |card|
      if card.value == card_max_value
        max_value_cards << card
      end
    end
    this_card = max_value_cards.sort!.reverse!.first 
    return this_card
  end
 
  def min_value_card
    card_values = []
    min_value_cards = []
    this_card = ''
    self.each do |card|
      card_values << card.value
    end
    card_min_value = card_values.min
    self.each do |card|
      if card.value == card_min_value
        min_value_cards << card
      end
    end
    this_card = min_value_cards.sort!.reverse!.first 
    return this_card
  end
 
  def obverse_cards(table_obverse)
    o_cards = []
    self.each do |card|
      o_cards << card if card.suit == table_obverse
    end
    return o_cards
  end
 
  def not_obverse_cards(table_obverse)
    not_o_cards = []
    self.each do |card|
      not_o_cards << card if card.suit != table_obverse
    end
    return not_o_cards
  end
  
  def minnows(table_obverse)
    ms = []
    self.each do |card|
      if card.mighty?
      elsif card.yoro?
      elsif card == "#{table_obverse}J"
      elsif card == "#{table_obverse.reverse}J"
      elsif card.two?
      elsif card.suit == table_obverse
      else
        ms << card
      end
    end
    ms.sort!.reverse!
    return ms
  end
 
  def except_two_and_joker
    cards = []
    self.each do |card|
      if card.number == '2'
      elsif card == 'Jo'
      else
        cards << card
      end
    end
    cards.sort!.reverse!
    return cards
  end
 
  def pict_cards
    p_cards = []
    self.each do |card|
      p_cards << card if card.pict?
    end
    return p_cards
  end
 
  def suit_cards(target_suit)
    s_cards = []
    self.each do |card|
      s_cards << card if card.suit == target_suit
    end
    return s_cards
  end
 
  def number_cards(target_number)
    n_cards = []
    self.each do |card|
      n_cards << card if card.number == target_number
    end
    return n_cards
  end
 
  def has_mighty?
    if self.find {|card| card == 'sA' }
      true
    else
      false
    end
  end
 
  def has_obverse_jack?(table_obverse)
    if self.find {|card| card == "#{table_obverse}J" }
      true
    else
      false
    end
  end
 
  def has_reverse_jack?(table_obverse)
    if self.find {|card| card == "#{table_obverse.reverse}J" }
      true
    else
      false
    end
  end
 
  def has_obverse?(table_obverse)
    if self.find {|card| card.suit == "#{table_obverse}" }
      true
    else
      false
    end
  end
 
  def has_not_obverse?(table_obverse)
    if self.find {|card| card.suit != "#{table_obverse}" }
      true
    else
      false
    end
  end
 
  def has_first_suit?(first_suit)
    if self.find {|card| card.suit == "#{first_suit}" }
      true
    else
      false
    end
  end
 
  def has_suit?(suit)
    if self.find {|card| card.suit == "#{suit}" }
      true
    else
      false
    end
  end
 
  def has_yoro?
    if self.find {|card| card == 'hQ' }
      true
    else
      false
    end
  end
 
  def has_two?
    if self.find {|card| card.number == '2'}
      true
    else
      false
    end
  end
 
  def has_joker?
    if self.find {|card| card == 'Jo'}
      true
    else
      false
    end
  end
  
  def has_pict?
    if self.find {|card| card.pict? == true }
      true
    else
      false
    end
  end
 
  def full_open?
    if self.find {|card| card == '#' }
      false
    else
      true
    end
  end
 
  def has?(target_card)
    if self.find {|card| card == target_card }
      true
    else
      false
    end
  end
  
  def except(target_card)
    e_cards = []
    self.each do |card|
      e_cards << card unless card == target_card
    end
    return e_cards
  end
  
end


class Table
  attr_accessor :total_player_count
  attr_accessor :human_player_count
  attr_accessor :players
  attr_accessor :all_cards
  attr_accessor :mount_cards
  attr_accessor :mount_cards_size
  attr_accessor :player_cards_size
  attr_accessor :declarations
  attr_accessor :target
  attr_accessor :obverse
  attr_accessor :napo_id
  attr_accessor :lieut
  attr_accessor :lieut_id
  attr_accessor :first_suit
  attr_accessor :first_card
  attr_accessor :faceup_cards
  attr_accessor :facedown_cards
  attr_accessor :all_gotten_picts
  attr_accessor :turn_id
  attr_accessor :winner_id
  attr_accessor :napos_picts
  attr_accessor :coals_picts
  
  def initialize(human_player_count, player_count)
    self.prepare_players(human_player_count, player_count)
    @mount_cards = []
    @faceup_cards = Hash.new # Card => Player's id
    @facedown_cards = Hash.new # Card => Player's id
    @declarations = Hash.new # Player's id => suit_target
    @all_gotten_picts = []
    @napos_picts = []
    @coals_picts = []
    @turn_id = 0
    if player_count == 4
      @mount_cards_size = 5
      @player_cards_size = 12
      @target = 13
    elsif player_count == 5
      @mount_cards_size = 3 
      @player_cards_size = 10 
      @target = 12
    elsif player_count == 6
      @mount_cards_size = 5
      @player_cards_size = 8
      @target = 10
    end
  end

  def prepare_players(human_player_count, player_count)
    @players = [] 
    cpu_player_count = player_count - human_player_count
    if human_player_count == 0
      1.upto cpu_player_count do |cpu_player_id|
        cpu_player = CPUPlayer.new
        cpu_player.brain = 'cpu'
        @players << cpu_player
      end
    else
      1.upto human_player_count do |human_player_id|
        human_player = HumanPlayer.new
        human_player.brain = 'human'
        @players << human_player
      end
      1.upto cpu_player_count do |cpu_player_id|
        cpu_player = CPUPlayer.new
        cpu_player.brain = 'cpu'
        @players << cpu_player
      end
    end
    @players = @players.sort_by{rand}
    1.upto @players.size do |i|
      @players[i-1].id = i
    end
  end

  def shuffle
    @all_cards = ['Jo']
    1.upto 13 do |number|
      ['s', 'h', 'd', 'c'].each do |suit|
        @all_cards << suit + number.to_s if number > 1 && number < 10 
        @all_cards << suit + '0' if number == 10
        @all_cards << suit + 'J' if number == 11
        @all_cards << suit + 'Q' if number == 12
        @all_cards << suit + 'K' if number == 13
        @all_cards << suit + 'A' if number == 13
      end 
    end
    @all_cards = @all_cards.sort_by{rand}
  end

  def first_deal
  
    1.upto @mount_cards_size do
      @mount_cards << @all_cards.pop
    end

    1.upto(@all_cards.size/@players.size) do
       @players.each do |p|
         p.cards << @all_cards.pop
       end
    end
  end
  
  def real_declaration
    #declaration_turns.times do
    catch(:end) do
    loop do
      @players.each do |p|
        p.declare(self)
        dec_target = []
        print_s "#{p.id}: #{p.declaration}\n"
      end
      print_s "\n"
      #if @declarations.size == 1
        #@target = @declarations.first.target
        ans = ''
        while (ans != 'n')
          @players.each do |p|
            print_s "#{p.id}: #{p.declaration} "
          end
          print_s "\n"
          @players.each do |p|
            ans = p.confirm(self.declarations) if p.brain == 'human'
          end
          if ans == 'y' || ans == ''
            throw(:end)
          elsif ans == 'n'
          else
            redo
          end
        end
      end
    end
  end
 
  def election
    targets = []
    highest_suits = Hash.new
    new_players = []
    @napo_id = 0
        
    if @declarations.size == 0
      pids = []
      1.upto @players.size do |pid|
        pids << pid
      end
      pids = pids.sort_by{rand}
      @napo_id = pids.first
      forced_napo = @players[@napo_id - 1]      
      max_value = forced_napo.strength_of_suits.values.max
      max_suit = forced_napo.strength_of_suits.index(max_value)
      #max_suit = psuedo_napo.strength_of_suits.index(max_value)
      # Hash#.index obsolute in 1.9.0
      forced_napo.declaration = "#{max_suit}#{@target}"
      @declarations[forced_napo.id] = forced_napo.declaration
    end
    
    @declarations.values.each do |d|
      targets << d.target
    end
    
    @declarations.values.each do |d|
      if d.target == targets.max
        highest_suits["#{d.suit}"] = d.suit.order
      end
    end
    
    # Hash#index obsolute in 1.9.0
    @obverse = highest_suits.index(highest_suits.values.max)
    
    @target = targets.max
    
    napo = NapoCPU.new
    
    @players.each do |p|
      if p.brain == 'human'
        if p.declaration == "#{@obverse}#{@target}"
          p.role = 'napoleon'
          @napo_id = p.id
          @winner_id = p.id
          new_players[p.id - 1] = p
          break
        end
      elsif p.brain == 'cpu'
        if p.declaration == "#{@obverse}#{@target}"
          napo.role = 'napoleon'
          napo.cards = p.cards
          napo.id = p.id
          @napo_id = napo.id
          @winner_id = napo.id
          new_players[napo.id - 1] = napo
          break
        end
      end
    end
    
    @players.each do |p|
      if p.brain == 'cpu'
        new_players[p.id - 1] = p if p.id != @napo_id
      elsif p.brain == 'human'
        new_players[p.id - 1] = p if p.id != @napo_id
      end
    end
    
    @players = new_players
       
  end
  
  def assign_lieut
    @lieut = ''
    @lieut_id = 0
    new_players = []
    
    @players.each do |p|
      if p.role == 'napoleon'
        @lieut = p.assign_lieut(@obverse)
      end
    end
    
    lieut_p = LieutCPU.new   
    @players.each do |p|
      if p.human?
        new_players << p
      elsif !p.human?
        if p.cards.include?(@lieut)
          lieut_p.id = p.id
          lieut_p.role = 'lieut'
          lieut_p.cards = p.cards
          new_players << lieut_p
        elsif p.role == 'napoleon'
          new_players << p
        elsif p.role == 'coalition'
          coal_p = CoalCPU.new
          coal_p.id = p.id
          coal_p.role = 'coalition'
          coal_p.cards = p.cards
          new_players << coal_p
        end
      end
    end
    @players.clear
    @players = new_players
  end
 
  def napoleon?(player_id)
    if @players[player_id-1].role == 'napoleon'
      true
    else
      false
    end
  end
 
  def lieut?(player_id)
    if @players[player_id-1].role == 'lieut'
      true
    else
      false
    end
  end
 
  def coalition?(player_id)
    if @players[player_id-1].role == 'coalition'
      true
    else
      false
    end
  end
 
  def gotten?(target_card)
    if @all_gotten_picts.find{|card| card == target_card}
      true
    else
      false
    end
  end
  
  def play
    last_turn = 0
    this_card = ''
    
    case @players.size
    when 4
      last_turn = 12
    when 5
      last_turn = 10
    when 6
      last_turn = 8
    end
    
    1.upto last_turn do |turn_id|
      @turn_id = turn_id
      
      print_s "| Turn: #{@turn_id} | "
      print_s "Obverse: Spade | " if @obverse == 's'
      print_s "Obverse: Heart | " if @obverse == 'h'
      print_s "Obverse: Diamonds | " if @obverse == 'd'
      print_s "Obverse: Club | " if @obverse == 'c'
      print_s "Target: #{@target} | "
      print_s "Lieut: #{@lieut} |\n\n"
      
      1.upto @players.size do |i|
        p_index = @winner_id + i - 2
        p_index = p_index - @players.size if p_index > @players.size - 1
        @first_card = this_card if i == 1
        @first_suit = this_card.suit if i == 1
        self.makes_facedown_cards
        this_card = @players[p_index].play(self)
        @faceup_cards[this_card] = p_index + 1
        print_s "#{p_index + 1}: "
        
        if this_card == '' || this_card == nil
          p_s @players[p_index].cards
        elsif this_card.suit == @first_suit || i == 1 
          print_s "#{this_card}"
        elsif this_card == 'Jo'
          print_s "#{this_card}"
        elsif @first_card == 'Jo'
          if this_card.suit == @obverse
            print_s "#{this_card}"
          elsif this_card.suit != @obverse
            print_s "# "
          end
        elsif this_card.suit != @first_suit
          print_s "# "
        else
          p_s @faceup_cards
        end

        print_s ' ('
        if @players[p_index].role == 'napoleon'
          print_s 'Napoleon'
        elsif @players[p_index].id == @lieut_id
          print_s 'Lieut'
        elsif @players[p_index].id != @lieut_id
          print_s 'Coalition'
        end
        print_s ')'
        print_s "\n"
        
        if i == 1
          @first_card = this_card
          @first_suit = this_card.suit
        end
      end
      
      print_s "\n"
      1.upto @players.size do |i|
        p_index = @winner_id + i - 2
        p_index = p_index - @players.size if p_index > @players.size - 1
        print_s "#{p_index + 1}: #{faceup_cards.index(p_index + 1)} "
        # Hash#index obsolute in 1.9.0
      end
      print_s "\n"
           
      self.judge
      @faceup_cards.clear
      @facedown_cards.clear
      print_s "\n"
      draw
    end
    
    if napo_win?
      p_s 'Napoleon Wins!!'
    elsif !napo_win? && @coals_picts.size == 0
      p_s 'Coalition Wins!!!'
      p_s 'Napoleon Gotten All picts!!'
    elsif !napo_win?
      p_s 'Coalition Wins!!!'
    end
    
    print_s "\n"
    
    @players.each do |p|
      print_s "#{p.role}: #{p.gotten_picts.size}\n"
    end
    
  end
  
  def makes_facedown_cards
    unopened = []
    @faceup_cards.each do |card, pid|
      unopened << card if card.suit == @first_suit
      unopened << '#' if card.suit != @first_suit
      unopened << pid
    end
    @facedown_cards = Hash[*unopened]  end
  
  def judge
    win_card = ''
    if @faceup_cards.keys.has_mighty?
      if @faceup_cards.keys.has_yoro?
        win_card = 'hQ'
        @winner_id = @faceup_cards[win_card]
        p_s 'Yoromeki hit!!'
#p "#Case 1"
      elsif !@faceup_cards.keys.has_yoro?
        win_card = 'sA'
        @winner_id = @faceup_cards[win_card]
        p_s 'Here\'s Mighty!'
#p "#Case 2"
      end
    elsif @faceup_cards.keys.has_obverse_jack?(@obverse)
      win_card = "#{@obverse}J"
      @winner_id = @faceup_cards[win_card]
        p_s 'Here\'s Obverse Jack!'
#p "#Case 3"
    elsif @faceup_cards.keys.has_reverse_jack?(@obverse)
      win_card = "#{@obverse.reverse}J"
      @winner_id = @faceup_cards[win_card]
        p_s 'Here\'s Reverse Jack!'
#p "#Case 4"
    elsif @first_card == 'Jo'
      if @turn_id != 1
        win_card = 'Jo'
        @winner_id = @faceup_cards[win_card]
        p_s 'Here\'s Joker!'
#p "#Case 5"
      elsif @turn_id == 1
        win_card = 
          @faceup_cards.keys.suit_cards(@obverse).max_value_card
        @winner_id = @faceup_cards[win_card]
        p_s  'Joker can\'t win at the first turn.'
#p "#Case 10"
      end
    elsif @faceup_cards.keys.suit_cards(@first_suit).size == @players.size
      if @faceup_cards.keys.has_two?
        if @turn_id != 1
          win_card = "#{@first_suit}2"
          @winner_id = @faceup_cards[win_card]
          p_s "Here\'s #{@first_suit}2!!"
#p "#Case 6"
        elsif @turn_id == 1
        win_card = 
          @faceup_cards.keys.suit_cards(@first_suit).max_value_card
          @winner_id = @faceup_cards[win_card]
          p_s "#{first_suit}2 can\'t win at the first turn."
#p "#Case 11"
        end
      elsif !@faceup_cards.keys.has_two?
          win_card = @faceup_cards.keys.max_value_card
          @winner_id = @faceup_cards[win_card]
#p "#Case 7"
#p "#Case 12"
      end
    elsif @faceup_cards.keys.suit_cards(@first_suit).size != @players.size
      if @faceup_cards.keys.has_suit?(@obverse)
        if @turn_id != 1
          win_card =
            @faceup_cards.keys.suit_cards(@obverse).max_value_card
          @winner_id = @faceup_cards[win_card]
#p "#Case 8"
        elsif @turn_id == 1
          win_card =
            @faceup_cards.keys.suit_cards(@first_suit).max_value_card
          @winner_id = @faceup_cards[win_card]
#p "#Case 13"
        end
      elsif !@faceup_cards.keys.has_suit?(@obverse)
        win_card =
          @faceup_cards.keys.suit_cards(@first_suit).max_value_card
          @winner_id = @faceup_cards[win_card]
#p "#Case 9"
#p "#Case 14"
      end
    end
    
    #if @faceup_cards.keys.include(@lieut)
      #p "Here\'s Lieut(#{@lieut})!!"
    #end
    
    @faceup_cards.keys.each do |c|
      @players[@winner_id-1].gotten_picts << c if c.pict?
      @all_gotten_picts << c if c.pict?
    end
    @players[@winner_id-1].gotten_picts.sort!.reverse!
    @all_gotten_picts.sort!.reverse!
    if napo_lose?
      p_s 'Napoleon lose!'
      print_s "\n"
      @players.each do |p|
        print_s "#{p.role}: #{p.gotten_picts.size}\n"
      end
      throw(:game_over)
    end    
  end
  
  def napo_win?
    @napos_picts = []
    @coals_picts = []
    @players.each do |p|
      @napos_picts.concat(p.gotten_picts) if p.role == 'napoleon'
      @napos_picts.concat(p.gotten_picts) if p.role == 'lieut'
      @coals_picts.concat(p.gotten_picts) if p.role == 'coalition'
    end
    if @coals_picts.size == 0
      return false
    elsif @napos_picts.size < @target
      return false
    elsif @napos_picts.size >= @target
      return true
    end
  end
 
  def napo_lose?
    @napos_picts = []
    @coals_picts = []
    @players.each do |p|
      @napos_picts.concat(p.gotten_picts) if p.role == 'napoleon'
      @napos_picts.concat(p.gotten_picts) if p.role == 'lieut'
      @coals_picts.concat(p.gotten_picts) if p.role == 'coalition'
    end
    
    if @coals_picts.size > 20 - @target
      return true
    elsif @coals_picts.size <= 20 - @target
      return false
    end
  end
  
end

class Player
  attr_accessor :id, :cards, :brain, :role, :declaration
  attr_accessor :gotten_picts
  def initialize
    @id = 0
    @role = "coalition"
    @cards = []
    @gotten_picts = []
  end
end

class HumanPlayer < Player
  
  def human?
    return true
  end
 
  def declare(table)
    t = table
    tds = t.declarations
    declaration = ''
    @cards.sort!.reverse!.each do |c|
      print_s "[#{c}]"
    end
    
    ans = ''
    catch(:last) do
    while(ans != 'n')
      print_s "\nDeclare?[y/n]\n"
      ans = STDIN.gets.chomp!
      ans.downcase!
      case ans
      when 'y'
        suits = ['s', 'h', 'd', 'c']
        suit_targets = Hash.new
        
        suits.each do |s|
          suit_targets[s] = t.target
        end
      
        tds.values.each do |td|
          suits.each do |s|
            if td.target >= suit_targets[s]
              if s.order > td.suit.order
                suit_targets[s] = td.target
              elsif s.order <= td.suit.order
                suit_targets[s] = td.target + 1
              end
            end
          end
        end
        
        if suit_targets.values.uniq.size == 1
          throw(:last) if suit_targets.values.uniq.first == 20
        end
        
        while (declaration == '')
          print_s "Which suit?/How many?\n"
          declaration_candidates = Hash.new
          suit_targets.keys.sort.reverse.each do |s|
            print_s "[#{s}#{suit_targets[s]}] "
            declaration_candidates[s] = suit_targets[s]
          end
          print_s "?\n"
          
          declaration = STDIN.gets.chomp! 
          
          if suits.include?(declaration.suit) && declaration.size == 3
            if declaration.target >= declaration_candidates[declaration.suit]
              if declaration.target <= 19
                @declaration = declaration
                #table.declarations << @declaration if @declaration != ''
                tds[self.id] = self.declaration if @declaration != ''
                break
              elsif declaration.target > 19
                redo
              end
            end
          else
            redo
          end
        end
        break
      when 'n'
        throw(:last)
      else
        redo
      end
    end
    end
  end
  
  def confirm(table_declarations)
    ans = ''
    loop do 
      print_s "\nOK?[y/n]\n"
      ans = STDIN.gets.chomp!
      ans.downcase!
      break if ans == 'y' || ans == 'n'
    end
    return 'y' if ans == 'y'
    return 'n' if ans == 'n'
  end
  
  def assign_lieut(table_obverse)
    dt = Table.new(0,4)
    dt.shuffle
    to = table_obverse
    print_s "Obverse: Spade\n" if to == 's'
    print_s "Obverse: Heart\n" if to == 'h'
    print_s "Obverse: Diamonds\n" if to == 'd'
    print_s "Obverse: Club\n" if to == 'c'
    @cards.sort!.reverse!.each do |c|
      print_s "[#{c}]"
    end
    
    lieut = ''
    while (!dt.all_cards.include?(lieut))
      print_s "\nWhich card is the best for the lieut?\n"
      lieut = STDIN.gets.chomp!
      if lieut != ''
        lieut = lieut.normalize
      elsif lieut == nil
        redo
      end
    end
    return lieut
  end
  
  def exchange(table)
    t = table
    ans = 'y'
    catch(:last) do 
      while(ans != 'n')
        print_s "Obverse: Spade\n" if t.obverse == 's'
        print_s "Obverse: Heart\n" if t.obverse == 'h'
        print_s "Obverse: Diamonds\n" if t.obverse == 'd'
        print_s "Obverse: Club\n" if t.obverse == 'c'
        print_s "\nYour cards:\n"
        @cards.sort!.reverse!.each do |c|
          print_s "[#{c}]"
        end
        print_s "\nTable mount cards:\n"
        table.mount_cards.sort!.reverse!.each do |c|
          print_s "[#{c}]"
        end
        print_s "\nExchange?[y/n]\n"
        ans = STDIN.gets.chomp!
        ans.downcase!
        case ans
        when 'y'
          print_s "Which card from the mount cards?\n"
          table.mount_cards.sort!.reverse!.each do |c|
            print_s "[#{c}]"
          end
          print_s "\n"
          card1 = STDIN.gets.chomp!
          if card1 != ''
            card1 = card1.normalize
          else 
            redo
          end
          
          if table.mount_cards.include?(card1)
            print_s "Which card from your cards?\n"
            @cards.sort!.reverse!.each do |c|
            print_s "[#{c}]"
          end
          print_s "\n"
            card2 = STDIN.gets.chomp!
            if card2 != ''
              card2 = card2.normalize
            else 
              redo
            end
            if @cards.include?(card2)
              table.mount_cards.delete(card1)
              @cards.delete(card2)
              @cards << card1
              table.mount_cards << card2
            else
            end
          end
        when 'n'
          throw(:last)
        else
          redo
        end
      end
    end
  end
 
  def play(table)
    this_card = ''
    print_s "------------------------------------------------\n"
    while(this_card == '')
      if @role == 'napoleon'
        print_s 'Your cards (Napoleon):'
      elsif @cards.has?(table.lieut)
        print_s 'Your cards (Lieut):' 
        @role = 'lieut'
      elsif @role == 'coalition'
        print_s 'Your cards (Coalition):' 
      end
      print_s "\n"
      @cards.sort!.reverse!.each do |c|
       print_s "[#{c}]"
      end
      print_s "\nWhich card from your cards?\n"
      raw_card = STDIN.gets.chomp!
      
      card = raw_card.suit.downcase + raw_card.number.downcase
      
      
      if card != ''
        card = card.normalize
      else 
        redo
      end
      
      if @cards.include?(card)
        @cards.delete(card)
        this_card = card
        print_s "------------------------------------------------\n"
      else
      end
    end
    return this_card
  end
  
end

class CPUPlayer < Player
  attr_accessor :total_value, :suit_card
  attr_accessor :jacks, :candidate_suits
  attr_accessor :num_of_suits, :strength_of_suits
  
  def human?
    return false
  end
 
  def prepare
    @jacks = []
    @suit_card = Hash.new
    @num_of_suits = Hash.new
    @candidate_suits = []
    @strength_of_suits = Hash.new
    suits = ['s', 'h', 'd', 'c']
    
    suits.each do |s|
      @suit_card["#{s}"] = []
    end
    
    @cards.each do |c|
      if c == 'Jo'
        suits.each do |s|
          @suit_card["#{s}"] << 'Jo'
        end
      else
        @suit_card["#{c.suit}"] << c 
      end
    end
 
    suits.each do |s|
      @num_of_suits["#{s}"] = @suit_card["#{s}"].size
    end
 
    suits.each do |s|
      @strength_of_suits["#{s}"] = 0
      @suit_card["#{s}"].each do |c|
        @strength_of_suits["#{s}"] += c.value 
      end 
    end
 
    @num_of_suits.each do |suit, number|
      if number == @num_of_suits.values.max
        @candidate_suits << suit
      end
    end
       
    @suit_card.each do |suit, card|
      card.each do |c|
        jack = "#{suit}" + 'J'
        @jacks << c if c == jack
      end
    end
  end
  
  def candidate_suits_choice
       
    case @jacks.size
    when 0
    when 1
      @candidate_suits << @jacks.first.suit
    when 2
      @candidate_suits << @jacks.first.suit
      @candidate_suits << @jacks.last.suit
    when 3
      @jacks.each do |j|
        @candidate_suits << j.suit
      end
    else
      @jacks.each do |j|
        @candidate_suits << j.suit
      end
    end
    @candidate_suits.sort!.reverse!.uniq! 
  end
  
  def pseudo_declare(table_declarations)
    
    case @cards.size
    when 12 # When 4 players
      target = 13
    when 10 # When 5 players
      target = 12
    when 8  # When 6 players
      target = 11
    else
    end
    case @candidate_suits.size
    when 1
      table_declarations.values.each do |dec|
        if target >= dec.target
          @declaration = @candidate_suits.first + target.to_s
        else
        end
      end
    when 2
      suit_1 = @candidate_suits.first
      suit_2 = @candidate_suits.last
      if suit_1.reverse == suit_2
        if @num_of_suits[suit_1] == @num_of_suits.values.max
          @declaration = suit_1 + target.to_s
        else
          @declaration = suit_2 + target.to_s
        end
      else
        if @num_of_suits[suit_1] == @num_of_suits.values.max
          @declaration = suit_1 + target.to_s
        else
          @declaration = suit_2 + target.to_s
        end
      end
    when 3
      suit_1 = ''
      suit_2 = ''
      @candidate_suits.each do |s|
        if @candidate_suits.find{|suit| suit == s}
          suit_1 = s
          suit_2 = s.reverse
          break
        end
      end
      if @num_of_suits[suit_1] == @num_of_suits.values.max
        @declaration = suit_1 + target.to_s
      else
        @declaration = suit_2 + target.to_s
      end
    when 4
      @candidate_suits.each do |s|
        if @num_of_suits[s] == @num_of_suits.values.max
          @declaration = s + target.to_s
          break
        end
      end
    else
  end
  
  end
  
  def compare_target(table_declarations)
    d = @declaration
    ns = @num_of_suits
    ss = @strength_of_suits
    case @cards.size
    when 12 # When 4 players
      table_declarations.values.each do |td|
        if d.target == td.target
          
          if d.suit.order > td.suit.order
          elsif d.suit.order <= td.suit.order
            if @cards.include?("#{d.suit}" + 'J')
              if @cards.include?("#{d.suit.reverse}" + 'J')
                d = d.plus_1
              elsif @cards.include?('sA')
                d = d.plus_1
              else
              end
            elsif @cards.include?("#{d.suit.reverse}" + 'J')
              if ns["#{d.suit}"] > 4
                d = d.plus_1
              elsif ss["#{d.suit}"] > 25
                d = d.plus_1
              else
              end
            elsif @cards.include?('sA')
              if ns["#{d.suit}"] > 4
                d = d.plus_1
              elsif ss["#{d.suit}"] > 20
                d = d.plus_1
              else
              end
            else
              if ns["#{d.suit}"] > 3
                d = d.plus_1
              elsif ss["#{d.suit}"] > 20
                d = d.plus_1
              else
              end
            end
          elsif d.suit.order > td.suit.order
          else
          end
        
        elsif d.target < td.target && ns != nil && ss != nil
          if d.suit.order > td.suit.order
          elsif d.suit.order <= td.suit.order
            if @cards.include?("#{d.suit}" + 'J')
              if @cards.include?("#{d.suit.reverse}" + 'J')
                d = d.plus_2
              elsif @cards.include?('sA')
                d = d.plus_2
              else
              end
            elsif ns["#{d.suit}"] != nil && ss["#{d.suit}"] != nil
              if @cards.include?("#{d.suit.reverse}" + 'J')
                if ns["#{d.suit}"] > 3
                  d = d.plus_2
                elsif ss["#{d.suit}"] > 20
                  d = d.plus_2
                else
                end
              elsif @cards.include?('sA')
                if ns["#{d.suit}"] > 2
                  d = d.plus_2
                elsif ss["#{d.suit}"] > 15
                  d = d.plus_2
                else
                end
              else
                if ns["#{d.suit}"] > 3
                  d = d.plus_2
                elsif ss["#{d.suit}"] > 20
                  d = d.plus_2
                else
                end
              end
            end
          #elsif d.suit.order > td.suit.order
          else
          end
        
        elsif d.target > td.target
        else
        end
      end
    when 10 # When 5 players
    when 8 # When 6 players
    else
    end
    @declaration = d
  end
  
  def declare(table)
    @declaration = ''
    table_declarations = table.declarations
    self.prepare
    self.candidate_suits_choice
    self.pseudo_declare(table_declarations)
    
    self.compare_target(table_declarations)
    
    table.declarations[self.id] = self.declaration
    
  end
  
  def confirm(table_declarations)
    return 'y'
  end
  
  def assign_lieut(table_obverse)
    lieut_card = ''
    o = table_obverse
    r = o.reverse
    suits = ['s', 'h', 'd', 'c']
    normal_suit = (suits - ["#{o}"])
    n1 = normal_suit[0]
    n2 = normal_suit[1]
    n3 = normal_suit[2]
    
    
    if !@cards.include?('sA')
      lieut_card = 'sA'
    elsif !@cards.include?("#{o}J")
      lieut_card = "#{o}J"
    elsif !@cards.include?("#{r}J")
      lieut_card = "#{r}J"
    elsif !@cards.include?("#{o}A")
      lieut_card = "#{o}A"
    elsif !@cards.include?('sK') && o == 's'
      lieut_card = 'sK'
    elsif !@cards.include?("#{n1}A") && o != 's' && n1 != r
      lieut_card = "#{n1}A"
    elsif !@cards.include?("#{n2}A") && o != 's' && n1 != r
      lieut_card = "#{n2}A"
    elsif !@cards.include?("#{o}A") && !@cards.include?("#{r}A")
      lieut_card = "#{n3}A"
    elsif !@cards.include?("#{o}K")
      lieut_card = "#{o}K"
    elsif !@cards.include?("#{o}Q")
      lieut_card = "#{o}Q"
    elsif !@cards.include?("Jo")
      lieut_card = "Jo"
    elsif !@cards.include?("#{o}2")
      lieut_card = "#{o}2"
    elsif !@cards.include?("#{o}0")
      lieut_card = "#{o}0"
    #elsif !@cards.include?("#{n3}A") && o != "s" && n1 != r
    else
      lieut_candidates = []
      3.upto 9 do |n|
        lieut_candidates << ("#{o}" + n.to_s)
      end
      lieut_candidates.map! do |lc|
        lc unless @cards.include?("#{lc}")
      end
      lieut_card = lieut_candidates.max
    end
    return lieut_card
  end
  
  def exchange(table)
    new_cards = []
    all_cards = []
    t = table
    
    all_cards = @cards.concat(table.mount_cards)
    # Basic evaluation
    all_cards.each do |c|
      if c == 'sA'
        new_cards << c
      elsif c == "#{table.obverse}J"
        new_cards << c
      elsif c == "#{table.obverse.reverse}J"
        new_cards << c
      elsif c.suit == table.obverse
        new_cards << c
      elsif c.number == 'A' || c.number == 'K'
        new_cards << c
      elsif c.number == 'Q' || c.number == 'J'
        new_cards << c
      elsif c.number == 'o' || c.number == '0'
        new_cards << c
      elsif c.number == '2'
        new_cards << c
      end
    end
    t.mount_cards.clear
    t.mount_cards = all_cards - new_cards
    
    if t.mount_cards.size == t.mount_cards_size
        @cards = new_cards
    end
    
    while(t.mount_cards.size != t.mount_cards_size) 
      if t.mount_cards.size < t.mount_cards_size 
        new_cards.reject! do |nc|
          nc.suit != table.obverse
          nc.pict? == false
          nc != 'sA'
          nc != "#{table.obverse}J"
          nc != "#{table.obverse.reverse}J"
          nc.number != '2'
        end
        new_cards.compact!
        table.mount_cards = all_cards - new_cards
        @cards = new_cards
      elsif t.mount_cards.size > t.mount_cards_size 
        new_cards << table.mount_cards.max_value_card
        new_cards.compact!
        table.mount_cards = all_cards - new_cards
        @cards = new_cards
      elsif t.mount_cards.size == t.mount_cards_size 
        table.mount_cards = all_cards - new_cards
        @cards = new_cards
        break
      end
    end
    
    if @cards.size != t.player_cards_size
      p 'Player Cards size is strange!!'
      p @cards, t.mount_cards
    end
    
  end
 
  def last_player?(table)
    if table.facedown_cards.size == table.players.size - 1
      true
    else
      false
    end
  end
 
  def play(table)
    this_card = ''
    t = table
    tf = t.first_suit
    if t.facedown_cards.size == 0 #first play
      this_card = first_play(t)
    elsif t.facedown_cards.size == (t.players.size-1) #last play
      if @cards.has_suit?(tf)
        if t.facedown_cards.keys.full_open?
          this_card = last_play_full_open_w_tf t
        elsif !t.facedown_cards.keys.full_open?
          this_card = last_play_not_full_open_w_tf t
        end
      elsif !@cards.has_suit?(tf)
        if t.facedown_cards.keys.full_open?
          this_card = last_play_full_open_wo_tf t
        elsif !t.facedown_cards.keys.full_open?
          this_card = last_play_not_full_open_wo_tf t
        end
      end
    else #middle play
      this_card = middle_play t
    end
    t.lieut_id = @id if this_card == t.lieut
    @cards.delete(this_card)
    return this_card
  end
  
  def first_play(table)
    this_card = ''
    t = table
    this_card = @cards.min_value_card
    if this_card == 'Jo'
      t.first_card = 'Jo'
      t.first_suit = t.obverse
    elsif this_card != 'Jo'
      t.first_card = this_card
      t.first_suit = this_card.suit
    end
    return this_card
  end
 
  def middle_play(table)
    this_card = ''
    t = table
    tf = t.first_suit
    if @cards.suit_cards(tf).size != 0
      if t.facedown_cards.keys.has_pict?
        this_card = mp_w_tf_seeing_pict t
      elsif !t.facedown_cards.keys.has_pict?
        this_card = mp_w_tf_wo_seeing_pict(t)
      end
    elsif @cards.suit_cards(tf).size == 0
      if t.facedown_cards.keys.has_pict?
        this_card = mp_wo_tf_seeing_pict t
      elsif !t.facedown_cards.keys.has_pict?
        this_card = mp_wo_tf_wo_seeing_pict(t)
      end
    end
    return this_card
  end
  
  def mp_wo_tf_seeing_pict(t)
    to = t.obverse
    if t.turn_id == 1
      if @cards.minnows(to).size == 0
        this_card =
          @cards.except_two_and_joker.min_value_card
        this_card = @cards.min_value_card if this_card == nil
      elsif @cards.minnows(to).size != 0
        this_card =
          @cards.minnows(to).except_two_and_joker.min_value_card
        this_card = @cards.minnows(to).min_value_card if this_card == nil
      end
#   Napo dosen't middle play at the first turn
    elsif t.turn_id !=1
      if @cards.obverse_cards(to).size == 0
        this_card =
          @cards.except_two_and_joker.min_value_card
        this_card = @cards.min_value_card if this_card == nil
      elsif @cards.obverse_cards(to).size != 0
        this_card = @cards.obverse_cards(to).max_value_card
      end
    end
    return this_card
  end
  
  def mp_wo_tf_wo_seeing_pict(t)
    to = t.obverse
    if t.turn_id == 1
      if @cards.minnows(to).size == 0
        this_card =
          @cards.except_two_and_joker.min_value_card
        this_card = @cards.min_value_card if this_card == nil
      elsif @cards.minnows(to).size != 0
        this_card =
          @cards.minnows(to).except_two_and_joker.min_value_card
        this_card = @cards.minnows(to).min_value_card if this_card == nil
      end
#     this_card = @cards.max_value_card
#   Napo dosen't middle play at the first turn
    elsif t.turn_id !=1
      if @cards.obverse_cards(to).size == 0
        this_card = @cards.min_value_card
      elsif @cards.obverse_cards(to).size != 0
        this_card = @cards.obverse_cards(to).max_value_card
      end
    end
    return this_card
  end
  
  def mp_w_tf_seeing_pict(t)
    to = t.obverse
    tf = t.first_suit
    if t.turn_id == 1
      this_card =
        @cards.except_two_and_joker.min_value_card
      this_card = @cards.min_value_card if this_card == nil
#   Napo dosen't middle play at the first turn
    elsif t.turn_id !=1
      if @cards.suit_cards(tf).has_two?
        this_card = "#{tf}2"
      elsif @cards.suit_cards(tf).has_obverse_jack?(to)
        this_card = "#{to}J"
      elsif @cards.suit_cards(tf).has_reverse_jack?(to)
        this_card = "#{to.reverse}J"
      elsif tf == to
        this_card = @cards.suit_cards(tf).min_value_card
      elsif tf != to
        this_card = @cards.suit_cards(tf).min_value_card
      end
    end
    return this_card
  end
  
  def mp_w_tf_wo_seeing_pict(t)
    to = t.obverse
    tf = t.first_suit
    if t.turn_id == 1
      this_card =
        @cards.except_two_and_joker.min_value_card
      this_card = @cards.min_value_card if this_card == nil
#   Napo dosen't middle play at the first turn
    elsif t.turn_id !=1
      if @cards.suit_cards(tf).has_two?
        this_card = "#{tf}2"
      elsif @cards.suit_cards(tf).has_obverse_jack?(to)
        this_card = "#{to}J"
      elsif @cards.suit_cards(tf).has_reverse_jack?(to)
        this_card = "#{to.reverse}J"
      elsif tf == to
        this_card = @cards.suit_cards(tf).min_value_card
      elsif tf != to
        this_card = @cards.suit_cards(tf).min_value_card
      end
    end
    return this_card
  end
   
  def last_play_full_open_wo_tf(table)
    this_card = ''
    t = table
    if t.facedown_cards.keys.has_pict?
      this_card = lp_fo_wo_tf_seeing_pict(t)
    elsif !t.facedown_cards.keys.has_pict?
      this_card = lp_fo_wo_tf_wo_seeing_pict(t)
    end
    return this_card
  end
 
  def lp_fo_wo_tf_wo_seeing_pict(table)
    this_card = ''
    to = table.obverse
    if @cards.size == 1
      this_card = @cards.last
    elsif @cards.has_not_obverse?(to)
      if @cards.not_obverse_cards(to).has_pict?
        this_card = 
          @cards.not_obverse_cards(to).min_value_card
#p "#Case 1-1"
      elsif !@cards.not_obverse_cards(to).has_pict?
        this_card = 
          @cards.not_obverse_cards(to).min_value_card
#p "#Case 1-2"
      end
    elsif !@cards.has_not_obverse?(to)
      if @cards.has_mighty?
        this_card = 'sA'
#p "#Case 1-3"
      elsif !@cards.has_mighty?
        this_card = 
          @cards.except_two_and_joker.min_value_card
#p "#Case 1-4"
      end
    end
    this_card = @cards.min_value_card if this_card == nil
    return this_card
  end
 
  def lp_fo_wo_tf_seeing_pict(table)
    this_card = ''
    t = table
    to = table.obverse
    if @cards.size == 1
      this_card = @cards.last
    elsif @cards.has_mighty?
      this_card = 'sA'
#p "#Case 1-5"
    elsif !@cards.has_mighty?
      if @cards.has_obverse?(to)
        if @cards.obverse_cards(to).has_pict?
          this_card = 
            @cards.obverse_cards(to).pict_cards.min_value_card
#p "#Case 1-6"
        elsif !@cards.obverse_cards(to).has_pict?
          this_card = 
            @cards.obverse_cards(to).max_value_card
#p "#Case 1-7"
        end
      elsif !@cards.has_obverse?(to)
        if @cards.has_reverse_jack?(to)
          this_card = "#{t.obverse.reverse}J"
#p "#Case 1-8"
        elsif !@cards.has_reverse_jack?(to)
          top_card = t.facedown_cards.keys.max_value_card
          top_card_player = t.players[t.faceup_cards[top_card]-1]
          if top_card_player.role == 'lieut'
            this_card = 
              @cards.minnows(to).pict_cards.min_value_card
#p "#Case 1-9"
          elsif top_card_player.role != 'lieut'
            this_card = 
              @cards.minnows(to).min_value_card
#p "#Case 1-10"
#p "#Case 1-11"
          end
        end
      end
    end
    this_card = @cards.min_value_card if this_card == nil
    return this_card
  end
   
  def last_play_not_full_open_wo_tf(table)
    t = table
    to = t.obverse
    tf = t.first_suit
    if @cards.size == 1
      this_card = @cards.last
    elsif t.facedown_cards.keys.has_pict?
      if tf == to
        top_card = t.facedown_cards.keys.max_value_card
        top_card_player = t.players[t.faceup_cards[top_card]-1]
        if top_card_player.role == 'lieut'
          if @cards.minnows(to).size != 0
            if @cards.minnows(to).has_pict?
              this_card = 
                @cards.minnows(to).pict_cards.min_value_card
#p "#Case 1-11"
            elsif !@cards.minnows(to).has_pict?
              this_card = 
                @cards.minnows(to).min_value_card
#p "#Case 1-12"
            end
          elsif @cards.minnows(to).size == 0
            this_card = 
              @cards.min_value_card
          end
        elsif top_card_player.role != 'lieut'
          this_card = 
            @cards.minnows(to).min_value_card
#p "#Case 1-13"
        end
      elsif  tf != to
        if t.facedown_cards.keys.has_mighty?
          this_card = lp_not_fo_wo_tf_seeing_mighty table
        elsif !t.facedown_cards.keys.has_mighty?
          this_card = lp_not_fo_wo_tf_wo_seeing_mighty table
        end
      end
    elsif !t.facedown_cards.keys.has_pict?
      if @cards.minnows(to).size == 0
        if @cards.has_mighty?
          this_card = 'sA'
#p "#Case 1-28"
        elsif !@cards.has_mighty?
        this_card =
          @cards.except_two_and_joker.min_value_card
#p "#Case 1-14-1"
        this_card = @cards.min_value_card if this_card == nil
#p "#Case 1-14-2"
        end
      elsif @cards.minnows(to).size != 0
        this_card =
          @cards.minnows(to).min_value_card
#p "#Case 1-15"
      end
    end
    return this_card
  end
   
  def lp_not_fo_wo_tf_seeing_mighty(table)
    t = table
    to = t.obverse
    if @cards.size == 1
      this_card = @cards.last
    elsif @cards.minnows(to).size == 0
      if @cards.has_pict?
        this_card = 
          @cards.pict_cards.min_value_card
#p "#Case 1-16"
      elsif !@cards.has_pict?
        this_card = 
          @cards.except_two_and_joker.min_value_card
#p "#Case 1-17"
      end
    elsif @cards.minnows(to).size != 0
      minnows = @cards.minnows(to)
      if minnows.has_pict?
        this_card =
          minnows.pict_cards.min_value_card
#p "#Case 1-18"
      elsif !minnows.has_pict?
        this_card =
          minnows.min_value_card
#p "#Case 1-19"
      end
    end
    return this_card
  end
   
  def lp_not_fo_wo_tf_wo_seeing_mighty(table)
  t = table
  to = t.obverse
  if @cards.size == 1
    this_card = @cards.last
  elsif @cards.has_mighty?
    if t.facedown_cards.keys.has_yoro?
        this_card =
          @cards.obverse_cards(to).except('sA').max_value_card
        this_card =
          @cards.max_value_card if this_card == nil
          
#p "#Case 1-20"
    elsif !t.facedown_cards.keys.has_yoro?
      if t.gotten?('hQ')
          this_card = 'sA'
#p "#Case 1-21"
      elsif !t.gotten?('hQ')
        if @cards.has_obverse?(to)
          this_card =
            @cards.max_value_card
#p "#Case 1-22"
        elsif !@cards.has_obverse?(to)
          this_card = 'sA'
#p "#Case 1-23"
        end
      end
    end
  elsif @cards.has_obverse_jack?(to)
    this_card = "#{to}J"
#p "#Case 1-24"
  elsif @cards.has_reverse_jack?(to)
    this_card = "#{to.reverse}J"
#p "#Case 1-25"
  elsif @cards.has_obverse?(to)
    this_card =
      @cards.obverse_cards(to).max_value_card
#p "#Case 1-26"
  elsif !@cards.has_obverse?(to)
    this_card =
      @cards.except_two_and_joker.min_value_card
    this_card =
      @cards.min_value_card if this_card == nil
#p "#Case 1-27"
  end
     return this_card
  end
 
  def last_play_full_open_w_tf(table)
    this_card = ''
    t = table
    if @cards.size == 1
      this_card = @cards.last
    elsif t.facedown_cards.keys.has_pict?
      this_card = lp_fo_w_tf_w_seeing_pict t
    elsif !t.facedown_cards.keys.has_pict?
      this_card = lp_fo_w_tf_wo_seeing_pict t
    end
    return this_card
  end
 
  def lp_fo_w_tf_w_seeing_pict(t)
    this_card = ''
    tf = t.first_suit
    if @cards.size == 1
      this_card = @cards.last
    elsif t.facedown_cards.keys.has_mighty?
      if @cards.suit_cards(tf).has_pict?
        this_card = 
          @cards.suit_cards(tf).pict_cards.min_value_card
#p "#Case 1-28"
      elsif !@cards.suit_cards(tf).has_pict?
        this_card = 
          @cards.suit_cards(tf).except_two_and_joker.min_value_card
#p "#Case 1-49"
      end
    elsif t.facedown_cards.keys.has_obverse_jack?(tf)
        this_card = 
          @cards.suit_cards(tf).except_two_and_joker.min_value_card
    elsif t.facedown_cards.keys.has_reverse_jack?(tf)
        this_card = 
          @cards.suit_cards(tf).except_two_and_joker.min_value_card
    elsif t.facedown_cards.keys.max_value_card.value >= @cards.suit_cards(tf).max_value_card.value
        this_card = 
          @cards.suit_cards(tf).except_two_and_joker.min_value_card
    elsif t.facedown_cards.keys.max_value_card.value < @cards.suit_cards(tf).max_value_card.value
        this_card = 
          @cards.suit_cards(tf).max_value_card
    end
    
    if this_card == nil
      this_card = @cards.suit_cards(tf).first
    end
    
    return this_card
  end
  
  def lp_fo_w_tf_wo_seeing_pict(t)
    this_card = ''
    if t.first_card.joker? || t.facedown_cards.keys.has_two?
      this_card = 
        lp_fo_w_tf_wo_seeing_pict_w_2_Jo t
    elsif !(t.first_card.joker? && t.facedown_cards.keys.has_two?)
      this_card = 
        lp_fo_w_tf_wo_seeing_pict_wo_2_Jo t
    end
    return this_card
  end
    
  def lp_fo_w_tf_wo_seeing_pict_w_2_Jo(t)
    tf = t.first_suit
    p_with_two = t.players[t.facedown_cards["#{tf}2"]-1]
    if p_with_two.role == 'napoleon'
      this_card = 
        lp_fo_w_tf_wo_seeing_pict_w_2_Jo_by_napo t
    elsif p_with_two.role == 'lieut'
      this_card = 
        lp_fo_w_tf_wo_seeing_pict_w_2_Jo_by_lieut t
    elsif p_with_two.role == 'coalition'
      this_card = 
        lp_fo_w_tf_wo_seeing_pict_w_2_Jo_by_coal t
    end
    return this_card
  end
 
  def lp_fo_w_tf_wo_seeing_pict_w_2_Jo_by_napo(t)
    tf = t.first_suit
    if @cards.suit_cards(tf).has_pict?
      this_card = @cards.suit_cards(tf).pict_cards.min_value_card
    elsif !@cards.suit_cards(tf).has_pict?
      this_card = 
        @cards.suit_cards(tf).except_two_and_joker.min_value_card
      this_card = 
        @cards.suit_cards(tf).min_value_card if this_card == nil
    end
    return this_card
  end
  
  def lp_fo_w_tf_wo_seeing_pict_w_2_Jo_by_lieut(t)
    tf = t.first_suit
    if @cards.suit_cards(tf).has_pict?
      this_card = @cards.suit_cards(tf).pict_cards.min_value_card
#p "#Case 1-28"
    elsif !@cards.suit_cards(tf).has_pict?
      this_card = 
        @cards.suit_cards(tf).except_two_and_joker.min_value_card
      this_card = 
        @cards.suit_cards(tf).min_value_card if this_card == nil
#p "#Case 1-29"
    end
    return this_card
  end
  
  def lp_fo_w_tf_wo_seeing_pict_w_2_Jo_by_coal(t)
    tf = t.first_suit
    to = t.obverse  
    if @cards.suit_cards(tf).has_mighty? && !t.facedown_cards.keys.has_yoro?
      this_card = 'sA'
#p "#Case 1-30"
    elsif @cards.suit_cards(tf).has_obverse_jack?(to)
      this_card = "#{to}J"
#p "#Case 1-31"
    elsif @cards.suit_cards(tf).has_reverse_jack?(to)
      this_card = "#{to.reverse}J"
#p "#Case 1-32"
    elsif @cards.has_joker?
      if @cards.suit_cards(tf).size == @cards.suit_cards(tf).pict_cards.size
        this_card = "Jo"
#p "#Case 1-33"
      elsif @cards.suit_cards(tf).size > @cards.suit_cards(tf).pict_cards.size
        this_card = @cards.suit_cards(tf).min_value_card
#p "#Case 1-34"
      end
    elsif !@cards.has_joker?
      this_card = @cards.suit_cards(tf).min_value_card
#p "#Case 1-35"
    end
    return this_card
  end
  
  def lp_fo_w_tf_wo_seeing_pict_wo_2_Jo(t)
    tf = t.first_suit
    if @cards.suit_cards(tf).has_pict?
      this_card = @cards.suit_cards(tf).pict_cards.min_value_card
#p "#Case 1-36"
    elsif !@cards.suit_cards(tf).has_pict?
      this_card = 
        @cards.suit_cards(tf).except_two_and_joker.min_value_card
      this_card = 
        @cards.suit_cards(tf).min_value_card if this_card == nil
#p "#Case 1-37"
    end
    return this_card
  end
 
  def last_play_not_full_open_w_tf(table)
    this_card = ''
    t = table
    if t.facedown_cards.keys.has_pict?
      this_card = lp_not_fo_w_tf_w_seeing_pict t
    elsif !t.facedown_cards.keys.has_pict?
      this_card = lp_not_fo_w_tf_wo_seeing_pict t
    end
    return this_card
  end
  
  def lp_not_fo_w_tf_w_seeing_pict(table)
    this_card = ''
    t = table
    tf = t.first_suit
    this_card = @cards.suit_cards(tf).min_value_card
#p "#Case 1-38"
    return this_card
  end
  
  def lp_not_fo_w_tf_wo_seeing_pict(table)
    this_card = ''
    t = table
    tf = t.first_suit
    this_card = @cards.suit_cards(tf).max_value_card
#p "#Case 1-39"
    return this_card
  end
      
end

class NapoCPU < CPUPlayer
  def first_play(table) 
    this_card = ''
    t = table
    to = t.obverse
    if t.turn_id == 1
      if @cards.not_obverse_cards(to).has?('sK')
        this_card = 'sK'
      elsif @cards.not_obverse_cards(to).has?('hA')
        this_card = 'hA'
      elsif @cards.not_obverse_cards(to).has?('dA')
        this_card = 'dA'
      elsif @cards.not_obverse_cards(to).has?('cA')
        this_card = 'cA'
      else
        this_card =
          @cards.not_obverse_cards(to).except_two_and_joker.max_value_card
#p "#Case 0-1"
      end
    elsif t.turn_id != 1
      if @cards.has_two?
        if @cards.obverse_cards(to).has_two?
          this_card = "#{to}2"
#p "#Case 0-2"
        elsif @cards.has?('h2') && @cards.has?('hA')
          this_card = 'hA'
#p "#Case 0-3"
        elsif @cards.has?('h2')
          this_card = 'h2'
#p "#Case 0-4"
        elsif @cards.not_obverse_cards(to).has_two?
          this_card = @cards.not_obverse_cards(to).number_cards('2').first
#p "#Case 0-5"
        end
      elsif @cards.has_joker?
        this_card = 'Jo'
#p "#Case 0-6"
      else
        this_card = @cards.max_value_card
      end
    end
    if this_card == 'Jo'
      t.first_card = 'Jo'
      t.first_suit = t.obverse
    elsif this_card != 'Jo'
      t.first_card = this_card
      t.first_suit = this_card.suit
    end
    return this_card
  end
end

class LieutCPU < CPUPlayer
 
  def mp_w_tf_seeing_pict(t)
    to = t.obverse
    tf = t.first_suit
    max_card = t.facedown_cards.keys.max_value_card
#   max_p_id = t.facedown_cards[max_card]
    if t.turn_id == 1
#     if t.napoleon?(max_p_id)
        if max_card == "#{tf}A" || max_card == 'sK'
          this_card =
            @cards.suit_cards(tf).except_two_and_joker.min_value_card
          this_card = @cards.suit_cards(tf).min_value_card if this_card == nil
#p "#Case 2-1"
        elsif @cards.except('sA').has?("#{tf}A")
          this_card = "#{tf}A"
#p "#Case 2-2"
        elsif @cards.has?('sK') && tf == 's'
          this_card = 'sK'
#p "#Case 2-3"
        elsif @cards.has?("#{tf}J") && tf == to.reverse
          this_card = "#{tf}J"
#p "#Case 2-4"
        elsif tf == to.reverse
          this_card =
            @cards.suit_cards(tf).except_two_and_joker.min_value_card
          this_card = @cards.suit_cards(tf).min_value_card if this_card == nil
#p "#Case 2-5"
        elsif tf != to.reverse
          this_card =
            @cards.suit_cards(tf).except_two_and_joker.min_value_card
          this_card = @cards.suit_cards(tf).min_value_card if this_card == nil
        end
#     elsif !t.napoleon?(max_p_id)
#     p 'elsif !t.napoleon?(max_p_id)'
#p  "#Case 2-6"
#     end
    elsif t.turn_id !=1
      this_card =
        @cards.suit_cards(tf).except_two_and_joker.min_value_card
      this_card = @cards.suit_cards(tf).min_value_card if this_card == nil
    end
    return this_card
  end
  
  def mp_w_tf_wo_seeing_pict(t)
    tf = t.first_suit
    if t.turn_id == 1
      this_card = @cards.suit_cards(tf).max_value_card
    elsif t.turn_id !=1
      this_card = @cards.suit_cards(tf).max_value_card
    end
    return this_card
  end
 
  def lp_fo_wo_tf_seeing_pict(table)
#p 'def lp_fo_wo_tf_seeing_pict(table) for lieut'
    this_card = ''
    t = table
    to = table.obverse
    if @cards.size == 1
      this_card = @cards.last
    elsif @cards.has_obverse?(to)
      if @cards.obverse_cards(to).has_pict?
        this_card = 
          @cards.obverse_cards(to).pict_cards.min_value_card
      elsif !@cards.obverse_cards(to).has_pict?
        this_card = 
          @cards.obverse_cards(to).max_value_card
      end
    elsif !@cards.has_obverse?(to)
      if @cards.has_reverse_jack?(to)
        this_card = "#{t.obverse.reverse}J"
      elsif !@cards.has_reverse_jack?(to)
        if @cards.minnows(to).size != 0
          if @cards.minnows(to).has_pict?
            top_card = t.facedown_cards.keys.max_value_card
            top_card_player = t.players[t.faceup_cards[top_card]-1]
            if top_card_player.role == 'napoleon'
              this_card = 
                @cards.minnows(to).pict_cards.min_value_card
            elsif top_card_player.role != 'napoleon'
              this_card = 
                @cards.minnows(to).min_value_card
            end
          elsif !@cards.minnows(to).has_pict?
            this_card = 
              @cards.minnows(to).min_value_card
          end
        elsif @cards.minnows(to).size == 0
          this_card = @cards.min_value_card
        end
      end
    end
    return this_card
  end
     
  def last_play_not_full_open_wo_tf(table)
    t = table
    to = t.obverse
    tf = t.first_suit
    if @cards.size == 1
      this_card = @cards.last
    elsif t.facedown_cards.keys.has_pict?
      if tf == to
        top_card = t.facedown_cards.keys.max_value_card
        top_card_player = t.players[t.faceup_cards[top_card]-1]
        if top_card_player.role == 'napoleon'
          if @cards.minnows(to).size == 0
            if @cards.has_pict?
              this_card = 
                @cards.pict_cards.min_value_card
#p "#Case 1-11"
            elsif !@cards.has_pict?
              this_card = 
                @cards.min_value_card
#p "#Case 1-12"
            end
          elsif @cards.minnows(to).size != 0
            this_card = 
              @cards.minnows(to).min_value_card
          end
        elsif top_card_player.role != 'napoleon'
          this_card = 
            @cards.minnows(to).min_value_card
#p "#Case 1-13"
        end
      elsif  tf != to
        if t.facedown_cards.keys.has_mighty?
          this_card = lp_not_fo_wo_tf_seeing_mighty table
        elsif !t.facedown_cards.keys.has_mighty?
          this_card = lp_not_fo_wo_tf_wo_seeing_mighty table
        end
      end
    elsif !t.facedown_cards.keys.has_pict?
      if @cards.minnows(to).size == 0
        if @cards.has_mighty?
          this_card = 'sA'
#p "#Case 1-28"
        elsif !@cards.has_mighty?
        this_card =
          @cards.except_two_and_joker.min_value_card
#p "#Case 1-14-1"
        this_card = @cards.min_value_card if this_card == nil
#p "#Case 1-14-2"
        end
      elsif @cards.minnows(to).size != 0
        this_card =
          @cards.minnows(to).min_value_card
#p "#Case 1-15"
      end
    end
    return this_card
  end
  
end

class CoalCPU < CPUPlayer
 
  def mp_w_tf_seeing_pict(t)
    to = t.obverse
    tf = t.first_suit
    max_card = t.facedown_cards.keys.max_value_card
    max_p_id = t.facedown_cards[max_card]
    if t.turn_id == 1
      if t.napoleon?(max_p_id)
        if max_card == "#{tf}A" || max_card == 'sK'
          this_card =
            @cards.suit_cards(tf).except_two_and_joker.min_value_card
          this_card = @cards.suit_cards(tf).min_value_card if this_card == nil
#p "#Case 3-1"
        elsif @cards.except('sA').has?("#{tf}A")
          this_card = "#{tf}A"
#p "#Case 3-2"
        elsif @cards.has?('sK') && tf == 's'
          this_card = 'sK'
#p "#Case 3-3"
        elsif @cards.has?("#{tf}J") && tf == to.reverse
          this_card = "#{tf}J"
#p "#Case 3-4"
        elsif tf == to.reverse
          this_card =
            @cards.suit_cards(tf).except_two_and_joker.min_value_card
          this_card = @cards.suit_cards(tf).min_value_card if this_card == nil
#p "#Case 3-5"
        elsif tf != to.reverse
          this_card =
            @cards.suit_cards(tf).except_two_and_joker.min_value_card
          this_card = @cards.suit_cards(tf).min_value_card if this_card == nil
        end
      elsif !t.napoleon?(max_p_id)
        if @cards.except('sA').has?("#{tf}A")
          if max_card == "#{tf}J" && tf = to.reverse
          this_card =
            @cards.suit_cards(tf).except_two_and_joker.min_value_card
          this_card = @cards.suit_cards(tf).min_value_card if this_card == nil
#p  "#Case 3-6"
          elsif max_card != "#{tf}J" && tf = to.reverse
            this_card = "#{tf}A"
#p  "#Case 3-7"
          end
        elsif @cards.has?('sK') && tf == 's'
          this_card = 'sK'
#p  "#Case 3-8"
        elsif !@cards.except('sA').has?("#{tf}A")
          this_card =
            @cards.suit_cards(tf).except_two_and_joker.min_value_card
          this_card = @cards.suit_cards(tf).min_value_card if this_card == nil
#p  "#Case 3-9"
        end
      end
    elsif t.turn_id !=1
      this_card =
        @cards.suit_cards(tf).except_two_and_joker.min_value_card
      this_card = @cards.suit_cards(tf).min_value_card if this_card == nil
    end
    return this_card
  end
 
  def mp_w_tf_wo_seeing_pict(t)
    tf = t.first_suit
    if t.turn_id == 1
      this_card = @cards.suit_cards(tf).max_value_card
    elsif t.turn_id !=1
      this_card = @cards.suit_cards(tf).max_value_card
    end
    return this_card
  end
   
  def lp_fo_wo_tf_seeing_pict(table)
    this_card = ''
    t = table
    to = t.obverse
      if @cards.size == 1
        this_card = @cards.last
      elsif @cards.has_mighty?
        this_card = 'sA'
#p "#Case 3-5"
      elsif !@cards.has_mighty?
        if @cards.has_obverse?(to)
#p "#Case 3"
          if @cards.obverse_cards(to).has_pict?
            this_card = 
              @cards.obverse_cards(to).pict_cards.min_value_card
#p "#Case 3-6"
          elsif !@cards.obverse_cards(to).has_pict?
            this_card = 
              @cards.obverse_cards(to).max_value_card
#p "#Case 3-7"
          end
        elsif !@cards.has_obverse?(to)
          if @cards.has_reverse_jack?(to)
            this_card = "#{t.obverse.reverse}J"
#p "#Case 3-8"
          elsif !@cards.has_reverse_jack?(to)
            top_card = t.facedown_cards.keys.max_value_card
            top_card_player = t.players[t.faceup_cards[top_card]-1]
            if top_card_player.role == 'lieut'
              this_card = 
                @cards.minnows(to).pict_cards.min_value_card
#p "#Case 3-9"
            elsif top_card_player.role != 'lieut'
              this_card = 
                @cards.minnows(to).min_value_card
#p "#Case 3-10"
            end
          end
        end
      end
    return this_card
  end
 
  def lp_fo_wo_tf_seeing_pict(table)
    this_card = ''
    t = table
    to = table.obverse
    if @cards.size == 1
      this_card = @cards.last
    elsif @cards.has_obverse?(to)
      if @cards.obverse_cards(to).has_pict?
        this_card = 
          @cards.obverse_cards(to).pict_cards.min_value_card
      elsif !@cards.obverse_cards(to).has_pict?
        this_card = 
          @cards.obverse_cards(to).max_value_card
      end
    elsif !@cards.has_obverse?(to)
      if @cards.has_reverse_jack?(to)
        this_card = "#{t.obverse.reverse}J"
      elsif !@cards.has_reverse_jack?(to)
        if @cards.minnows(to).size != 0
          if @cards.minnows(to).has_pict?
            this_card = 
              @cards.minnows(to).pict_cards.min_value_card
          elsif !@cards.minnows(to).has_pict?
            this_card = 
              @cards.minnows(to).min_value_card
          end
        elsif @cards.minnows(to).size == 0
          this_card = @cards.min_value_card
        end
      end
    end
    return this_card
  end
  
  def lp_fo_wo_tf_seeing_pict(table)
    this_card = ''
    t = table
    to = table.obverse
      if @cards.size == 1
        this_card = @cards.last
      elsif @cards.has_mighty?
        this_card = 'sA'
      elsif !@cards.has_mighty?
        if @cards.has_obverse?(to)
          if @cards.obverse_cards(to).has_pict?
            this_card = 
              @cards.obverse_cards(to).pict_cards.min_value_card
          elsif !@cards.obverse_cards(to).has_pict?
            this_card = 
              @cards.obverse_cards(to).max_value_card
          end
        elsif !@cards.has_obverse?(to)
          if @cards.has_reverse_jack?(to)
            this_card = "#{t.obverse.reverse}J"
          elsif !@cards.has_reverse_jack?(to)
            top_card = t.facedown_cards.keys.max_value_card
            top_card_player = t.players[t.faceup_cards[top_card]-1]
            if top_card_player.role == 'lieut'
              this_card = 
                @cards.minnows(to).pict_cards.min_value_card
            elsif top_card_player.role != 'lieut'
              this_card = 
                @cards.minnows(to).min_value_card
            end
          end
        end
      end
    this_card = @cards.min_value_card if this_card == nil
    return this_card
  end
   
  def last_play_not_full_open_wo_tf(table)
    t = table
    to = t.obverse
    tf = t.first_suit
    if @cards.size == 1
      this_card = @cards.last
    elsif t.facedown_cards.keys.has_pict?
      if tf == to
        top_card = t.facedown_cards.keys.max_value_card
        top_card_player = t.players[t.faceup_cards[top_card]-1]
        if top_card_player.role == 'napoleon'
          this_card = @cards.min_value_card
        elsif top_card_player.role != 'napoleon'
          if top_card == t.lieut
            this_card = @cards.min_value_card 
          elsif top_card != t.lieut
            if @cards.has_pict?
              this_card = @cards.pict_cards.min_value_card
              this_card = @cards.min_value_card if this_card.yoro?
            elsif !@cards.has_pict?
              this_card = @cards.min_value_card 
            end
          end
        end
      elsif  tf != to
        if t.facedown_cards.keys.has_mighty?
          this_card = lp_not_fo_wo_tf_seeing_mighty table
        elsif !t.facedown_cards.keys.has_mighty?
          this_card = lp_not_fo_wo_tf_wo_seeing_mighty table
        end
      end
    elsif !t.facedown_cards.keys.has_pict?
      if @cards.minnows(to).size == 0
        if @cards.has_mighty?
          this_card = 'sA'
        elsif !@cards.has_mighty?
        this_card =
          @cards.except_two_and_joker.min_value_card
        this_card = @cards.min_value_card if this_card == nil
        end
      elsif @cards.minnows(to).size != 0
        this_card =
          @cards.minnows(to).min_value_card
      end
    end
    return this_card
  end
  
end
