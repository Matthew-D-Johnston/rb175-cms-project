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

---

### Assignment 4: Viewing Text Files

This is a good time to add some content to the files in the `data` directory of the project. Feel free to use any text you'd like; you can also use the Ruby release dates list below.

#### Requirements

1. When a user visits the index page, they are presented with a list of links, one for each document in the CMS.
2. When a user clicks on a document link in the index, they should be taken to a page that displays the content of the file whose name was clicked.
3. When a user visits the path `/history.txt`, they will be presented with the content of the document `history.txt`.
4. The browser should render a text file as a plain text file.

#### My Implementation and Solution

* I will need to create `get` routes for files. We will want to use a parameter, such as `:file` in the route path.

  ```ruby
  get "/:file" do
    # implementation details go here
  end
  ```

* We will need a way to retrieve the file name specified as the parameter.

* We can use `File.read(root + "/data/:file")` and store in an instance variable called `@file`.

  ```ruby
  get "/:file" do
    file = params[:file]
  	@file = File.read(root + "/data/#{file}")
    
    # erb views page
  end
  ```

* Now we need to create a new views template page, named file, which will display the contents of the file.

  ```html
  <!-- views/file.erb -->
  <p>
    <%= @file %>
  </p>
  ```

* Then, the final route implementation will look like this:

  ```ruby
  get "/:file" do
    file_name = params[:file]
    file_path = root + "/data/#{file_name}"
    @file = File.read(file_path)
  
    erb :file
  end
  ```

* Now we need to add links to this route from the main page. To do that we will have to add some hyperlink references in the `index.erb` views template.

  ```ruby
  <ul>
    <% @files.each do |file| %>
      <li>
        <a href="/<%= file %>"><%= file %></a>
      </li>
    <% end %>
  </ul>
  ```

  