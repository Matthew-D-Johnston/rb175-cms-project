##### RB175 Networked Applications > Project: File-based CMS

---

## CMS Project Plan

### Assignment 3: Adding an Index Page  

Many content management systems store their content in databases, but some use files stored on the filesystem instead. This is the path we will follow with this project. Each document within the CMS will have a name that includes an extension. This extension will determine how the contents of the page are displayed in later steps.

#### Requirements  

1. When a user visits the home page, they should see a list of the documents in the CMS: `history.txt`, `changes.txt` and `about.txt`.

#### My Implementation and Solution

* Create a `files` directory within the route directory.

* Create `history.txt`, `changes.txt` and `about.txt` files.

* Create a `views` directory within the route directory.

* Within the `cms.rb` file, and within the block of the `get "/"` homepage route, we will need to access the files in the `files` directory. The code will store the files as an array assigned to a `@files` instance variable. Something like this: 

  ```ruby
  get "/" do
  	@files = Dir.entries("files").select { |file| file unless file =~ /^\./ }.sort
  end
  ```

* Create a view template called `files.erb`.

* Within the `files.erb` view template, code the appropriate HTML that will call the `@files`  instance variable and list the individual files. Something like this:

  ```html
  <ul>
    <% @files.each do |file| %>
    	<li><%= file %></li>
    <% end %>
  </ul>
  ```

  

* And we now need to update the `get "/"` route's block of code so that it will direct the client to that view template.

  ```ruby
  get "/" do
    @files = Dir.entries("files").select { |file| file unless file =~ /^\./ }.sort
  
    erb :files
  end
  ```

#### LS Implementation

1. Create a `data` directory in the same directory as your Sinatra application. Within the `data` directory, create three text files with following names: `history.txt`, `changes.txt` and `about.txt`.
2. Use methods from the [`File` class](http://ruby-doc.org/core-2.3.0/File.html) and the [`Dir` class](http://ruby-doc.org/core-2.3.0/Dir.html) to get a list of documents. Together, these classes provide many useful methods for manipulating file names, file paths, and directories.
3. Use an ERB template to render the list of documents.

#### LS Solution

```ruby
# Gemfile
source "https://rubygems.org"

gem "sinatra"
gem "sinatra-contrib"
gem "erubis"
```

```ruby
# cms.rb
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
```

```html
<!-- views/index.erb -->
<ul>
  <% @files.each do |file| %>
    <li><%= file %></li>
  <% end %>
</ul>
```

