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
  $cards = %w[sK sJ s9 s8 h8 dA d4 d2 c8 c6 c5 c0]
  
  setup_content do
    linear_layout(:orientation => LinearLayout::VERTICAL) do
      linear_layout do
        $cards.each do |c|
          button :text => "#{c}", :width => :wrap_content
        end
      end
      @tv = text_view :text => "Click buttons or menu items:"
      #@et = edit_text
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
    toast text
    $cards.delete(text)
    setup_content do
      linear_layout(:orientation => LinearLayout::VERTICAL) do
        linear_layout do
          $cards.each do |c|
            button :text => "#{c}", :width => :wrap_content
          end
        end
        @tv = text_view :text => ""
        #@et = edit_text
      end
    end
    @tv.append "\n#{text}"
  end
  
end