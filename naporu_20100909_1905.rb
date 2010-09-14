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
java_import "android.graphics.drawable.GradientDrawable"
java_import "android.graphics.Color"
java_import "android.graphics.Paint"
java_import "android.graphics.RectF"
java_import "android.graphics.Canvas"
java_import "android.graphics.Bitmap"
java_import "android.graphics.Path"
java_import "android.hardware.SensorManager"
java_import "android.hardware.Sensor"
java_import "android.app.TimePickerDialog"
java_import "android.app.DatePickerDialog"
java_import "android.graphics.Typeface"
java_import "android.content.res.ColorStateList"

class RubotoActivity
  @@lists = {
#    :main      => %w(App Content Graphics Media OS Text Views),
    :main       => %w(App),
#    "App"       => ["Activity", "Alarm", "Dialog" "Intents", 
#                     "Launcher Shortcuts", "Menus", "Notification", 
#                     "Preferences", "Search", "Service", "Voice Recognition"],
    "App"       => ["Activity"],
    "Activity"  => ["Hello World"],
           
  }

  def self.resolve_click(context, title)
    if @@lists[title]
      RubotoActivity.launch_list context, "$sl_#{title.downcase.gsub(' ', '_')}", "Api Demos", title
    else
      case title
      when "Custom Dialog"         : custom_dialog(context)
      when "Custom Title"          : custom_title(context)
      when "Forwarding"            : forwarding(context)
      when "Hello World"           : hello_world(context)
      when "Persistent State"      : persistent_state(context)
      when "Save & Restore State"  : save_and_restore_state(context)
      when "Arcs"                  : arcs(context)
      when "Morse Code"            : morse_code(context)
      when "Sensors"               : sensors(context)
      when "Buttons"               : buttons(context)
      when "Chronometer"           : chronometer_demo(context)
      when "1. Dialog"             : date_dialog(context)
      when "2. Inline"             : date_inline(context)
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
  # Hello, World
  #

  def self.hello_world(context)
    context.start_ruboto_activity "$hello_world" do
      setTitle "App/Activity/Hello World"

      setup_content do
          text_view :text => "Hello, World!", 
            :gravity => (Gravity::CENTER_HORIZONTAL | Gravity::CENTER_VERTICAL)
      end
    end
  end
end

#######################################################
#
# Start
#

RubotoActivity.launch_list $activity, "$main_list", "Api Demos", :main,
  "This is a Ruboto demo that attempts to duplicate the standard Android API Demo using Ruboto. It is in the early stages (more samples will be completed in the future)."