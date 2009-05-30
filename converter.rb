#!/usr/bin/env ruby
# Prefix  Meaning
# ------  -------
# rline   raw line
# pline   parsed line
# cline   converted line

require 'cgi'




class Converter
  TEMPLATE_LINE = '<li id="L%d" class="%s">%s</li>'
  TEMPLATE_JOIN_CONTENT = '<span class="time">%s</span> <span class="nick">%s</span> <span class="text">has joined</span>'
  TEMPLATE_NICK_CONTENT = <<-'END'
    <span class="time">%s</span>
    <span class="text">
      <span class="old-nick">%s</span>
      is now as known as
      <span class="new-nick">%s</span>
    </span>
  END
  TEMPLATE_MSG_CONTENT = <<-'END'
    <span class="time">%s</span>
    <span class="nick">%s</span>
    <span class="text">%s</span>
  END
  TEMPLATE_PART_CONTENT = <<-'END'
    <span class="time">%s</span>
    <span class="nick">%s</span>
    <span class="text">has left</span>
  END
  TEMPLATE_TOPIC_CONTENT = <<-'END'
    <span class="time">%s</span>
    <span class="nick">%s</span>
    <span class="text">sets topic:
      <span class="topic">%s</span>
    </span>
  END

  def convert(input_stream)
    yield generate_header

    input_stream.lines.each_with_index do |rline, line_number|
      yield "#{rline}#{line_number}\n"
    end

    yield generate_footer
  end

  def converted_line_of_join_from_parsed_line(parsed_line, line_number)
    return TEMPLATE_LINE % [
      line_number,
      parsed_line[:type],
      TEMPLATE_JOIN_CONTENT % [
        parsed_line[:time],
        sanitize(parsed_line[:nick])
      ]
    ]
  end

  def generate_header()
    return "dummy header\n"
  end

  def generate_footer()
    return "dummy footer\n"
  end

  def main(args)
    if args.size != 1
      return usage
    end

    date = args[0]
    unless /^\d\d\d\d-\d\d-\d\d$/ =~ date
      warn "Invalid date: #{args[0]}"
      return 1
    end

    convert $stdin do |line|
      print line
    end

    return 0
  end

  def parsed_line_from_rline(rline)
    parsed_line = {}

    /^(\d\d:\d\d:\d\d) (.)/ =~ rline
    parsed_line[:time] = Regexp.last_match 1

    case Regexp.last_match 2
    when nil then
      parsed_line[:type] = :invalid
      parsed_line[:original] = rline
    when '+' then
      /^\S+ \+ (\S+) / =~ rline
      parsed_line[:type] = :join
      parsed_line[:nick] = Regexp.last_match 1
    when '!' then
      /^\S+ ! (\S+) / =~ rline
      parsed_line[:type] = :part
      parsed_line[:nick] = Regexp.last_match 1
    when '<', '>' then
      /^\S+ [<>]\S+:(\S+)[<>] (.*)$/ =~ rline
      parsed_line[:type] = :msg
      parsed_line[:nick] = Regexp.last_match 1
      parsed_line[:text] = Regexp.last_match 2
    else
      if /^\S+ (\S+) -> (\S+)/ =~ rline
        parsed_line[:type] = :nick
        parsed_line[:old_nick] = Regexp.last_match 1
        parsed_line[:new_nick] = Regexp.last_match 2
        parsed_line[:nick] = Regexp.last_match 2
      elsif /^\S+ Topic of channel #\S+@\S+ by (\S+): (.*)$/ =~ rline
        parsed_line[:type] = :topic
        parsed_line[:nick] = Regexp.last_match 1
        parsed_line[:topic] = Regexp.last_match 2
      else
        parsed_line[:type] = :invalid
        parsed_line[:original] = rline
      end
    end

    return parsed_line
  end

  def sanitize(*args)
    return CGI.escapeHTML *args
  end

  def usage()
    print "Usage: converter {YYYY-MM-DD} <{log.txt} >{log.html}\n"
    return 1
  end
end




if __FILE__ == $0
  exit Converter.new.main ARGV
end

__END__
