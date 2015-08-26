require "./exception"

module Rofi
  class Dialog
    getter(
      choices,
      prompt,
      selected_row,
      lines,
      case_insensitive,
      active_rows,
      urgent_rows,
      message,
      fuzzy,
      key_bindings
    )

    def initialize(
      @choices = [] of String : Array(String),
      @prompt = nil : String?,
      @selected_row = nil : Int32?,
      @lines = nil : Int32?,
      @case_insensitive = false : Bool,
      @active_rows = nil : Array(Int32)?,
      @urgent_rows = nil : Array(Int32)?,
      @message = nil : String?,
      @fuzzy = false : Bool,
      @key_bindings = {} of String => Int32 : Hash(String, Int32)
    )
    end

    def show : { String?, Int32 }
      choice = nil
      error = nil
      Process.run("rofi", arguments) do |process|
        choices.each { |choice| process.input.puts(choice) }
        process.input.close
        choice = process.output.read.chomp
        error = process.error.read.chomp
      end

      exit_code = $?.exit_code
      key_code = 0
      case exit_code
      when 0 then
      when 1 then choice = nil
      when 10..18 then key_code = exit_code - 9
      else raise Exception.new("rofi error: #{error}")
      end

      { choice, key_code }
    end

    private def arguments : Array(String)
      result = [] of String
      {
        "-dmenu" => true,
        "-p" => "#{prompt} ",
        "-selected-row" => selected_row,
        "-l" => lines,
        "-i" => case_insensitive,
        "-a" => active_rows.try { |rows| rows.join(",") },
        "-u" => urgent_rows.try { |rows| rows.join(",") },
        "-mesg" => message,
        "-z" => fuzzy,
      }.each do |flag, value|
        next unless value
        result << flag
        case value
        when String then result << value
        when Int32 then result << value.to_s
        end
      end

      key_bindings.each do |binding, slot|
        result << "-kb-custom-#{slot}"
        result << binding
      end

      result
    end
  end
end
