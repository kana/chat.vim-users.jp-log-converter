#!/usr/bin/env ruby

class Converter
  def parsed_line_from_raw_line(raw_line)
    parsed_line = {}

    /^(\d\d:\d\d:\d\d) (.)(.*)$/ =~ raw_line
    parsed_line[:time] = Regexp.last_match 1

    case Regexp.last_match 2
    when nil then
      raise RuntimeError, 'Invalid raw_line'
    when '+' then
      /^\S+ \+ (\S+) / =~ raw_line
      parsed_line[:type] = :join
      parsed_line[:nick] = Regexp.last_match 1
    when '!' then
      /^\S+ ! (\S+) / =~ raw_line
      parsed_line[:type] = :part
      parsed_line[:nick] = Regexp.last_match 1
    when '<' then
      /^\S+ <\S+:(\S+)> (.*)$/ =~ raw_line
      parsed_line[:type] = :msg
      parsed_line[:nick] = Regexp.last_match 1
      parsed_line[:text] = Regexp.last_match 2
    else
      /^\S+ (\S+) -> (\S+)/ =~ raw_line
      parsed_line[:type] = :nick
      parsed_line[:old_nick] = Regexp.last_match 1
      parsed_line[:new_nick] = Regexp.last_match 2
      parsed_line[:nick] = Regexp.last_match 2
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
