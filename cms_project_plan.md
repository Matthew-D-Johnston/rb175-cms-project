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

---

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

---

#### LS Implementation

1. Update `views/index.erb` to make each document name a link.
2. Add a new route that will handle viewing the contents of documents.
3. In the new route, read the contents of the document to be viewed.
4. Set an appropriate value for the `Content-Type` header to tell browsers to display the response as plain text.

#### LS Solution

```ruby
# cms.rb
get "/:filename" do
  file_path = root + "/data/" + params[:filename]

  headers["Content-Type"] = "text/plain"
  File.read(file_path)
end
```

```html
<!-- views/index.erb -->
<ul>
  <% @files.each do |file| %>
    <li><a href="/<%= file %>"><%= file %></a></li>
  <% end %>
</ul>
```

---

### Assignment 5: Adding Tests

Here is a summary of what you need to be able to do to get started testing a Sinatra application:

1. Make a request to your application.

   Use `get`, `post`, or other HTTP-method named methods.

2. Access the response.

   The response to your request will be accessible using `last_response`. This method will return an instance of `Rack::MockResponse`. Instances of this class provide `status`, `body`, and `[]` methods for accessing their status code, body, and headers, respectively.

3. Make assertions against values in the response.

   Use the standard assertions supplied by `Minitest`.

#### Requirements

1. Write tests for the routes that the application already supports.

#### My Implementation and Solution

* First, include the `minitest` gem in our `Gemfile`, then run `bundle install`.

* Next, we create a `test` directory and then a `cms_test.rb` file within it.

* Then we set up the file by assigning the `RACK_ENV` environment variable, requiring the appropriate testing libraries, requiring the app that is going to be tested, then creating the test suite class, mixing in useful rack testing helper methods, and define an `app` method that will return an instance of a Rack application when called.

  ```ruby
  ENV["RACK_ENV"] = "test"
  
  require "minitest/autorun"
  require "rack/test"
  
  require_relative "../cms.rb"
  
  class CMSTest < Minitest::Test
    include Rack::Test::Methods
  
    def app
      Sinatra::Application
    end
  
    # tests ...
  
  end
  ```

* Now we must write the appropriate tests. We have two routes, so we will want two tests.

* The first is our main homepage, or index page.

  ```ruby
  # ...
  
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
  ```

* The above test works, but it has a very static implementation. If we add another text file to our `data` directory, it will be displayed on our page but our test will become obsolete. There must be some way to employ interpolation but I'm not sure the best way to go about doing it.

* Let's write the other test.

  ```ruby
  # ...
  
  def test_filename
    index_body = <<~BODY
    
    BODY
    
    get "/:filename"
    assert_equal(200, last_response.status)
    assert_equal("text/plain", last_response["Content-Type"])
  end
  ```

* However, the above won't quite work because of the dynamic `"/:filename"`. I'm not sure how to deal with this.

#### LS Implementation

1. Add `minitest` and `rack-test` to the project's `Gemfile` and run `bundle install` to install them.
2. Create a `test` directory within the project. Inside that directory, create a file called `cms_test.rb` and add to it any testing setup code.
3. Write a test that performs a `GET` request to `/` and validates the response has a successful response and contains the names of the three documents.
4. Write a test that performs a `GET` request to `/history.txt` (or another document of your choosing) and validates the response is successful and contains some of the content of that document.

#### LS Solution

Gemfile:

```ruby
source "https://rubygems.org"

gem "sinatra"
gem "sinatra-contrib"
gem "erubis"

gem "minitest"
gem "rack-test"
```

`test/cms_test.rb`

```ruby
ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"

require_relative "../cms"

class CMSTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_index
    get "/"

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "about.txt"
    assert_includes last_response.body, "changes.txt"
    assert_includes last_response.body, "history.txt"
  end

  def test_viewing_text_document
    get "/history.txt"

    assert_equal 200, last_response.status
    assert_equal "text/plain", last_response["Content-Type"]
    assert_includes last_response.body, "Ruby 0.95 released"
  end
end
```

---

### Assignment 6: Handling Requests for Nonexistent Documents

#### Requirements

1. When a user attempts to view a document that does not exist, they should be redirected to the index page and shown the message: `$DOCUMENT does not exist.`.
2. When the user reloads the index page after seeing an error message, the message should go away.

#### My Implementation and Solution

* We will need to check to see if a file exist within the route that directs the client to the requested file.

* If the file exists then go ahead with the usual implementation; otherwise, the client should be redirected back to the index page. A flash message should appear: `$DOCUMENT does not exist.`.

* We should create a session error that gets triggered if the client must be redirected. `session[:error] = "$DOCUMENT does not exist."`.

* Within the index `get "/"` route, we should print out this error message if it exists and then delete it.

* First I need to include a `configure` method in the main `cms.rb` file in order to enable sessions.

  ```ruby
  configure do
    enable :sessions
    set :session_secret, 'secret'
  end
  ```

* Here is the updated `get "/:filename"` route:

  ```ruby
  get "/:filename" do
    file_path = root + "/data/" + params[:filename]
  
    if File.exist?(file_path)
      headers["Content-Type"] = "text/plain"
      File.read(file_path)
    else
      session[:error] = "#{params[:filename]} does not exist."
      redirect "/"
    end
  end
  ```

* Here is the updated `index.erb` file:

  ```ruby
  <% if session[:error] %>
    <p><%= session.delete(:error) %></p>
  <% end %>
  
  <ul>
    <% @files.each do |file| %>
      <li><a href="/<%= file %>"><%= file %></a></li>
    <% end %>
  </ul>
  ```

* Now we need to write a test to check to see if an error message is created.

* Here is the test:

  ```ruby
  def test_error_message
    get "/non_existent.txt"
  
    assert_equal(302, last_response.status)
  
    get "/"
    assert_equal(200, last_response.status)
    assert_includes(last_response.body, "non_existent.txt does not exist.")
  
    get "/"
    refute_includes(last_response.body, "non_existent.txt does not exist.")
  end
  ```

#### LS Implementation

1. Check to see if a file exists before attempting to read in its content.
2. Enable sessions in the application so we can persist data between requests.
3. If a document doesn't exist, store an error message in the session and redirect the user.
4. In the index template, if there is error message, print it out and delete it.

#### LS Solution

`cms.rb`

```ruby
...

configure do
  enable :sessions
  set :session_secret, 'super secret'
end

...

get "/:filename" do
  file_path = root + "/data/" + params[:filename]

  if File.file?(file_path)
    headers["Content-Type"] = "text/plain"
    File.read(file_path)
  else
    session[:message] = "#{params[:filename]} does not exist."
    redirect "/"
  end
end
```

`views/index.rb`

```ruby
<% if session[:message] %>
  <p><%= session.delete(:message) %></p>
<% end %>

<ul>
  <% @files.each do |file| %>
    <li><a href="/<%= file %>"><%= file %></a></li>
  <% end %>
</ul>
```

`test/cms_test.rb`

```ruby
def test_document_not_found
  get "/notafile.ext" # Attempt to access a nonexistent file

  assert_equal 302, last_response.status # Assert that the user was redirected

  get last_response["Location"] # Request the page that the user was redirected to

  assert_equal 200, last_response.status
  assert_includes last_response.body, "notafile.ext does not exist"

  get "/" # Reload the page
  refute_includes last_response.body, "notafile.ext does not exist" # Assert that our message has been removed
end
```

---

### Assignment 7: Viewing Markdown Files

Markdown is a common text-to-html markup language. You've probably encountered it here on Launch School, on Stack Overflow, GitHub, and other popular sites already.

Converting raw Markdown text into HTML can be done with a variety of libraries, many of which are available for use with a Ruby application. We recommend you use [Redcarpet](https://github.com/vmg/redcarpet) in this project. To get started, follow these steps:

1. Add `redcarpet` to your `Gemfile` and run `bundle install`.

2. Add `require "redcarpet"` to the top of your application.

3. To actually render text into HTML, create a `Redcarpet::Markdown` instance and then use it to process the text:

   ```ruby
   markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
   markdown.render("# This will be a headline!")
   ```

You can read more about how to use Redcarpet [on GitHub](https://github.com/vmg/redcarpet).

#### Requirements

1. When a user views a document written in Markdown format, the browser should render the rendered HTML version of the document's content.

#### My Implementation and Solution

* Create a `file.erb` views template. Make it so that the output will be conditional on whether the file is a markdown file or not. If it is a markdown then use the `markdown.render` implementation above. Otherwise just read the file as is.
* Will need to change the variable name in the `get "/:filename"` route to instance variables.
* My solution does not seem to be rendering properly. What is being rendered is a string of html code. The browser is not actually processing html but a string.

#### LS Implementation

1. Rename `about.txt` to `about.md` Add some Markdown-formatted text to this file.
2. Create a helper method called `render_markdown` that takes a single argument, the text to be processed, and returns rendered HTML.
3. When a user is viewing a file with the extension `md`, render the file's content using RedCarpet and return the result as the response's body.

#### LS Solution

`cms.rb`

```ruby
# cms.rb
require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "redcarpet"

configure do
  enable :sessions
  set :session_secret, 'super secret'
end

root = File.expand_path("..", __FILE__)

def render_markdown(text)
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  markdown.render(text)
end

def load_file_content(path)
  content = File.read(path)
  case File.extname(path)
  when ".txt"
    headers["Content-Type"] = "text/plain"
    content
  when ".md"
    render_markdown(content)
  end
end

get "/" do
  @files = Dir.glob(root + "/data/*").map do |path|
    File.basename(path)
  end
  erb :index
end

get "/:filename" do
  file_path = root + "/data/" + params[:filename]

  if File.exist?(file_path)
    load_file_content(file_path)
  else
    session[:message] = "#{params[:filename]} does not exist."
    redirect "/"
  end
end
```

`test/cms_test.rb`

```ruby
# test/cms_test.rb
def test_index
  get "/"

  assert_equal 200, last_response.status
  assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
  assert_includes last_response.body, "about.md"
  assert_includes last_response.body, "changes.txt"
  assert_includes last_response.body, "history.txt"
end

def test_viewing_markdown_document
  get "/about.md"

  assert_equal 200, last_response.status
  assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
  assert_includes last_response.body, "<h1>Ruby is...</h1>"
end
```

---

### Assignment 8: Editing Document Content

Now it’s time to allow users to modify the content stored within our CMS.

#### Requirements

1. When a user views the index page, they should see an “Edit” link next to each document name.
2. When a user clicks an edit link, they should be taken to an edit page for the appropriate document.
3. When a user views the edit page for a document, that document's content should appear within a textarea.
4. When a user edits the document's content and clicks a “Save Changes” button, they are redirected to the index page and are shown a message: `$FILENAME has been updated.`.

#### My Implementation

* Add an anchor tag to the `index.erb` view template for an "Edit" link.
* Create a new `get "/:filename/edit"` route in the `cms.rb` file.
* Create a new `edit.erb` view template.
* Create a new `post "/:filename/changes"` route in the `cms.rb` file; this will be the route for whenever the "Save Changes" button is pushed.

#### LS Implementation

1. Update `views/index.erb` to add edit links after each document name.
2. Create a new route for editing a document. Within this route, render a new view template that contains a form and a text area.
3. Create a new route for saving changes to the document. Within this route, update the contents of the appropriate document, add a message to the session, and redirect the user.

#### My Solution

`index.erb`

```ruby
<% if session[:message] %>
  <p><%= session.delete(:message) %></p>
<% end %>

<ul>
  <% @files.each do |file| %>
    <li><a href="/<%= file %>"><%= file %></a> <a href="/<%= file %>/edit">(Edit)</a></li>
  <% end %>
</ul>
```

`edit.erb`

```html
<p>Edit content of <%= @file_name %></p>
<form action="/<%= @file_name %>/change" method="post">
  <p><input value="<%= @content %>"/></p>
  <button type="submit">Save Changes</button>
</form>
```

`cms.rb`

```ruby
# ... rest of code omitted

get "/:filename/edit" do
  @file_name = params[:filename]
  file_path = root + "/data/" + @file_name
  @content = File.read(file_path)

  erb :edit
end

post "/:filename/change" do

  redirect "/"
end
```

#### LS Solution

```ruby
# cms.rb
get "/:filename/edit" do
  file_path = root + "/data/" + params[:filename]

  @filename = params[:filename]
  @content = File.read(file_path)

  erb :edit
end

post "/:filename" do
  file_path = root + "/data/" + params[:filename]

  File.write(file_path, params[:content])

  session[:message] = "#{params[:filename]} has been updated."
  redirect "/"
end
```

```html
<!-- views/edit.erb -->
<form method="post" action="/<%= @filename %>">
  <label for="content">Edit content of <%= @filename %>:</label>
  <div>
    <textarea name="content" id="content" rows="20" cols="100"><%= @content %></textarea>
  </div>
  <button type="submit">Save Changes</button>
</form>
```

```html
<!-- views.index.erb -->
<ul>
  <% @files.each do |file| %>
    <li>
      <a href="/<%= file %>"><%= file %></a>
      <a href="/<%= file %>/edit">edit</a>
    </li>
  <% end %>
</ul>
```

And for the tests:

```ruby
# test/cms_test.rb
def test_editing_document
  get "/changes.txt/edit"

  assert_equal 200, last_response.status
  assert_includes last_response.body, "<textarea"
  assert_includes last_response.body, %q(<button type="submit")
end

def test_updating_document
  post "/changes.txt", content: "new content"

  assert_equal 302, last_response.status

  get last_response["Location"]

  assert_includes last_response.body, "changes.txt has been updated"

  get "/changes.txt"
  assert_equal 200, last_response.status
  assert_includes last_response.body, "new content"
end
```

---

### Assignment 9: Isolating Test Execution

#### Implementation

1. Update the rest of the tests so they pass after making the changes described above.





