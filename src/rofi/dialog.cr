require "./exception"
require "./matching_method"

module Rofi
  class Dialog
    getter choices : Array(String)
    getter prompt : String?
    getter selected_row : Int32?
    getter lines : Int32?
    getter case_insensitive : Bool = false
    getter active_rows : Array(Int32)?
    getter urgent_rows : Array(Int32)?
    getter message : String?
    getter matching_method : MatchingMethod = MatchingMethod::Normal
    getter key_bindings : Hash(String, Int32) = {} of String => Int32

    def initialize(@choices, **options : **T) forall T
      {% for key in T.keys %}
        @{{key}} = options[{{key.symbolize}}]
      {% end %}
    end

    def show : { String?, Int32 }
      choice = nil
      error = nil

      Process.run("rofi", arguments) do |process|
        choices.each { |choice| process.input.puts(choice) }
        process.input.close
        choice = process.output.gets_to_end.chomp
        error = process.error.gets_to_end.chomp
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
        "-matching" => matching_method,
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
