#!/usr/bin/env ruby
# Misc. initialization  #{{{1

require 'converter'
require 'stringio'


RAW_JOIN_MESSAGE = '01:09:27 + thinca (thinca!i=3b9c8a56@gateway/web/ajax/mibbit.com/x-7370eae4604f8456) to #Vim-users.jp@freenode'
RAW_MSG_MESSAGE_WITHOUT_SPECIALS = '03:17:42 <#Vim-users.jp@freenode:kana> やることやった感'
RAW_MSG_MESSAGE_WITHOUT_SPECIALS2 = '14:00:37 >#Vim-users.jp@freenode:from_kyushu< gyazoみたく簡単にできれば良いのだけども'
RAW_MSG_MESSAGE_WITH_AN_IMAGE_LINK = '03:22:04 <#Vim-users.jp@freenode:kana> http://gyazo.com/af8f793b7371a721bbb06059b8d3d5fe.png'
RAW_MSG_MESSAGE_WITH_A_NORMAL_LINK = '03:17:35 <#Vim-users.jp@freenode:kana> よし寝る http://whileimautomaton.net/2009/05/29/02/37/54/diary'
RAW_MSG_MESSAGE_WITH_A_PASTE_LINK = '14:28:59 <#Vim-users.jp@freenode:Shougo> http://gist.github.com/119798'
RAW_NICK_MESSAGE = '09:34:25 ukstudio -> ukstudio_aw'
RAW_PART_MESSAGE = '20:02:15 ! kana ("http://www.mibbit.com ajax IRC Client")'
RAW_TOPIC_MESSAGE = '13:45:40 Topic of channel #Vim-users.jp@freenode by from_kyushu: ログサーバを一時的に復帰 http://chat.vim-users.jp/ for true vim users and not true vim users.'




describe Converter, 'parsing a join message' do  #{{{1
  before do
    @pline = Converter.new.pline_from_rline RAW_JOIN_MESSAGE
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
    pline = c.pline_from_rline RAW_JOIN_MESSAGE
    cline = c.cline_of_join_from_pline pline, 1
    cline.should == '<li id="L1" class="join"><span class="time">01:09:27</span> <span class="nick">thinca</span> <span class="text">has joined</span></li>'
  end
end




describe Converter, 'parsing a normal message without specials' do  #{{{1
  before do
    @pline = Converter.new.pline_from_rline RAW_MSG_MESSAGE_WITHOUT_SPECIALS
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




describe Converter, 'parsing another normal message without specials' do  #{{{1
  before do
    @pline = Converter.new.pline_from_rline RAW_MSG_MESSAGE_WITHOUT_SPECIALS2
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




describe Converter, 'parsing a normal message with an image link' do  #{{{1
  before do
    @pline = Converter.new.pline_from_rline RAW_MSG_MESSAGE_WITH_AN_IMAGE_LINK
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




describe Converter, 'parsing a normal message with a normal link' do  #{{{1
  before do
    @pline = Converter.new.pline_from_rline RAW_MSG_MESSAGE_WITH_A_NORMAL_LINK
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




describe Converter, 'parsing a normal message with a paste link' do  #{{{1
  before do
    @pline = Converter.new.pline_from_rline RAW_MSG_MESSAGE_WITH_A_PASTE_LINK
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




describe Converter, 'parsing a nick message' do  #{{{1
  before do
    @pline = Converter.new.pline_from_rline RAW_NICK_MESSAGE
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
    pline = c.pline_from_rline RAW_NICK_MESSAGE
    cline = c.cline_of_nick_from_pline pline, 2
    cline.should == '<li id="L2" class="nick"><span class="time">09:34:25</span> <span class="text"><span class="old-nick">ukstudio</span> is now as known as <span class="new-nick">ukstudio_aw</span></span></li>'
  end
end




describe Converter, 'parsing a part message' do  #{{{1
  before do
    @pline = Converter.new.pline_from_rline RAW_PART_MESSAGE
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
    pline = c.pline_from_rline RAW_PART_MESSAGE
    cline = c.cline_of_part_from_pline pline, 3
    cline.should == '<li id="L3" class="part"><span class="time">20:02:15</span> <span class="nick">kana</span> <span class="text">has left</span></li>'
  end
end




describe Converter, 'parsing a topic message' do  #{{{1
  before do
    @pline = Converter.new.pline_from_rline RAW_TOPIC_MESSAGE
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
    pline = c.pline_from_rline RAW_TOPIC_MESSAGE
    cline = c.cline_of_topic_from_pline pline, 4
    cline.should == '<li id="L4" class="topic"><span class="time">13:45:40</span> <span class="nick">from_kyushu</span> <span class="text">sets topic: <span class="topic">ログサーバを一時的に復帰 http://chat.vim-users.jp/ for true vim users and not true vim users.</span></span></li>'
  end
end




describe Converter, 'parsing an invalid message' do  #{{{1
  before do
    @pline = Converter.new.pline_from_rline 'foo bar baz'
  end

  it 'should have a valid type' do
    @pline[:type].should == :invalid
  end

  it 'should have the original value' do
    @pline[:original].should == 'foo bar baz'
  end
end




describe Converter, 'parsing another invalid message' do  #{{{1
  before do
    @pline = Converter.new.pline_from_rline '00:01:02 Xyzzy'
  end

  it 'should have a valid type' do
    @pline[:type].should == :invalid
  end

  it 'should have the original value' do
    @pline[:original].should == '00:01:02 Xyzzy'
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
        RAW_JOIN_MESSAGE,
        RAW_MSG_MESSAGE_WITHOUT_SPECIALS,
        RAW_MSG_MESSAGE_WITHOUT_SPECIALS2,
        RAW_MSG_MESSAGE_WITH_AN_IMAGE_LINK,
        RAW_MSG_MESSAGE_WITH_A_NORMAL_LINK,
        RAW_MSG_MESSAGE_WITH_A_PASTE_LINK,
        RAW_NICK_MESSAGE,
        RAW_PART_MESSAGE,
        RAW_TOPIC_MESSAGE,
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
