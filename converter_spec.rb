#!/usr/bin/env ruby

require 'converter'




RAW_JOIN_MESSAGE = '01:09:27 + thinca (thinca!i=3b9c8a56@gateway/web/ajax/mibbit.com/x-7370eae4604f8456) to #Vim-users.jp@freenode'
RAW_MSG_MESSAGE_WITHOUT_SPECIALS = '03:17:42 <#Vim-users.jp@freenode:kana> やることやった感'
RAW_MSG_MESSAGE_WITH_AN_IMAGE_LINK = '03:22:04 <#Vim-users.jp@freenode:kana> http://gyazo.com/af8f793b7371a721bbb06059b8d3d5fe.png'
RAW_MSG_MESSAGE_WITH_A_NORMAL_LINK = '03:17:35 <#Vim-users.jp@freenode:kana> よし寝る http://whileimautomaton.net/2009/05/29/02/37/54/diary'
RAW_MSG_MESSAGE_WITH_A_PASTE_LINK = '14:28:59 <#Vim-users.jp@freenode:Shougo> http://gist.github.com/119798'
RAW_NICK_MESSAGE = '09:34:25 ukstudio -> ukstudio_aw'
RAW_PART_MESSAGE = '20:02:15 ! kana ("http://www.mibbit.com ajax IRC Client")'








describe Converter, 'with a join message' do
  before do
    @parsed_line = Converter.new.parsed_line_from_raw_line RAW_JOIN_MESSAGE
  end

  it 'should have a valid type' do
    @parsed_line[:type].should == :join
  end

  it 'should have a valid nick' do
    @parsed_line[:nick].should == 'thinca'
  end

  it 'should have a valid time' do
    @parsed_line[:time].should == '01:09:27'
  end
end

describe Converter, 'with a normal message without specials' do
  before do
    @parsed_line = Converter.new.parsed_line_from_raw_line RAW_MSG_MESSAGE_WITHOUT_SPECIALS
  end

  it 'should have a valid type' do
    @parsed_line[:type].should == :msg
  end

  it 'should have a valid nick' do
    @parsed_line[:nick].should == 'kana'
  end

  it 'should have a valid time' do
    @parsed_line[:time].should == '03:17:42'
  end

  it 'should have a valid text' do
    @parsed_line[:text].should == 'やることやった感'
  end
end

describe Converter, 'with a normal message with an image link' do
  before do
    @parsed_line = Converter.new.parsed_line_from_raw_line RAW_MSG_MESSAGE_WITH_AN_IMAGE_LINK
  end

  it 'should have a valid type' do
    @parsed_line[:type].should == :msg
  end

  it 'should have a valid nick' do
    @parsed_line[:nick].should == 'kana'
  end

  it 'should have a valid time' do
    @parsed_line[:time].should == '03:22:04'
  end

  it 'should have a valid text' do
    @parsed_line[:text].should == 'http://gyazo.com/af8f793b7371a721bbb06059b8d3d5fe.png'
  end
end

describe Converter, 'with a normal message with a normal link' do
  before do
    @parsed_line = Converter.new.parsed_line_from_raw_line RAW_MSG_MESSAGE_WITH_A_NORMAL_LINK
  end

  it 'should have a valid type' do
    @parsed_line[:type].should == :msg
  end

  it 'should have a valid nick' do
    @parsed_line[:nick].should == 'kana'
  end

  it 'should have a valid time' do
    @parsed_line[:time].should == '03:17:35'
  end

  it 'should have a valid text' do
    @parsed_line[:text].should == 'よし寝る http://whileimautomaton.net/2009/05/29/02/37/54/diary'
  end
end

describe Converter, 'with a normal message with a paste link' do
  before do
    @parsed_line = Converter.new.parsed_line_from_raw_line RAW_MSG_MESSAGE_WITH_A_PASTE_LINK
  end

  it 'should have a valid type' do
    @parsed_line[:type].should == :msg
  end

  it 'should have a valid nick' do
    @parsed_line[:nick].should == 'Shougo'
  end

  it 'should have a valid time' do
    @parsed_line[:time].should == '14:28:59'
  end

  it 'should have a valid text' do
    @parsed_line[:text].should == 'http://gist.github.com/119798'
  end
end

describe Converter, 'with a nick message' do
  before do
    @parsed_line = Converter.new.parsed_line_from_raw_line RAW_NICK_MESSAGE
  end

  it 'should have a valid type' do
    @parsed_line[:type].should == :nick
  end

  it 'should have a valid nick' do
    @parsed_line[:nick].should == 'ukstudio_aw'
    @parsed_line[:old_nick].should == 'ukstudio'
    @parsed_line[:new_nick].should == 'ukstudio_aw'
  end

  it 'should have a valid time' do
    @parsed_line[:time].should == '09:34:25'
  end
end

describe Converter, 'with a part message' do
  before do
    @parsed_line = Converter.new.parsed_line_from_raw_line RAW_PART_MESSAGE
  end

  it 'should have a valid type' do
    @parsed_line[:type].should == :part
  end

  it 'should have a valid nick' do
    @parsed_line[:nick].should == 'kana'
  end

  it 'should have a valid time' do
    @parsed_line[:time].should == '20:02:15'
  end
end

__END__
