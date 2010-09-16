 linear_layout :orientation => LinearLayout::VERTICAL do
          linear_layout do
            @etl = edit_text(:text => "Left is best", :min_ems => 10, :max_ems => 10)
            button :text => "Change left"
          end
          linear_layout do
            @etr = edit_text(:text => "Right is always right", :min_ems => 10, :max_ems => 10)
            button :text => "Change right"
          end
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
      end