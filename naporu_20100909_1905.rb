#######################################################
#
# hello.rb (by Takashi Fujiwara)
# 
# Just say hello
# 
#######################################################

require "ruboto.rb"
confirm_ruboto_version(4)

ruboto_import_widgets :LinearLayout, :TextView, :RelativeLayout,
  :TableLayout, :TableRow,
  :Chronometer, :DatePicker, :TimePicker, :EditText, :ToggleButton

java_import "android.os.SystemClock"
java_import "android.view.Window"
java_import "android.view.WindowManager"
java_import "android.view.Gravity"
java_import "android.content.Context"
java_import "android.util.AttributeSet"
java_import "android.content.res.ColorStateList"

class RubotoActivity
  @@lists = {
#    :main      => %w(App Content Graphics Media OS Text Views),
#    "App"       => ["Activity", "Alarm", "Dialog" "Intents", 
#                     "Launcher Shortcuts", "Menus", "Notification", 
#                     "Preferences", "Search", "Service", "Voice Recognition"],
    #:main       => %w(App),
    :main       => ["Naporoid"],
    #"App"       => ["Activity"],
    #"Activity"  => ["Naporoid"],
           
  }

  def self.resolve_click(context, title)
    if @@lists[title]
      RubotoActivity.launch_list context, "$sl_#{title.downcase.gsub(' ', '_')}", "Api Demos", title
    else
      case title
      when "Naporoid"              : naporoid(context)
      else
        context.toast "Not Implemented Yet"
      end
    end
  end

  def self.launch_list(context, var, title, list_id, extra_text=nil)
    context.start_ruboto_activity var do
      setTitle title
      setup_content do
        linear_layout :orientation => LinearLayout::VERTICAL do
          text_view(:text => extra_text) if extra_text
          list_view :list => @@lists[list_id]
        end
      end
      handle_item_click do |adapter_view, view, pos, item_id| 
        RubotoActivity.resolve_click self, view.getText
      end
    end
  end

  #######################################################
  #
  # App -> Activity
  #

  #
  # Naporoid
  #

  def self.naporoid(context)
    context.start_ruboto_activity "$naporoid" do
      requestWindowFeature Window::FEATURE_CUSTOM_TITLE

      setup_content do
        linear_layout :orientation => LinearLayout::VERTICAL do
          linear_layout do
            @etl = edit_text(:text => "Left is best", :min_ems => 10, :max_ems => 10)
            button :text => "Change left"
          end
          linear_layout do
            @etr = edit_text(:text => "Right is always right", :min_ems => 10, :max_ems => 10)
            button :text => "Change right"
          end
    		  #text_view :text => "#{@tvl.getText}", 
	        #:gravity => (Gravity::CENTER_HORIZONTAL | Gravity::CENTER_VERTICAL)
        end
      end

      handle_create do
        getWindow.setFeatureInt(Window::FEATURE_CUSTOM_TITLE, 
                                Ruboto::R::layout::empty_relative_layout)

        @rl = findViewById(Ruboto::Id::empty_relative_layout)
        @tvl = text_view :text => "Left is best", 
                         :text_color => ColorStateList.valueOf(0xFFFFFFFF),
                         :typeface => [Typeface::DEFAULT, Typeface::BOLD]
        @rl.addView @tvl
        @tvl.getLayoutParams.addRule RelativeLayout::ALIGN_PARENT_LEFT

        @tvr = text_view :text => "Right is always right", 
                         :text_color => ColorStateList.valueOf(0xFFFFFFFF),
                         :typeface => [Typeface::DEFAULT, Typeface::BOLD]
        @rl.addView @tvr
        @tvr.getLayoutParams.addRule RelativeLayout::ALIGN_PARENT_RIGHT
      end

      handle_click do |view|
        view.getText == "Change left" ? @tvl.setText(@etl.getText) : @tvr.setText(@etr.getText)
        #setup_content do
          #text_view :text => "#{@etl.getText}"
        #end
      end
      
    end
  end
end


#######################################################
#
# Start
#

RubotoActivity.launch_list $activity, "$main_list", "Api Demos", :main,
  "Napoleon implemented by Ruby on Andorid."