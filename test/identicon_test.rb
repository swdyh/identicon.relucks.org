require 'rubygems'
require 'sinatra'
require 'sinatra/test/spec'
require 'identicon'

describe 'Identicon' do
  setup do
    FileUtils.rm Dir.glob('tmp/*')
  end

  it "should show a default page" do
    get_it '/'
    should.be.ok
  end

  it "should display icon" do
    get_it '/foo'
    should.be.ok
    tmp = IO.read 'tmp/200198069'
    body.should.be.equal tmp
    headers['Content-Type'].should.equal 'image/png'
    headers['Content-Length'].should.equal tmp.size.to_s
  end

  it "should display with size option" do
    get_it '/foo?size=100'
    should.be.ok
    tmp = IO.read 'tmp/200198069_100'
    body.should.be.equal tmp
    headers['Content-Type'].should.equal 'image/png'
    headers['Content-Length'].should.equal tmp.size.to_s
  end

  it "should display with option include '.' " do
    get_it '/foo.foo?size=100'
    should.be.ok
  end
end

