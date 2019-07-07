require "./exception"
require "./matching_method"

module Rofi
  class Dialog(T)
    # Ugly hack to deal with rofi's lack of sanitized output
    FIELD_SEPARATOR = "#-#--#---#----#"

    record Result(T), selected_entry : T, input : String, key_code : Int32

    getter choices
    getter prompt : String?
    getter selected_row : Int32?
    getter lines : Int32?
    getter case_insensitive : Bool = false
    getter active_rows : Array(Int32)?
    getter urgent_rows : Array(Int32)?
    getter message : String?
    getter matching_method : MatchingMethod = MatchingMethod::Normal
    getter key_bindings : Hash(String, Int32) = {} of String => Int32
    getter no_custom : Bool = false
    getter only_match : Bool = false

    def initialize(@choices : Indexable(T), **options : **K) forall K
      {% for key in K.keys %}
        @{{key}} = options[{{key.symbolize}}]
      {% end %}
    end

    def show : Result(T?)?
      output = IO::Memory.new
      error = IO::Memory.new

      Process.run("rofi", arguments, output: output, error: error) do |process|
        choices.each { |choice| process.input.puts(choice) }
      end

      exit_code = $?.exit_code
      key_code = 0
      case exit_code
      when 0 then
      when 1 then return nil
      when 10..18 then key_code = exit_code - 9
      else raise Exception.new("rofi error: #{error.to_s}")
      end

      index, input = output.to_s.split(FIELD_SEPARATOR)
      index = index.to_i

      selected_entry = index >= 0 ? @choices[index]? : nil
      Result.new(selected_entry, input.chomp, key_code)
    end

    private def arguments : Array(String)
      result = [] of String
      {
        "-dmenu" => true,
        "-p" => prompt,
        "-selected-row" => selected_row,
        "-l" => lines,
        "-i" => case_insensitive,
        "-a" => active_rows.try { |rows| rows.join(",") },
        "-u" => urgent_rows.try { |rows| rows.join(",") },
        "-mesg" => message,
        "-matching" => matching_method,
        "-format" => "i#{FIELD_SEPARATOR}s",
        "-no-custom" => no_custom,
        "-only-match" => only_match,
      }.each do |flag, value|
        next unless value
        result << flag
        result << value.to_s
      end

      key_bindings.each do |binding, slot|
        result << "-kb-custom-#{slot}"
        result << binding
      end

      result
    end
  end
end
