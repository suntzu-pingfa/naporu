#######################################################
#
# demo-ruboto.rb (by Scott Moyer)
# 
# A simple look at how to generate and 
# use a RubotoActivity.
#
#######################################################

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
  def self.my_click(card)
    card = @et.getText
    toast "#{@cards.size}"
    @cards.delete("#{card}")
    toast card
    toast "#{@cards.size}"
    #@tv.append "\n#{text}"
    my_cards =""
    @cards.each do |c|
      my_cards += "[#{c}]"
    end
    @tv.setText "\n#{my_cards}"
    #@tv.setText "\n#{text}"
  end
  
  def napo
    print "test"
    p "TEST"
  end
  
end

#######################################################
#
# demo-ruboto.rb (by Scott Moyer)
# 
# A simple look at how to generate and 
# use a RubotoActivity.
#
#######################################################

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
    input_card = @et.getText
    card = "#{input_card}"
    toast "#{@cards.size}"
    card = card.suit + card.number.upcase
    @cards.delete("#{card}")
    toast card
    toast "#{@cards.size}"
    #@tv.append "\n#{text}"
    my_cards =""
    @cards.each do |c|
      my_cards += "[#{c}]"
    end
    @tv.setText "\n#{my_cards}"
    #@tv.setText "\n#{text}"
  end

  def self.print(text)
    @tv.setText "#{text}"
  end

  def self.p(text)
    @tv.setText "#{text}\n"
  end
  
  def napo
    print "test"
    p "TEST"
  end
end
  
### Extentions for Napo ###

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