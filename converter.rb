#!/usr/bin/env ruby
# Prefix  Meaning
# ------  -------
# rline   raw line
# pline   parsed line
# cline   converted line

require 'cgi'




class Converter
  TEMPLATE_LINE = '<li id="L%d" class="%s">%s</li>' + "\n"

  TEMPLATE_INVALID_CONTENT = '<span class="text">%s</span>'
  TEMPLATE_JOIN_CONTENT = '<span class="time">%s</span> <span class="nick">%s</span> <span class="text">has joined</span>'
  TEMPLATE_MSG_CONTENT = '<span class="time">%s</span> <span class="nick">%s</span> <span class="text">%s</span>'
  TEMPLATE_NICK_CONTENT = '<span class="time">%s</span> <span class="text"><span class="old-nick">%s</span> is now as known as <span class="new-nick">%s</span></span>'
  TEMPLATE_PART_CONTENT = '<span class="time">%s</span> <span class="nick">%s</span> <span class="text">has left</span>'
  TEMPLATE_TOPIC_CONTENT = '<span class="time">%s</span> <span class="nick">%s</span> <span class="text">sets topic: <span class="topic">%s</span></span>'
  TEMPLATE_UNSUPPORTED_CONTENT = '<span class="time">%s</span> <span class="text">%s</span>'

  def cline_of_invalid_from_pline(pline, line_number)
    return TEMPLATE_LINE % [
      line_number,
      pline[:type],
      TEMPLATE_INVALID_CONTENT % [
        sanitize(pline[:original])
      ]
    ]
  end

  def cline_of_join_from_pline(pline, line_number)
    return TEMPLATE_LINE % [
      line_number,
      pline[:type],
      TEMPLATE_JOIN_CONTENT % [
        pline[:time],
        sanitize(pline[:nick])
      ]
    ]
  end

  def cline_of_nick_from_pline(pline, line_number)
    return TEMPLATE_LINE % [
      line_number,
      pline[:type],
      TEMPLATE_NICK_CONTENT % [
        pline[:time],
        sanitize(pline[:old_nick]),
        sanitize(pline[:new_nick])
      ]
    ]
  end

  def cline_of_msg_from_pline(pline, line_number)
    # FIXME: Expand each link in :text
    return TEMPLATE_LINE % [
      line_number,
      pline[:type],
      TEMPLATE_MSG_CONTENT % [
        pline[:time],
        sanitize(pline[:nick]),
        sanitize(pline[:text]),
      ]
    ]
  end

  def cline_of_part_from_pline(pline, line_number)
    return TEMPLATE_LINE % [
      line_number,
      pline[:type],
      TEMPLATE_PART_CONTENT % [
        pline[:time],
        sanitize(pline[:nick]),
      ]
    ]
  end

  def cline_of_topic_from_pline(pline, line_number)
    return TEMPLATE_LINE % [
      line_number,
      pline[:type],
      TEMPLATE_TOPIC_CONTENT % [
        pline[:time],
        sanitize(pline[:nick]),
        make_simple_links_in(sanitize pline[:topic]),
      ]
    ]
  end

  def cline_of_unsupported_from_pline(pline, line_number)
    return TEMPLATE_LINE % [
      line_number,
      pline[:type],
      TEMPLATE_UNSUPPORTED_CONTENT % [
        pline[:time],
        sanitize(pline[:message])
      ]
    ]
  end

  def convert(input_stream, date)
    yield generate_header date

    input_stream.lines.each_with_index do |rline, index|
      line_number = index + 1
      pline = pline_from_rline rline
      cline_from_pline = method('cline_of_%s_from_pline' % pline[:type])
      yield cline_from_pline.call pline, line_number
    end

    yield generate_footer
  end

  def generate_header(date)
    title = sanitize 'chat.vim-users.jp > log > %s' % date
    return <<-'END' % [title, title]
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja">
<head>
  <title>%s</title>
  <link rel="stylesheet" href="log.css"/>
  <!-- FIXME: rel="next" and others -->
</head>
<body>
<h1>%s</h1>
<ul class="log">
    END
  end

  def generate_footer()
    return <<-'END'
</ul>
</body>
</html>
    END
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

    convert $stdin, date do |line|
      print line
    end

    return 0
  end

  def make_simple_links_in(sanitized_string)  # FIXME: NIY
    return sanitized_string
  end

  def pline_from_rline(rline)
    pline = {}

    /^(\d\d:\d\d:\d\d) (.)/ =~ rline
    pline[:time] = Regexp.last_match 1

    case Regexp.last_match 2
    when nil then
      pline[:type] = :invalid
      pline[:original] = rline.chomp
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
        /^\S+\s+(.*)$/ =~ rline
        pline[:type] = :unsupported
        pline[:message] = Regexp.last_match 1
      end
    end

    return pline
  end

  def sanitize(*args)
    return CGI.escapeHTML(*args).gsub(/'/, '&#39;')
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
