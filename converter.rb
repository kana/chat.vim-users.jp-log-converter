#!/usr/bin/env ruby

class Converter
  def parsed_line_from_raw_line(raw_line)
    parsed_line = {}

    /^(\d\d:\d\d:\d\d) (.)(.*)$/ =~ raw_line
    case Regexp.last_match 2
    when nil then
      raise RuntimeError, 'Invalid raw_line'
    when '+' then
      parsed_line[:type] = :join
    when '!' then
      parsed_line[:type] = :part
    when '<' then
      parsed_line[:type] = :msg
    else
      parsed_line[:type] = :nick
    end

    return parsed_line
  end

  def main()
    0
  end
end




if __FILE__ == $0
  exit Converter.new.main
end

__END__
