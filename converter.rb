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

  def converted_line_of_join_from_pline(pline, line_number)
    return TEMPLATE_LINE % [
      line_number,
      pline[:type],
      TEMPLATE_JOIN_CONTENT % [
        pline[:time],
        sanitize(pline[:nick])
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

  def pline_from_rline(rline)
    pline = {}

    /^(\d\d:\d\d:\d\d) (.)/ =~ rline
    pline[:time] = Regexp.last_match 1

    case Regexp.last_match 2
    when nil then
      pline[:type] = :invalid
      pline[:original] = rline
    when '+' then
      /^\S+ \+ (\S+) / =~ rline
      pline[:type] = :join
      pline[:nick] = Regexp.last_match 1
    when '!' then
      /^\S+ ! (\S+) / =~ rline
      pline[:type] = :part
      pline[:nick] = Regexp.last_match 1
    when '<', '>' then
      /^\S+ [<>]\S+:(\S+)[<>] (.*)$/ =~ rline
      pline[:type] = :msg
      pline[:nick] = Regexp.last_match 1
      pline[:text] = Regexp.last_match 2
    else
      if /^\S+ (\S+) -> (\S+)/ =~ rline
        pline[:type] = :nick
        pline[:old_nick] = Regexp.last_match 1
        pline[:new_nick] = Regexp.last_match 2
        pline[:nick] = Regexp.last_match 2
      elsif /^\S+ Topic of channel #\S+@\S+ by (\S+): (.*)$/ =~ rline
        pline[:type] = :topic
        pline[:nick] = Regexp.last_match 1
        pline[:topic] = Regexp.last_match 2
      else
        pline[:type] = :invalid
        pline[:original] = rline
      end
    end

    return pline
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
