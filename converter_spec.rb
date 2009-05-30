#!/usr/bin/env ruby
# Misc. initialization  #{{{1

require 'converter'
require 'stringio'


RLINE_INVALID = 'Invalid format'
RLINE_JOIN = '01:09:27 + thinca (thinca!i=3b9c8a56@gateway/web/ajax/mibbit.com/x-7370eae4604f8456) to #Vim-users.jp@freenode'
RLINE_MSG_LINK_ALL_TYPES = '00:01:02 <#Vim-users.jp@freenode:kana> foo http://whileimautomaton.net/2009/05/29/02/37/54/diary bar http://gyazo.com/af8f793b7371a721bbb06059b8d3d5fe.png baz http://gist.github.com/119798 hehehe'
RLINE_MSG_LINK_IMAGE = '03:22:04 <#Vim-users.jp@freenode:kana> http://gyazo.com/af8f793b7371a721bbb06059b8d3d5fe.png'
RLINE_MSG_LINK_NORMAL = '03:17:35 <#Vim-users.jp@freenode:kana> よし寝る http://whileimautomaton.net/2009/05/29/02/37/54/diary'
RLINE_MSG_LINK_PASTE = '14:28:59 <#Vim-users.jp@freenode:Shougo> http://gist.github.com/119798'
RLINE_MSG_NORMAL = '03:17:42 <#Vim-users.jp@freenode:kana> やることやった感'
RLINE_MSG_NORMAL2 = '14:00:37 >#Vim-users.jp@freenode:from_kyushu< gyazoみたく簡単にできれば良いのだけども'
RLINE_MSG_NORMAL3 = %q{00:01:02 <#Vim-users.jp@freenode:kana> &"<>'}
RLINE_NICK = '09:34:25 ukstudio -> ukstudio_aw'
RLINE_PART = '20:02:15 ! kana ("http://www.mibbit.com ajax IRC Client")'
RLINE_TOPIC = '13:45:40 Topic of channel #Vim-users.jp@freenode by from_kyushu: ログサーバを一時的に復帰 http://chat.vim-users.jp/ for true vim users and not true vim users.'
RLINE_UNSUPPORTED = '00:01:02 Unsupported format'




describe Converter, 'translating uris, simple style' do  #{{{1
  it 'should translate uris into html links' do
    c = Converter.new
    sanitized_s = c.sanitize 'foo http://example.com/ bar http://example.net/'
    translated_s = c.make_simple_links_in sanitized_s
    translated_s.should == 'foo <a href="http://example.com/">http://example.com/</a> bar <a href="http://example.net/">http://example.net/</a>'
  end
end




describe Converter, 'translating uris, neat style' do  #{{{1
  before do
    @c = Converter.new
  end

  it 'should translate simple uris into html links' do
    sanitized_s = @c.sanitize 'foo http://example.com/ bar http://example.net/'
    translated_s = @c.make_neat_links_in sanitized_s
    translated_s.should == 'foo <a href="http://example.com/">http://example.com/</a> bar <a href="http://example.net/">http://example.net/</a>'
  end

  it 'should translate image uris into html links with img' do
    sanitized_s = @c.sanitize 'foo http://example.com/a.png bar http://example.net/b.png'
    translated_s = @c.make_neat_links_in sanitized_s
    translated_s.should == 'foo <a href="http://example.com/a.png"><img src="http://example.com/a.png" alt="http://example.com/a.png"/></a> bar <a href="http://example.net/b.png"><img src="http://example.net/b.png" alt="http://example.net/b.png"/></a>'
  end

  it 'should translate gist uris into html links with script' do
    sanitized_s = @c.sanitize 'foo http://gist.github.com/1 bar http://gist.github.com/2'
    translated_s = @c.make_neat_links_in sanitized_s
    translated_s.should == 'foo <a href="http://gist.github.com/1">http://gist.github.com/1</a><script src="http://gist.github.com/1.js" type="text/javascript"></script> bar <a href="http://gist.github.com/2">http://gist.github.com/2</a><script src="http://gist.github.com/2.js" type="text/javascript"></script>'
  end
end




describe Converter, 'parsing a join message' do  #{{{1
  before do
    @pline = Converter.new.pline_from_rline RLINE_JOIN
  end

  it 'should have a valid type' do
    @pline[:type].should == :join
  end

  it 'should have a valid nick' do
    @pline[:nick].should == 'thinca'
  end

  it 'should have a valid time' do
    @pline[:time].should == '01:09:27'
  end
end




describe Converter, 'converting a join message' do  #{{{1
  it 'should convert the line nicely' do
    c = Converter.new
    pline = c.pline_from_rline RLINE_JOIN
    cline = c.cline_of_join_from_pline pline, 1
    cline.should == '<tr id="L1" class="join"><td><a class="time" href="#L1" title="URI for the post #1">01:09:27</a></td> <td><span class="nick">thinca</span></td> <td><span class="text">has joined</span></td></tr>' + "\n"
  end
end




describe Converter, 'parsing a normal message without specials' do  #{{{1
  before do
    @pline = Converter.new.pline_from_rline RLINE_MSG_NORMAL
  end

  it 'should have a valid type' do
    @pline[:type].should == :msg
  end

  it 'should have a valid nick' do
    @pline[:nick].should == 'kana'
  end

  it 'should have a valid time' do
    @pline[:time].should == '03:17:42'
  end

  it 'should have a valid text' do
    @pline[:text].should == 'やることやった感'
  end
end




describe Converter, 'converting a normal message without specials' do  #{{{1
  it 'should convert the line nicely' do
    c = Converter.new
    pline = c.pline_from_rline RLINE_MSG_NORMAL
    cline = c.cline_of_msg_from_pline pline, 5
    cline.should == '<tr id="L5" class="msg"><td><a class="time" href="#L5" title="URI for the post #5">03:17:42</a></td> <td><span class="nick">kana</span></td> <td><span class="text">やることやった感</span></td></tr>' + "\n"
  end
end




describe Converter, 'parsing another normal message without specials' do  #{{{1
  before do
    @pline = Converter.new.pline_from_rline RLINE_MSG_NORMAL2
  end

  it 'should have a valid type' do
    @pline[:type].should == :msg
  end

  it 'should have a valid nick' do
    @pline[:nick].should == 'from_kyushu'
  end

  it 'should have a valid time' do
    @pline[:time].should == '14:00:37'
  end

  it 'should have a valid text' do
    @pline[:text].should == 'gyazoみたく簡単にできれば良いのだけども'
  end
end




describe Converter, 'converting another normal message without specials' do  #{{{1
  it 'should convert the line nicely' do
    c = Converter.new
    pline = c.pline_from_rline RLINE_MSG_NORMAL2
    cline = c.cline_of_msg_from_pline pline, 6
    cline.should == '<tr id="L6" class="msg"><td><a class="time" href="#L6" title="URI for the post #6">14:00:37</a></td> <td><span class="nick">from_kyushu</span></td> <td><span class="text">gyazoみたく簡単にできれば良いのだけども</span></td></tr>' + "\n"
  end
end




describe Converter, 'parsing an evil message' do  #{{{1
  before do
    @pline = Converter.new.pline_from_rline RLINE_MSG_NORMAL3
  end

  it 'should have a valid type' do
    @pline[:type].should == :msg
  end

  it 'should have a valid nick' do
    @pline[:nick].should == 'kana'
  end

  it 'should have a valid time' do
    @pline[:time].should == '00:01:02'
  end

  it 'should have a valid text' do
    @pline[:text].should == "&\"<>'"
  end
end




describe Converter, 'converting an evil message' do  #{{{1
  it 'should convert the line nicely' do
    c = Converter.new
    pline = c.pline_from_rline RLINE_MSG_NORMAL3
    cline = c.cline_of_msg_from_pline pline, 12
    cline.should == %q{<tr id="L12" class="msg"><td><a class="time" href="#L12" title="URI for the post #12">00:01:02</a></td> <td><span class="nick">kana</span></td> <td><span class="text">&amp;&quot;&lt;&gt;&#39;</span></td></tr>} + "\n"
  end
end




describe Converter, 'parsing a normal message with an image link' do  #{{{1
  before do
    @pline = Converter.new.pline_from_rline RLINE_MSG_LINK_IMAGE
  end

  it 'should have a valid type' do
    @pline[:type].should == :msg
  end

  it 'should have a valid nick' do
    @pline[:nick].should == 'kana'
  end

  it 'should have a valid time' do
    @pline[:time].should == '03:22:04'
  end

  it 'should have a valid text' do
    @pline[:text].should == 'http://gyazo.com/af8f793b7371a721bbb06059b8d3d5fe.png'
  end
end




describe Converter, 'converting a normal message with an image link' do  #{{{1
  it 'should convert the line nicely' do
    c = Converter.new
    pline = c.pline_from_rline RLINE_MSG_LINK_IMAGE
    cline = c.cline_of_msg_from_pline pline, 7
    cline.should == '<tr id="L7" class="msg"><td><a class="time" href="#L7" title="URI for the post #7">03:22:04</a></td> <td><span class="nick">kana</span></td> <td><span class="text"><a href="http://gyazo.com/af8f793b7371a721bbb06059b8d3d5fe.png"><img src="http://gyazo.com/af8f793b7371a721bbb06059b8d3d5fe.png" alt="http://gyazo.com/af8f793b7371a721bbb06059b8d3d5fe.png"/></a></span></td></tr>' + "\n"
  end
end




describe Converter, 'parsing a normal message with a normal link' do  #{{{1
  before do
    @pline = Converter.new.pline_from_rline RLINE_MSG_LINK_NORMAL
  end

  it 'should have a valid type' do
    @pline[:type].should == :msg
  end

  it 'should have a valid nick' do
    @pline[:nick].should == 'kana'
  end

  it 'should have a valid time' do
    @pline[:time].should == '03:17:35'
  end

  it 'should have a valid text' do
    @pline[:text].should == 'よし寝る http://whileimautomaton.net/2009/05/29/02/37/54/diary'
  end
end




describe Converter, 'converting a normal message with a normal link' do  #{{{1
  it 'should convert the line nicely' do
    c = Converter.new
    pline = c.pline_from_rline RLINE_MSG_LINK_NORMAL
    cline = c.cline_of_msg_from_pline pline, 8
    cline.should == '<tr id="L8" class="msg"><td><a class="time" href="#L8" title="URI for the post #8">03:17:35</a></td> <td><span class="nick">kana</span></td> <td><span class="text">よし寝る <a href="http://whileimautomaton.net/2009/05/29/02/37/54/diary">http://whileimautomaton.net/2009/05/29/02/37/54/diary</a></span></td></tr>' + "\n"
  end
end




describe Converter, 'parsing a normal message with a paste link' do  #{{{1
  before do
    @pline = Converter.new.pline_from_rline RLINE_MSG_LINK_PASTE
  end

  it 'should have a valid type' do
    @pline[:type].should == :msg
  end

  it 'should have a valid nick' do
    @pline[:nick].should == 'Shougo'
  end

  it 'should have a valid time' do
    @pline[:time].should == '14:28:59'
  end

  it 'should have a valid text' do
    @pline[:text].should == 'http://gist.github.com/119798'
  end
end




describe Converter, 'converting a normal message with a paste link' do  #{{{1
  it 'should convert the line nicely' do
    c = Converter.new
    pline = c.pline_from_rline RLINE_MSG_LINK_PASTE
    cline = c.cline_of_msg_from_pline pline, 9
    cline.should == '<tr id="L9" class="msg"><td><a class="time" href="#L9" title="URI for the post #9">14:28:59</a></td> <td><span class="nick">Shougo</span></td> <td><span class="text"><a href="http://gist.github.com/119798">http://gist.github.com/119798</a><script src="http://gist.github.com/119798.js" type="text/javascript"></script></span></td></tr>' + "\n"
  end
end




describe Converter, 'parsing a normal message with multiple links' do  #{{{1
  before do
    @pline = Converter.new.pline_from_rline RLINE_MSG_LINK_ALL_TYPES
  end

  it 'should have a valid type' do
    @pline[:type].should == :msg
  end

  it 'should have a valid nick' do
    @pline[:nick].should == 'kana'
  end

  it 'should have a valid time' do
    @pline[:time].should == '00:01:02'
  end

  it 'should have a valid text' do
    @pline[:text].should == 'foo http://whileimautomaton.net/2009/05/29/02/37/54/diary bar http://gyazo.com/af8f793b7371a721bbb06059b8d3d5fe.png baz http://gist.github.com/119798 hehehe'
  end
end




describe Converter, 'converting a normal message with multiple links' do  #{{{1
  it 'should convert the line nicely' do
    c = Converter.new
    pline = c.pline_from_rline RLINE_MSG_LINK_ALL_TYPES
    cline = c.cline_of_msg_from_pline pline, 11
    cline.should == '<tr id="L11" class="msg"><td><a class="time" href="#L11" title="URI for the post #11">00:01:02</a></td> <td><span class="nick">kana</span></td> <td><span class="text">foo <a href="http://whileimautomaton.net/2009/05/29/02/37/54/diary">http://whileimautomaton.net/2009/05/29/02/37/54/diary</a> bar <a href="http://gyazo.com/af8f793b7371a721bbb06059b8d3d5fe.png"><img src="http://gyazo.com/af8f793b7371a721bbb06059b8d3d5fe.png" alt="http://gyazo.com/af8f793b7371a721bbb06059b8d3d5fe.png"/></a> baz <a href="http://gist.github.com/119798">http://gist.github.com/119798</a><script src="http://gist.github.com/119798.js" type="text/javascript"></script> hehehe</span></td></tr>' + "\n"
  end
end




describe Converter, 'parsing a nick message' do  #{{{1
  before do
    @pline = Converter.new.pline_from_rline RLINE_NICK
  end

  it 'should have a valid type' do
    @pline[:type].should == :nick
  end

  it 'should have a valid nick' do
    @pline[:nick].should == 'ukstudio_aw'
    @pline[:old_nick].should == 'ukstudio'
    @pline[:new_nick].should == 'ukstudio_aw'
  end

  it 'should have a valid time' do
    @pline[:time].should == '09:34:25'
  end
end




describe Converter, 'converting a nick message' do  #{{{1
  it 'should convert the line nicely' do
    c = Converter.new
    pline = c.pline_from_rline RLINE_NICK
    cline = c.cline_of_nick_from_pline pline, 2
    cline.should == '<tr id="L2" class="nick"><td><a class="time" href="#L2" title="URI for the post #2">09:34:25</a></td> <td><span class="old-nick">ukstudio</span></td> <td><span class="text">is now as known as <span class="new-nick">ukstudio_aw</span></span></td></tr>' + "\n"
  end
end




describe Converter, 'parsing a part message' do  #{{{1
  before do
    @pline = Converter.new.pline_from_rline RLINE_PART
  end

  it 'should have a valid type' do
    @pline[:type].should == :part
  end

  it 'should have a valid nick' do
    @pline[:nick].should == 'kana'
  end

  it 'should have a valid time' do
    @pline[:time].should == '20:02:15'
  end
end




describe Converter, 'converting a part message' do  #{{{1
  it 'should convert the line nicely' do
    c = Converter.new
    pline = c.pline_from_rline RLINE_PART
    cline = c.cline_of_part_from_pline pline, 3
    cline.should == '<tr id="L3" class="part"><td><a class="time" href="#L3" title="URI for the post #3">20:02:15</a></td> <td><span class="nick">kana</span></td> <td><span class="text">has left</span></td></tr>' + "\n"
  end
end




describe Converter, 'parsing a topic message' do  #{{{1
  before do
    @pline = Converter.new.pline_from_rline RLINE_TOPIC
  end

  it 'should have a valid type' do
    @pline[:type].should == :topic
  end

  it 'should have a valid nick' do
    @pline[:nick].should == 'from_kyushu'
  end

  it 'should have a valid time' do
    @pline[:time].should == '13:45:40'
  end

  it 'should have a valid topic' do
    @pline[:topic].should == 'ログサーバを一時的に復帰 http://chat.vim-users.jp/ for true vim users and not true vim users.'
  end
end




describe Converter, 'converting a topic message' do  #{{{1
  it 'should convert the line nicely' do
    c = Converter.new
    pline = c.pline_from_rline RLINE_TOPIC
    cline = c.cline_of_topic_from_pline pline, 4
    cline.should == '<tr id="L4" class="topic"><td><a class="time" href="#L4" title="URI for the post #4">13:45:40</a></td> <td><span class="nick">from_kyushu</span></td> <td><span class="text">sets topic: <span class="topic">ログサーバを一時的に復帰 <a href="http://chat.vim-users.jp/">http://chat.vim-users.jp/</a> for true vim users and not true vim users.</span></span></td></tr>' + "\n"
  end
end




describe Converter, 'parsing an unsupported message' do  #{{{1
  before do
    @pline = Converter.new.pline_from_rline RLINE_UNSUPPORTED
  end

  it 'should have a valid type' do
    @pline[:type].should == :unsupported
  end

  it 'should have a valid time' do
    @pline[:time].should == '00:01:02'
  end

  it 'should have the original message' do
    @pline[:message].should == 'Unsupported format'
  end
end




describe Converter, 'converting an unsuported message' do  #{{{1
  it 'should convert the line nicely' do
    c = Converter.new
    pline = c.pline_from_rline RLINE_UNSUPPORTED
    cline = c.cline_of_unsupported_from_pline pline, 10
    cline.should == '<tr id="L10" class="unsupported"><td><a class="time" href="#L10" title="URI for the post #10">00:01:02</a></td> <td colspan="2"><span class="text">Unsupported format</span></td></tr>' + "\n"
  end
end




describe Converter, 'parsing an invalid message' do  #{{{1
  before do
    @pline = Converter.new.pline_from_rline RLINE_INVALID
  end

  it 'should have a valid type' do
    @pline[:type].should == :invalid
  end

  it 'should have the original value' do
    @pline[:original].should == RLINE_INVALID
  end
end




describe Converter, 'converting an invalid message' do  #{{{1
  it 'should convert the line nicely' do
    c = Converter.new
    pline = c.pline_from_rline RLINE_INVALID
    cline = c.cline_of_invalid_from_pline pline, 10
    cline.should == '<tr id="L10" class="invalid"><td colspan="3"><a class="text" href="#L10" title="URI for the post #10">Invalid format</a></td></tr>' + "\n"
  end
end




describe Converter, 'main without any argument' do  #{{{1
  it 'should output usage message' do
    Converter.new.main([]).should == 1
    # FIXME: Check the output
  end
end




describe Converter, 'main with a valid argument' do  #{{{1
  it 'should return 0' do
    original_stdin = $stdin
      $stdin = StringIO.new [
        RLINE_INVALID,
        RLINE_JOIN,
        RLINE_MSG_LINK_ALL_TYPES,
        RLINE_MSG_LINK_IMAGE,
        RLINE_MSG_LINK_NORMAL,
        RLINE_MSG_LINK_PASTE,
        RLINE_MSG_NORMAL,
        RLINE_MSG_NORMAL2,
        RLINE_MSG_NORMAL3,
        RLINE_NICK,
        RLINE_PART,
        RLINE_TOPIC,
        RLINE_UNSUPPORTED,
        ''
      ].join("\n")
      Converter.new.main(['2009-05-30']).should == 0
    $stdin = original_stdin
  end
end




describe Converter, 'main with an invalid argument' do  #{{{1
  it 'should return 1' do
    Converter.new.main(['XXXX-YY-ZZ']).should == 1
    # FIXME: Check the output
  end
end




# vim: set foldmethod=marker :  #{{{1
__END__
