ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"

require_relative "../cms.rb"

class CMSTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_index
    index_body = <<~BODY
      <ul>
          <li><a href="/changes.txt">changes.txt</a></li>
          <li><a href="/about.txt">about.txt</a></li>
          <li><a href="/history.txt">history.txt</a></li>
      </ul>
    BODY

    get "/"
    assert_equal(200, last_response.status)
    assert_equal("text/html;charset=utf-8", last_response["Content-Type"])
    assert_equal(index_body, last_response.body)
  end

  def test_filename
    # index_body = <<~BODY
    
    # BODY
    
    get "/changes.txt"
    assert_equal(200, last_response.status)
    assert_equal("text/plain", last_response["Content-Type"])
  end
end
