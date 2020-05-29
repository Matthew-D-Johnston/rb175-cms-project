require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

root = File.expand_path("..", __FILE__)

get "/" do
  @files = Dir.glob(root + "/data/*").map do |path|
    File.basename(path)
  end
  erb :index
end

get "/:file" do
  file_name = params[:file]
  file_path = root + "/data/#{file_name}"
  @file = File.read(file_path)

  erb :file
end
