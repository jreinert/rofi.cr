require "../spec_helper"

describe Rofi::Dialog do
  describe "#run" do
    it "yields the expected choice" do
      dialog = Rofi::Dialog.new(%w(success), prompt: "hit enter")

      choice, key = dialog.show
      choice.should eq("success")
      key.should eq(0)
    end

    it "yields the expected key code" do
      dialog = Rofi::Dialog.new(%w(success), prompt: "hit alt+1")

      choice, key = dialog.show
      choice.should eq("success")
      key.should eq(1)
    end

    it "yields nil as choice if rofi is exited without selecting an item" do
      dialog = Rofi::Dialog.new(%w(success), prompt: "hit esc")

      choice, key = dialog.show
      choice.should be_nil
      key.should eq(0)
    end

    it "maps key bindings correctly" do
      dialog = Rofi::Dialog.new(
        %w(success),
        prompt: "hit alt+o",
        key_bindings: {
          "alt+o" => 3
        }
      )

      choice, key = dialog.show
      choice.should eq("success")
      key.should eq(3)
    end

    it "selects a specified row" do
      dialog = Rofi::Dialog.new(
        %w(first second),
        prompt: "hit enter",
        selected_row: 1
      )

      choice, key = dialog.show
      choice.should eq("second")
      key.should eq(0)
    end

    it "shows only the given amount of lines" do
      dialog = Rofi::Dialog.new(
        ["success", "", "hit enter if this is the last line", "hit esc"],
        prompt: "look down",
        lines: 3
      )

      choice, key = dialog.show
      choice.should eq("success")
      key.should eq(0)
    end

    it "matches case sensitively unless the option is set" do
      dialog = Rofi::Dialog.new(
        %w(Fail fSuccess),
        prompt: "type f and hit enter"
      )
      choice, key = dialog.show
      choice.should eq("fSuccess")
      key.should eq(0)

      dialog = Rofi::Dialog.new(
        %w(FSuccess),
        prompt: "type f and hit enter",
        case_insensitive: true
      )

      choice, key = dialog.show
      choice.should eq("FSuccess")
      key.should eq(0)
    end

    it "marks given rows as active" do
      dialog = Rofi::Dialog.new(
        [
          "success",
          "hit escape if this is also marked as active or if nothing is",
          "success"
        ],
        prompt: "Hit enter if the first and last entry is marked as active",
        active_rows: [0,2]
      )

      choice, key = dialog.show
      choice.should eq("success")
      key.should eq(0)
    end

    it "marks given rows as urgent" do
      dialog = Rofi::Dialog.new(
        [
          "success",
          "hit escape if this is also marked as active or if nothing is"
        ],
        prompt: "Hit enter if the first entry is marked as urgent",
        urgent_rows: [0]
      )

      choice, key = dialog.show
      choice.should eq("success")
      key.should eq(0)
    end

    it "shows a message if set" do
      dialog = Rofi::Dialog.new(
        %w(success),
        prompt: "look down, if you don't see a message, hit esc",
        message: "I'm a message. You can hit enter"
      )

      choice, key = dialog.show
      choice.should eq("success")
      key.should eq(0)
    end

    it "does fuzzy matching if specified" do
      dialog = Rofi::Dialog.new(
        %w(success/fail),
        prompt: "type 'sucail' and hit enter",
      )

      choice, key = dialog.show
      choice.should eq("sucail")
      key.should eq(0)

      dialog = Rofi::Dialog.new(
        %w(success/fail),
        prompt: "do it again",
        matching_method: Rofi::MatchingMethod::Fuzzy
      )

      choice, key = dialog.show
      choice.should eq("success/fail")
      key.should eq(0)
    end
  end
end
