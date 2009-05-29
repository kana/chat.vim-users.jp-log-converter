#!/usr/bin/env ruby

class Converter
  def main()
    0
  end

  def parsed_line_from_raw_line(raw_line)
    parsed_line = {}

    /^(\d\d:\d\d:\d\d) (.)/ =~ raw_line
    parsed_line[:time] = Regexp.last_match 1

    case Regexp.last_match 2
    when nil then
      parsed_line[:type] = :invalid
      parsed_line[:original] = raw_line
    when '+' then
      /^\S+ \+ (\S+) / =~ raw_line
      parsed_line[:type] = :join
      parsed_line[:nick] = Regexp.last_match 1
    when '!' then
      /^\S+ ! (\S+) / =~ raw_line
      parsed_line[:type] = :part
      parsed_line[:nick] = Regexp.last_match 1
    when '<', '>' then
      /^\S+ [<>]\S+:(\S+)[<>] (.*)$/ =~ raw_line
      parsed_line[:type] = :msg
      parsed_line[:nick] = Regexp.last_match 1
      parsed_line[:text] = Regexp.last_match 2
    else
      if /^\S+ (\S+) -> (\S+)/ =~ raw_line
        parsed_line[:type] = :nick
        parsed_line[:old_nick] = Regexp.last_match 1
        parsed_line[:new_nick] = Regexp.last_match 2
        parsed_line[:nick] = Regexp.last_match 2
      elsif /^\S+ Topic of channel #\S+@\S+ by (\S+): (.*)$/ =~ raw_line
        parsed_line[:type] = :topic
        parsed_line[:nick] = Regexp.last_match 1
        parsed_line[:topic] = Regexp.last_match 2
      else
        parsed_line[:type] = :invalid
        parsed_line[:original] = raw_line
      end
    end

    return parsed_line
  end
end




if __FILE__ == $0
  exit Converter.new.main
end

__END__
