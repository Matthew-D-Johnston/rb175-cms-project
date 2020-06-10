#### RB175 Networked Applications > Project: File-based CMS

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

`cms_test.rb`

```ruby
# test/cms_test.rb
ENV["RACK_ENV"] = "test"

require "fileutils"

require "minitest/autorun"
require "rack/test"

require_relative "../cms"

class CMSTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    FileUtils.mkdir_p(data_path)
  end

  def teardown
    FileUtils.rm_rf(data_path)
  end

  def create_document(name, content = "")
    File.open(File.join(data_path, name), "w") do |file|
      file.write(content)
    end
  end

  def test_index
    create_document "about.md"
    create_document "changes.txt"

    get "/"

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "about.md"
    assert_includes last_response.body, "changes.txt"
  end

  def test_viewing_text_document
    create_document "history.txt", "Ruby 0.95 released"

    get "/history.txt"

    assert_equal 200, last_response.status
    assert_equal "text/plain", last_response["Content-Type"]
    assert_includes last_response.body, "Ruby 0.95 released"
  end

  def test_viewing_markdown_document
    create_document "about.md", "# Ruby is..."

    get "/about.md"

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "<h1>Ruby is...</h1>"
  end

  def test_document_not_found
    get "/notafile.ext"

    assert_equal 302, last_response.status

    get last_response["Location"]

    assert_equal 200, last_response.status
    assert_includes last_response.body, "notafile.ext does not exist"
  end

  def test_editing_document
    create_document "changes.txt"

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
end
```

`cms.rb`

```ruby
require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "redcarpet"

configure do
  enable :sessions
  set :session_secret, 'super secret'
end

def data_path
  if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/data", __FILE__)
  else
    File.expand_path("../data", __FILE__)
  end
end

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
  pattern = File.join(data_path, "*")
  @files = Dir.glob(pattern).map do |path|
    File.basename(path)
  end
  erb :index
end

get "/:filename" do
  file_path = File.join(data_path, params[:filename])

  if File.exist?(file_path)
    load_file_content(file_path)
  else
    session[:message] = "#{params[:filename]} does not exist."
    redirect "/"
  end
end

get "/:filename/edit" do
  file_path = File.join(data_path, params[:filename])

  @filename = params[:filename]
  @content = File.read(file_path)

  erb :edit
end

post "/:filename" do
  file_path = File.join(data_path, params[:filename])

  File.write(file_path, params[:content])

  session[:message] = "#{params[:filename]} has been updated."
  redirect "/"
end
```

---

### Assignment 10: Adding Global Style and Behaviour

When a message is displayed to a user anywhere on the site, it should be styled in a way that is easily distinguished from the rest of the page. This will help attract the user's attention to the information in the message that would otherwise be easy to miss.

While we're adding styling, we can also change the default display of the site to use a sans-serif font and have a little padding around the outside.

#### Requirements

1. When a message is displayed to a user, that message should appear against a yellow background.
2. Messages should disappear if the page they appear on is reloaded.
3. Text files should continue to be displayed by the browser as plain text.
4. The entire site (including markdown files, but not text files) should be displayed in a sans-serif typeface.

#### My Implementation and Solution

* In the `index.erb` file, modify the html `p` tag for the error message to include a `style` attribute that sets the `background-color` to `yellow`.

  ```html
  <% if session[:message] %>
    <p style="background-color:yellow;"><%= session.delete(:message) %></p>
  <% end %>
  ```

* We need to a way to implement the sans-serif typeface for the entire site except for when text files are displayed.

#### LS Implementation

1. Add the following CSS to a new file called `cms.css` in your project.

   ```css
   body {
     padding: 1em;
     font-family: sans-serif;
   }
   
   .message {
     padding: 10px;
     background: #FFFF99;
   }
   ```

2. Create a layout called `layout.erb`, and link to the `cms.css` file from it.

3. When viewing a text file, no surrounding HTML code should be sent in the response.

#### LS Solution

`views/layout.erb`

```html
<html>
  <title>CMS</title>
  <link href="/cms.css" rel="stylesheet" type="text/css" />
  <body>
    <% if session[:message] %>
      <p class="message"><%= session.delete(:message) %></p>
    <% end %>
    <%= yield %>
  </body>
</html>
```

`views/index.erb`

```html
<ul>
  <% @files.each do |file| %>
    <li>
      <a href="/<%= file %>"><%= file %></a>
      <a href="/<%= file %>/edit">edit</a>
    </li>
  <% end %>
</ul>
```

`public/cms.css`

```css
body {
  padding: 1em;
  font-family: sans-serif;
}

.message {
  padding: 10px;
  background: #FFFF99;
}
```

`cms.rb`

```ruby

...

def load_file_content(path)
  content = File.read(path)
  case File.extname(path)
  when ".txt"
    headers["Content-Type"] = "text/plain"
    content
  when ".md"
    erb render_markdown(content)
  end
end

...
```

---

### Assignment 11: Sidebar: Favicon Requests

Save [this image](https://da77jsbdz4r05.cloudfront.net/images/file_based_cms/favicon.ico) to the project's `public` directory, and the `favicon.ico` errors will go away. Browsers automatically request a file called `favicon.ico` when they load sites so they can show an icon for that site. By adding this file, the browser will show it in the page's tab and your application won't have to deal with ignoring those requests, as they can sometimes cause unexpected errors.

---

### Assignment 12: Creating New Documents

#### Requirements

1. When a user views the index page, they should see a link that says "New Document".
2. When a user clicks the "New Document" link, they should be taken to a page with a text input labeled "Add a new document:" and a submit button labeled "Create".
3. When a user enters a document name and clicks "Create," they should be redirected to the index page. The name they entered in the form should now appear in the file list. They should see a message that says `"$FILENAME was created."`, where ​`$FILENAME` is the name of the document just created.
4. If a user attempts to create a new document without a name, the form should be re-displayed and a message should say "A name is required."

#### My Implementation and Solution

* Add appropriate html to `index.erb` so that a link that says "New Document" is created.

  ```html
  <ul>
    <% @files.each do |file| %>
      <li>
        <a href="/<%= file %>"><%= file %></a>
        <a href="/<%= file %>/edit">edit</a>
      </li>
    <% end %>
  </ul>
  
  <p><a href="/new_document">New Document</a></p> # new code here
  ```

* Create a `get "/new_document"` route for the link in the `cms.rb` file.

  ```ruby
  get "/new_document" do
    erb :new_doc
  end
  ```

* Create a `new_doc.erb` views template.

  ```html
  <form method="post" action="">
    <label for="new_doc"> Add a new document:</label>
    <div>
      <textarea name="new_doc" id="new_doc"></textarea> <button type="submit">Create</button>
    </div>
  </form>
  ```

* Create a `post "/new_document"` route.
* This is where I'm a bit stuck.

#### LS Implementation

1. Add a new route that will handle rendering the new document form.
2. Add a view template and render it within the route created in #1. This template should include a form for entering the new document's name.
3. Add a link to the new route within the index view template.
4. Add a new route that the form from #2 will submit to.
   * If a filename is provided by the user, create the document, store the appropriate message in the session, and redirect the user to the index page.
   * If filename is not provided by the user, render the new form and display an error message.
5. Make sure the routes are setting an appropriate status code.

#### LS Solution

```html
<!-- views/new.erb -->
<form method="post" action="/create">
  <label for="filename">Add a new document:</label>
  <div>
    <input name="filename" id="filename" />
    <button type="submit">Create</button>
  </div>
</form>
```

```html
<!-- views/index.erb -->
<ul>
  <% @files.each do |file| %>
    <li>
      <a href="/<%= file %>"><%= file %></a>
      <a href="/<%= file %>/edit">edit</a>
    </li>
  <% end %>
</ul>

<p><a href="/new">New Document</a></p>
```

```ruby
# cms.rb
get "/new" do
  erb :new
end

post "/create" do
  filename = params[:filename].to_s

  if filename.size == 0
    session[:message] = "A name is required."
    status 422
    erb :new
  else
    file_path = File.join(data_path, filename)

    File.write(file_path, "")
    session[:message] = "#{params[:filename]} has been created."

    redirect "/"
  end
end
```

```ruby
# test/cms_test.rb
  def test_view_new_document_form
    get "/new"

    assert_equal 200, last_response.status
    assert_includes last_response.body, "<input"
    assert_includes last_response.body, %q(<button type="submit")
  end

  def test_create_new_document
    post "/create", filename: "test.txt"
    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_includes last_response.body, "test.txt has been created"

    get "/"
    assert_includes last_response.body, "test.txt"
  end

  def test_create_new_document_without_filename
    post "/create", filename: ""
    assert_equal 422, last_response.status
    assert_includes last_response.body, "A name is required"
  end
```

#### Questions

1. What will happen if a user creates a document without a file extension? How could this be handled?

#### Solution

Any file that doesn't have either a `txt` or `md` extension won't be displayed at all, since the `case` statement in `load_file_content` doesn't have an `else` clause:

```ruby
# cms.rb
def load_file_content(path)
  content = File.read(path)
  case File.extname(path)
  when ".txt"
    headers["Content-Type"] = "text/plain"
    content
  when ".md"
    erb render_markdown(content)
  end
end
```

Validating the value provided as a new document name would prevent this situation from occurring.

---

### Assignment 13: Deleting Documents

#### Requirements

1. When a user views the index page, they should see a "delete" button next to each document.
2. When a user clicks a "delete" button, the application should delete the appropriate document and display a message: "$FILENAME was deleted".

#### My Implementation and Solution

* Update the the `index.erb` view template to include a "delete" button next to each file.

  ```html
  <ul>
    <% @files.each do |file| %>
      <li>
        <a href="/<%= file %>"><%= file %></a>
        <a href="/<%= file %>/edit">edit</a>
        <button type="submit" method="delete" action="/<%= file %>">delete</button>
      </li>
    <% end %>
  </ul>
  
  <p><a href="/new">New Document</a></p>
  ```

* Add a `delete "/:filename"` route to the `cms.rb` file.

  ```ruby
  delete "/:filename" do
    file_path = File.join(data_path, params[:filename])
  
    File.delete(file_path)
  
    session[:message] = "#{params[:filename]} was deleted."
    redirect "/"
  end
  ```

#### LS Implementation

1. Add a form to each `li` within `views/index.erb`. This form needs to only contain a submit button.
2. Create a route that the forms created in #1 will submit to. Within this route, delete the appropriate document, store a message in the session, and redirect the user back to the index page.

#### LS Solution

```erb
<!-- views/index.erb -->
<ul>
  <% @files.each do |file| %>
    <li>
      <a href="/<%= file %>"><%= file %></a>
      <a href="/<%= file %>/edit">edit</a>
      <form class="inline" method="post" action="/<%= file %>/delete">
        <button type="submit">delete</button>
      </form>
    </li>
  <% end %>
</ul>

<p><a href="/new">New Document</a></p>
```

```css
/* public/cms.css */

...

form.inline {
  display: inline;
}
```

```ruby
# cms.rb
post "/:filename/delete" do
  file_path = File.join(data_path, params[:filename])

  File.delete(file_path)

  session[:message] = "#{params[:filename]} has been deleted."
  redirect "/"
end
```

```ruby
def test_deleting_document
  create_document("test.txt")

  post "/test.txt/delete"

  assert_equal(302, last_response.status)

  get last_response["Location"]
  assert_includes(last_response.body, "test.txt was deleted.")

  get "/"
  refute_includes(last_response.body, "test.txt")
end
```

---

### Assignment 14: Signing In and Out

Now that the content in our CMS can be modified and new documents can be created and deleted, we'd like to only allow registered users to be able to perform these tasks. To do that, though, first we'll need to have a way for users to sign in and out of the application.

#### Requirements

1. When a signed-out user views the index page of the site, they should see a "Sign In" button.
2. When a user clicks the "Sign In" button, they should be taken to a new page with a sign-in form. The form should contain a text input labeled "Username" and a password input labeled "Password". The form should also contain a submit button labeled "Sign In".
3. When a user enters the username "admin" and password "secret" into the sign in form and clicks the "Sign In" button, they should be signed in and redirected to the index page. A message should display that says "Welcome!".
4. When a user enters any other username and password into the sign-in form and clicks the "Sign In" button, the sign-in form should be redisplayed and an error message "Invalid Credentials" should be shown. The username they entered into the form should appear in the username input.
5. When a signed-in user views the index page, they should see a message at the bottom of the page that says "Signed in as $USERNAME.", followed by a button labeled "Sign Out".
6. When a signed-in user clicks this "Sign Out" button, they should be signed out of the application and redirected to the index page of the site. They should see a message that says "You have been signed out.".

#### My Implementation

* Update the `index.erb` view template to include a "Sign In" button, which when clicked should direct the user to a sign-in page.
* Update the `cms.rb` file to include a route for the sign-in page. Something like, `get "/users/signin"`. We will want to create a session variable to store the status of whether or not the user is signed in, such as `session[:signedin]`. This can be assigned a boolean value, `true` when the user is signed in and false when they are not signed in.
* Create a new `signin.erb` view template, which should include "Username:" and "Password:" labels for forms where users can input their credentials, and a "Sign In" button at the bottom. If the username and password are valid (i.e. "admin" and "secret") then the user should be redirected back to the index page. This should also store a session "Welcome!" message.
* If any other username or password are input into the sign-in form, clicking the "Sign In" button should result in an error message "Invalid Credentials". Update the template so that the username they entered appears in the username input.
* Update the `index.erb` view template so that it includes a message at the bottom of the screen that says "Signed in as $USERNAME.", followed by a button labeled "Sign Out". When the user clicks this button, the session message should be set to `"You have been signed out"` and the user should be redirected to the index page.

#### LS Implementation

1. Create a route that renders a view template containing a sign in form.
2. Create a route that the form from #1 submits to.
   * If the credentials are correct, store the username and the success message in the session and redirect to the index page.
   * If the credentials are not correct, rerender the sign in form and display an error message.
3. Add some code to the index page to display a "Sign In" or "Sign Out" button and message based on whether the user is signed in.
4. Create a route that deletes the username from the session, adds a message to the session, and redirects the user to the index page. Point the "Sign Out" button created in #3 at this route.

#### LS Solution

```erb
<!-- views/index.erb -->
<ul>
  <% @files.each do |file| %>
    <li>
      <a href="/<%= file %>"><%= file %></a>
      <a href="/<%= file %>/edit">edit</a>
      <form class="inline" method="post" action="<%= file %>/delete">
        <button type="submit">delete</button>
      </form>
    </li>
  <% end %>
</ul>

<p><a href="/new">New Document</a></p>

<% if session[:username] %>
  <form method="post" action="/users/signout">
    <p class="user-status">
      Signed in as <%= session[:username] %>.
      <button type="submit">Sign Out</button>
    </p>
  </form>
<% else %>
  <p class="user-status"><a href="/users/signin">Sign In</a></p>
<% end %>
```

```erb
<!-- views/signin.erb -->
<form method="post" action="/users/signin">
  <div>
    <label for="username"> Username:
      <input name="username" id="username" value="<%= params[:username] %>"/>
    </label>
  </div>
  <div>
    <label for="password"> Password:
      <input type="password" id="password" name="password" />
    </label>
  </div>
  <button type="submit">Sign In</button>
</form>
```

```ruby
# cms.rb

...

get "/users/signin" do
  erb :signin
end

post "/users/signin" do
  if params[:username] == "admin" && params[:password] == "secret"
    session[:username] = params[:username]
    session[:message] = "Welcome!"
    redirect "/"
  else
    session[:message] = "Invalid credentials"
    status 422
    erb :signin
  end
end

post "/users/signout" do
  session.delete(:username)
  session[:message] = "You have been signed out."
  redirect "/"
end
```

```css
/* public/cms.css */

...

.user-status {
  font-style: italic;
  font-size: 0.9em;
}
```

```ruby
# test/cms_test.rb
def test_signin_form
  get "/users/signin"

  assert_equal 200, last_response.status
  assert_includes last_response.body, "<input"
  assert_includes last_response.body, %q(<button type="submit")
end

def test_signin
  post "/users/signin", username: "admin", password: "secret"
  assert_equal 302, last_response.status

  get last_response["Location"]
  assert_includes last_response.body, "Welcome"
  assert_includes last_response.body, "Signed in as admin"
end

def test_signin_with_bad_credentials
  post "/users/signin", username: "guest", password: "shhhh"
  assert_equal 422, last_response.status
  assert_includes last_response.body, "Invalid credentials"
end

def test_signout
  post "/users/signin", username: "admin", password: "secret"
  get last_response["Location"]
  assert_includes last_response.body, "Welcome"

  post "/users/signout"
  get last_response["Location"]

  assert_includes last_response.body, "You have been signed out"
  assert_includes last_response.body, "Sign In"
end
```

---

### Assignment 15: Accessing the Session While Testing

#### LS Implementation

1. Update all existing tests to use the above methods for verifying session values. This means that many tests will become shorter as assertions can be made directly about the session instead of the content of a response's body. Specifically, instead of loading a page using `get` and then checking to see if a given message is displayed on it, `session[:message]` can be used to access the session value directly.

#### LS Solution

```ruby
ENV["RACK_ENV"] = "test"

require "fileutils"

require "minitest/autorun"
require "rack/test"

require_relative "../cms"

class CMSTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    FileUtils.mkdir_p(data_path)
  end

  def teardown
    FileUtils.rm_rf(data_path)
  end

  def create_document(name, content = "")
    File.open(File.join(data_path, name), "w") do |file|
      file.write(content)
    end
  end

  def session
    last_request.env["rack.session"]
  end

  def test_index
    create_document "about.md"
    create_document "changes.txt"

    get "/"

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "about.md"
    assert_includes last_response.body, "changes.txt"
  end

  def test_viewing_text_document
    create_document "history.txt", "Ruby 0.95 released"

    get "/history.txt"

    assert_equal 200, last_response.status
    assert_equal "text/plain", last_response["Content-Type"]
    assert_includes last_response.body, "Ruby 0.95 released"
  end

  def test_viewing_markdown_document
    create_document "about.md", "# Ruby is..."

    get "/about.md"

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "<h1>Ruby is...</h1>"
  end

  def test_document_not_found
    get "/notafile.ext"

    assert_equal 302, last_response.status
    assert_equal "notafile.ext does not exist.", session[:message]
  end

  def test_editing_document
    create_document "changes.txt"

    get "/changes.txt/edit"

    assert_equal 200, last_response.status
    assert_includes last_response.body, "<textarea"
    assert_includes last_response.body, %q(<button type="submit")
  end

  def test_updating_document
    post "/changes.txt", content: "new content"

    assert_equal 302, last_response.status
    assert_equal "changes.txt has been updated.", session[:message]

    get "/changes.txt"
    assert_equal 200, last_response.status
    assert_includes last_response.body, "new content"
  end

  def test_view_new_document_form
    get "/new"

    assert_equal 200, last_response.status
    assert_includes last_response.body, "<input"
    assert_includes last_response.body, %q(<button type="submit")
  end

  def test_create_new_document
    post "/create", filename: "test.txt"
    assert_equal 302, last_response.status
    assert_equal "test.txt has been created.", session[:message]

    get "/"
    assert_includes last_response.body, "test.txt"
  end

  def test_create_new_document_without_filename
    post "/create", filename: ""
    assert_equal 422, last_response.status
    assert_includes last_response.body, "A name is required"
  end

  def test_deleting_document
    create_document("test.txt")

    post "/test.txt/delete"
    assert_equal 302, last_response.status
    assert_equal "test.txt has been deleted.", session[:message]

    get "/"
    refute_includes last_response.body, %q(href="/test.txt")
  end

  def test_signin_form
    get "/users/signin"

    assert_equal 200, last_response.status
    assert_includes last_response.body, "<input"
    assert_includes last_response.body, %q(<button type="submit")
  end

  def test_signin
    post "/users/signin", username: "admin", password: "secret"
    assert_equal 302, last_response.status
    assert_equal "Welcome!", session[:message]
    assert_equal "admin", session[:username]

    get last_response["Location"]
    assert_includes last_response.body, "Signed in as admin"
  end

  def test_signin_with_bad_credentials
    post "/users/signin", username: "guest", password: "shhhh"
    assert_equal 422, last_response.status
    assert_nil session[:username]
    assert_includes last_response.body, "Invalid credentials"
  end

  def test_signout
    get "/", {}, {"rack.session" => { username: "admin" } }
    assert_includes last_response.body, "Signed in as admin"

    post "/users/signout"
    assert_equal "You have been signed out", session[:message]

    get last_response["Location"]
    assert_nil session[:username]
    assert_includes last_response.body, "Sign In"
  end
end
```

### Assignment 16: Restricting Actions to Only Signed-in Users

Adding the concept of signed-in users to this project allows the ability to restrict certain actions (those that result in changes to data) to only those signed-in users. This is a very common model in web applications, where guest (signed-out) users can access resources but not make any changes to them.

#### Requirements

1. When a signed-out user attempts to perform the following actions, they should be redirected back to the index and shown a message that says "You must be signed in to do that.":
   * Visit the edit page for a document
   * Submit changes to a document
   * Visit the new document page
   * Submit the new document form
   * Delete a document

#### My Implementation

* Update the `get "/:filename/edit"` route to include a conditional that will check to see if the user is signed in. This can be done by checking the `session` hash for the username. If there is no username then we will want to set the `session[:message]` to `"You must be signed in to do that."` and redirect back to the index page.
* We will want to update the rest of the routes that apply to the above actions with a similar process. Thus, we might want to defined a method that we can use and apply repetitively.

#### My Solution

```ruby
def not_signed_in_redirect
  session[:message] = "You must be signed in to do that."
  redirect "/"
end

# ...

get "/new" do
  not_signed_in_redirect if !session[:username]
  erb :new
end

# ...

get "/:filename/edit" do
  not_signed_in_redirect if !session[:username]

  file_path = File.join(data_path, params[:filename])

  @filename = params[:filename]
  @content = File.read(file_path)

  erb :edit
end

post "/create" do
  not_signed_in_redirect if !session[:username]

  filename = params[:filename].to_s

  if filename.size == 0
    session[:message] = "A name is required."
    status 422
    erb :new
  else
    file_path = File.join(data_path, filename)

    File.write(file_path, "")
    session[:message] = "#{params[:filename]} has been created."

    redirect "/"
  end
end

post "/:filename" do
  not_signed_in_redirect if !session[:username]

  file_path = File.join(data_path, params[:filename])

  File.write(file_path, params[:content])

  session[:message] = "#{params[:filename]} has been updated."
  redirect "/"
end

post "/:filename/delete" do
  not_signed_in_redirect if !session[:username]

  file_path = File.join(data_path, params[:filename])

  File.delete(file_path)

  session[:message] = "#{params[:filename]} has been deleted."
  redirect "/"
end
```

#### LS Implementation

1. Write a method that returns `true` or `false` based on if a user is signed in.
2. Write a method that checks the return value of the method created in #1 and, if a user is not signed in, stores a message in the session and redirects to the index page.
3. Call the method created in #2 at the beginning of actions that only signed-in users should access.
4. Add additional tests to verify that signed-out users are handled properly.

#### LS Solution

```ruby
# cms.rb
def user_signed_in?
  session.key?(:username)
end

def require_signed_in_user
  unless user_signed_in?
    session[:message] = "You must be signed in to do that."
    redirect "/"
  end
end

...

get "/new" do
  require_signed_in_user

  erb :new
end

post "/create" do
  require_signed_in_user

  filename = params[:filename].to_s

  if filename.size == 0
    session[:message] = "A name is required."
    status 422
    erb :new
  else
    file_path = File.join(data_path, filename)

    File.write(file_path, "")
    session[:message] = "#{params[:filename]} has been created."

    redirect "/"
  end
end

...

get "/:filename/edit" do
  require_signed_in_user

  file_path = File.join(data_path, params[:filename])

  @filename = params[:filename]
  @content = File.read(file_path)

  erb :edit
end

post "/:filename" do
  require_signed_in_user

  file_path = File.join(data_path, params[:filename])

  File.write(file_path, params[:content])

  session[:message] = "#{params[:filename]} has been updated."
  redirect "/"
end

post "/:filename/delete" do
  require_signed_in_user

  file_path = File.join(data_path, params[:filename])

  File.delete(file_path)

  session[:message] = "#{params[:filename]} has been deleted."
  redirect "/"
end
```

```ruby
# test/cms_test.rb
def admin_session
  { "rack.session" => { username: "admin" } }
end

...

def test_editing_document
  create_document "changes.txt"

  get "/changes.txt/edit", {}, admin_session

  assert_equal 200, last_response.status
  assert_includes last_response.body, "<textarea"
  assert_includes last_response.body, %q(<button type="submit")
end

def test_editing_document_signed_out
  create_document "changes.txt"

  get "/changes.txt/edit"

  assert_equal 302, last_response.status
  assert_equal "You must be signed in to do that.", session[:message]
end

def test_updating_document
  post "/changes.txt", {content: "new content"}, admin_session

  assert_equal 302, last_response.status
  assert_equal "changes.txt has been updated.", session[:message]

  get "/changes.txt"
  assert_equal 200, last_response.status
  assert_includes last_response.body, "new content"
end

def test_updating_document_signed_out
  post "/changes.txt", {content: "new content"}

  assert_equal 302, last_response.status
  assert_equal "You must be signed in to do that.", session[:message]
end

def test_view_new_document_form
  get "/new", {}, admin_session

  assert_equal 200, last_response.status
  assert_includes last_response.body, "<input"
  assert_includes last_response.body, %q(<button type="submit")
end

def test_view_new_document_form_signed_out
  get "/new"

  assert_equal 302, last_response.status
  assert_equal "You must be signed in to do that.", session[:message]
end

def test_create_new_document
  post "/create", {filename: "test.txt"}, admin_session
  assert_equal 302, last_response.status
  assert_equal "test.txt has been created.", session[:message]

  get "/"
  assert_includes last_response.body, "test.txt"
end

def test_create_new_document_signed_out
  post "/create", {filename: "test.txt"}

  assert_equal 302, last_response.status
  assert_equal "You must be signed in to do that.", session[:message]
end

def test_create_new_document_without_filename
  post "/create", {filename: ""}, admin_session
  assert_equal 422, last_response.status
  assert_includes last_response.body, "A name is required"
end

def test_deleting_document
  create_document("test.txt")

  post "/test.txt/delete", {}, admin_session
  assert_equal 302, last_response.status
  assert_equal "test.txt has been deleted.", session[:message]

  get "/"
  refute_includes last_response.body, %q(href="/test.txt")
end

def test_deleting_document_signed_out
  create_document("test.txt")

  post "/test.txt/delete"
  assert_equal 302, last_response.status
  assert_equal "You must be signed in to do that.", session[:message]
end
```

---

### Assignment 17: Storing User Accounts in an External File

#### Requirements

1. An administrator should be able to modify the list of users who may sign into the application by editing a configuration file using their text editor.

#### My Implementation and Solution

* Add a `users.yaml` file to the `public` directory.

  ```yaml
  ---
  bill: "secret1"
  sonia: "secret2"
  ...
  ```

* Update files allowing usernames and passwords that exist in the `yaml` file to sign in and sign out.
* There should be an "edit user list" page that is only accessible to the administrator. This page will allow the user to edit which users can sign in and out.

#### LS Implementation

1. Create a file called `users.yml` and add a few users to it. Use the format specified above in the hint.
2. When a user is attempting to sign in, load the file created in #1 and use it to validate the user's credentials.
3. Modify the application to use `test/users.yml` to load user credentials during testing.

#### LS Solution

```ruby
# cms.rb
require "yaml"

...

def load_user_credentials
  credentials_path = if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/users.yml", __FILE__)
  else
    File.expand_path("../users.yml", __FILE__)
  end
  YAML.load_file(credentials_path)
end

...

post "/users/signin" do
  credentials = load_user_credentials
  username = params[:username]

  if credentials.key?(username) && credentials[username] == params[:password]
    session[:username] = username
    session[:message] = "Welcome!"
    redirect "/"
  else
    session[:message] = "Invalid credentials"
    status 422
    erb :signin
  end
end
```

```yaml
# users.yml
---
developer: letmein
```

```ruby
# test/users.yml
---
admin: secret
```

---

### Assignment 18: Storing Hashed Passwords

#### Requirements

1. User passwords must be hashed using bcrypt before being stored so that raw passwords are not being stored anywhere.

#### LS Implementation

1. Use `irb` to calculate hashed versions of the passwords that appear in `users.yml` and `test/users.yml`. Replace the passwords in these files with a hashed version.
2. Update the code that checks a user's username and password in `cms.rb` to use the `BCrypt` class to compare.

#### LS Solution

```ruby
# Gemfile
source "https://rubygems.org"

gem "sinatra"
gem "sinatra-contrib"
gem "erubis"
gem "bcrypt"

gem "minitest"
gem "rack-test"
```

```ruby
# cms.rb

...

require "bcrypt"

def valid_credentials?(username, password)
  credentials = load_user_credentials

  if credentials.key?(username)
    bcrypt_password = BCrypt::Password.new(credentials[username])
    bcrypt_password == password
  else
    false
  end
end

...

post "/users/signin" do
  username = params[:username]

  if valid_credentials?(username, params[:password])
    session[:username] = username
    session[:message] = "Welcome!"
    redirect "/"
  else
    session[:message] = "Invalid credentials"
    status 422
    erb :signin
  end
end
```

---

### Next Steps:

#### 1. Validate that document names contain an extension that the application supports.

#### Implementation

* Update the `if` conditional statement in the `post "/create"` route to include an `else` conditional that will check to ensure that the document extension is either a `.txt` or `.md` extension.

  ```ruby
  # ... 
  
  def invalid_extension?(filename)
  	return true unless filename =~ (/.txt$|.md$/)
  end
  
  # ...
  
  post "/create" do
    require_signed_in_user
  
    filename = params[:filename].to_s
  
    if filename.size == 0
      session[:message] = "A name is required."
      status 422
      erb :new
    elsif invalid_extension?(filename)
      session[:message] = "Document type not supported (only .txt and .md supported)."
      status 422
      erb :new
    else
      file_path = File.join(data_path, filename)
  
      File.write(file_path, "")
      session[:message] = "#{params[:filename]} has been created."
  
      redirect "/"
    end
  end
  ```

---

#### 2. Add a "duplicate" button that creates a new document based on an old one.

#### Implementation

* Update the `index.erb` view template to include a "duplicate" button.

  ```erb
  <form class="inline" method="post" action="/<%= file %>/duplicate">
  	<button type="submit">duplicate</button>
  </form>
  ```

* Add a `post "/:filename/duplicate"` route to the `cms.rb` file. Load the file content for the file and store it to a new name that includes a "(dup)" in it.

  ```ruby
  post "/:filename/duplicate" do
    require_signed_in_user
    
    file_path = File.join(data_path, params[:filename])
    file_ext = File.extname(file_path)
    file_name = File.basename(file_path, file_ext)
    
    duplicate_name = "#{file_name}(dup)#{file_ext}"
    dup_file_path = File.join(data_path, duplicate_name)
    
    file_content = load_file_content(file_path)
    
    File.write(dup_file_path, file_content)
    session[:message] = "#{file_name} duplicate has been created."
    
    redirect "/"
  end
  ```

---

#### 3. Extend this project with a user signup form.

#### Implementation

* Update the `index.erb` view to include a "New User Signup" link.

  ```erb
  # ...
  
  <% else %>
    <p class="user-status"><a href="/users/signin">Sign In</a></p>
    <p class="user-status"><a href="/users/signup">New User Sign Up</a></p>
  <% end %>
  ```

* Add a `get "/users/signup"` route. Within the route, render a `signup.erb` view template. Template should include input box for username and password. 

  ```erb
  <h3>New User Signup</h3>
  <form method="post" action="/users/signin">
    <div>
      <label for="username"> Username:
        <input name="username" id="username" value="<%= params[:username] %>"/>
      </label>
    </div>
    <div>
      <label for="password"> Password:
        <input type="password" id="password" name="password" />
      </label>
    </div>
    <button type="submit">Submit</button>
  </form>
  ```

* Add a `post "/users/signup"` route. Within the route, set a new session message to declare that the new user was created. Redirect the user back to the `/` home page. One should now be able to sign in as the newly created user.

  ```ruby
  post "/users/signup" do
    username = params[:username]
    password = params[:password]
    hashed_password = BCrypt::Password.create(password)
    
    credentials = load_user_credentials
  
    if credentials.key?(username)
      session[:message] = "Sorry, that username already exists."
      redirect "users/signup"
    else
      credentials[username] = hashed_password
      credentials_path = File.expand_path("../users.yml", __FILE__)
      File.open(credentials_path, "w") { |file| file.write(credentials.to_yaml) }
  
      session[:message] = "#{username} was added to the user database."
      redirect "/"
    end
  end
  ```

---

#### 4. Add the ability to upload images to the CMS (which could be referenced within markdown files).

#### Implementation

* Update the `invalid_extension?(filename)` method in the `cms.rb` file to allow for `.jpg`, `.jpeg` and `.png` files to be accepted.

  ```ruby
  def invalid_extension?(filename)
    return true unless filename =~ (/.txt$|.md$|.jpg$|.jpeg$|.png$/)
  end
  ```

* Update the `load_file_content(path)` method in the `cms.rb` file in order to render image files.

  ```ruby
  def load_file_content(path)
    content = File.read(path)
    case File.extname(path)
    when ".txt"
      headers["Content-Type"] = "text/plain"
      content
    when ".md"
      erb render_markdown(content)
    when ".jpeg"
      headers["Content-Type"] = "image/jpeg"
      content
    when ".jpg"
      headers["Content-Type"] = "image/jpg"
      content
    when ".png"
      headers["Content-Type"] = "image/png"
      content
    end
  end
  ```

---

#### 5. Modify the CMS so that each version of a document is preserved as changes are made to it.

#### Implementation

* Whenever a document is edited, create a duplicate of the document and save it with `(original)` and a time stamp added to the documents name.

* Update `post "/:filename" do` route so that a duplicate file is created whenever the "Save Changes" button is clicked.

  ```ruby
  post "/:filename" do
    require_signed_in_user
  
    time = Time.new
  
    file_path = File.join(data_path, params[:filename])
    file_ext = File.extname(file_path)
    file_name = File.basename(file_path, file_ext)
    
    duplicate_name = "#{file_name}(org_#{time.strftime("%m_%d_%Y")})#{file_ext}"
    dup_file_path = File.join(data_path, duplicate_name)
    
    FileUtils.cp(file_path, dup_file_path)
  
    File.write(file_path, params[:content])
  
    session[:message] = "#{params[:filename]} has been updated."
    redirect "/"
  end
  ```

---

