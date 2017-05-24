# <img src="https://cloud.githubusercontent.com/assets/7833470/10899314/63829980-8188-11e5-8cdd-4ded5bcb6e36.png" height="60"> Public Library App

### Part 1: Users & Auth

### Setup

Create a new rails app without tests and with a PostgreSQL database:


```bash
rails new lib-app -T -d postgresql
cd lib-app
```


Create the databases:

``` bash
rails db:create
```



## Routeside-in Development

Rails recommends "routeside-in" development - starting with a RESTful route and an idea of what that route should do, then working through everything else required to enable that route!

Because Rails errors are famously helpful, you can also think of this as "error driven development" to some extent. When you're setting up a simple Rails app, errors will guide you to writing everything you need.

### The homepage ('/') should show how many users are signed up.

Let's start with a route for `root`, which is just a helper method in Rails for `/`.


`config/routes.rb`

```ruby
Rails.application.routes.draw do
  root to: 'users#index'
end
```


We can look at how these routes are interpreted by Rails.

```bash
rails routes
```

Which should give us the following routes:

```bash
Prefix Verb URI Pattern      Controller#Action
  root GET  /                users#index
```

If we're working routeside-in, the question now is **what to do next?** There are a few ways to figure this out. We could go to our new home page in the browser and see a helpful error message. Just looking at the output we have so far, you may notice we don't have a `users#index`. We don't even have a `UsersController`.

Let's practice using our `rails generate` skills to create a users controller and associated files.


```bash
rails g controller users
```

This does something like the following:

```bash
***   create  app/controllers/users_controller.rb
      invoke  erb
***   create    app/views/users
      invoke  helper
 **   create    app/helpers/users_helper.rb
      invoke  assets
      invoke    coffee
 **    create      app/assets/javascripts/users.coffee
      invoke    scss
 **   create      app/assets/stylesheets/users.scss
```

Note the special `create` statements here. The `***` ones are the most important. It creates the `users_controller.rb` file and the `views/users` directory.


Now that we have a `users_controller.rb` we should add our `users#index` method.

```ruby
class UsersController < ApplicationController

  def index
  end

end
```


Now, if you visit the site in your browser, you may see an error about a missing template! We need to actually create a `users/index.html.erb` view template for this route to render:

```bash
touch app/views/users/index.html.erb
```


Then we can go ahead and add some actual content to our `index` - the count of users:


```html
<h1>Welcome to Users Index.</h1>

<div>
There are currently <%= @users.length %> user(s) signed up!
</div>
```


Check that root route in the browser again.  Uh-oh! If you have an error, pop back over to the controller and make sure we have the right data available for the view:

```rb
class UsersController < ApplicationController

  def index
    @users = User.all
  end

end
```


But wait! If you go to `localhost:3000` after this step (like you should be!), we have a problem. No `User` model.

Generate a `User` model with `email`, `first_name`, `last_name`, and `password_digest` strings. 


```bash
rails g model user email:string first_name:string last_name:string password_digest:string
```


Then go ahead and verify that the migration looks correct:


sample `db/migrate/201575943834_create_users.rb`:

`db/migrate/201675943834_create_users.rb`

```ruby
class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :password_digest

      t.timestamps
    end
  end
end
```

We're ready to migrate!

```bash
rails db:migrate
```

Ok, now we should see `0` users signed up on the home page.  

That makes sense because there's no way to sign up yet.  **YET.**

> Optionally, you can add a new `GET /users` route that also uses the `users#index` controller action.

### The ' GET /users/new' route should show a signup form.

Create this route. Remember to set up the proper prefix. 


```ruby

Rails.application.routes.draw do
  root to: 'users#index'

  get '/users/new', to: 'users#new', as: 'new_user'
end
```


Check that you get the following output from `rails routes`:

```bash
  Prefix Verb URI Pattern          Controller#Action
    root GET  /                    users#index
new_user GET  /users/new(.:format) users#new
```

We don't have a `users#new` controller action, so let's create one. If you'd like, you can go ahead and fill it in so it gets the data for the form view.


```ruby

class UsersController < ApplicationController

  #...

  def new
    # we make a new user
    # to pass to the form view later
    @user = User.new
  end


```


Then we can continue on to creating a `new.html.erb` view for the sign up form:


```
touch app/views/users/new.html.erb
```


In that file, use `form_for @user` to create a sign up form. 

```html
Sign Up

<%= form_for @user do |f| %>
  <div>
    <%= f.text_field :first_name, placeholder: "First Name" %>
  </div>
  <div>
    <%= f.text_field :last_name, placeholder: "Last Name" %>
  </div>
  <div>
    <%= f.text_field :email, placeholder: "Email" %>
  </div>
  <div>
    <%= f.password_field :password, placeholder: "Password" %>
  </div>
  <%= f.submit "Sign Up" %>
<% end %>
```


Visit `/users/new` in your browser.  You should see a form. Inspect it to see that the `form_for` helper renders a form like the following (note the authenticity token):

```html
Sign Up

<form class="new_user" id="new_user" action="/users" accept-charset="UTF-8" method="post"><input name="utf8" type="hidden" value="✓">
  <input type="hidden" name="authenticity_token" value="6EhU37Nz3gcbL8UsJL6Q868ZOI0a/UWJ2GLMOdu4fuiMEb8y8AthB6t032Of4seUgI0NMv8wOPPNPZ/eFOkNfw==">
  <div>
    <input placeholder="First Name" type="text" name="user[first_name]" id="user_first_name">
  </div>
  <div>
    <input placeholder="Last Name" type="text" name="user[last_name]" id="user_last_name">
  </div>
  <div>
    <input placeholder="Email" type="text" name="user[email]" id="user_email">
  </div>
  <div>
    <input placeholder="Password" type="password" name="user[password]" id="user_password">
  </div>
  <input type="submit" name="commit" value="Sign Up" data-disable-with="Sign Up">
</form>
```

Note here the correlation between the symbol we put into `f.text_field` and `name="..."` in the generated form.



Note what kind of request this form will make and the path it's going to.

```html
<form class="new_user" id="new_user" action="/users" accept-charset="UTF-8" method="post">
```

What error do you see if you try to submit this form in the browser now?

It looks like this form is sending `POST /USERS`. Do we have a route for that?

**Having doubts?  "Rails" your routes!**

### A POST to /users should create a new user in the database.

We don't have that route, so set it up next.


```ruby
Rails.application.routes.draw do
  root to: 'users#index'

  get '/users/new', to: 'users#new', as: 'new_user'
  post '/users', to: 'users#create'
end
```


Running `rails routes` should now show:

```
  Prefix Verb URI Pattern          Controller#Action
    root GET  /                    users#index
new_user GET  /users/new(.:format) users#new
   users POST /users(.:format)     users#create
```

Then, add the `create` action in the users controller. Remember to use strong parameters. (Bonus for separating these into a private method.)


```ruby
class UsersController < ApplicationController

  # ...

  def create
    @user = User.create(user_params)
    redirect_to root_path
  end


  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password)
  end

end
```


Now when you submit the form, you probably get the following error:

```
ActiveRecord::Unknown
AttributeError in UsersController#create

unknown attribute 'password' for User.
```

Oops! Don't we need users to submit passwords to sign up??

No! We only have a `password_digest` in our user model, and we'll only store a `password_digest` in our database. This `password_digest` will be a salted and hashed (obfuscated) version of the user's acutal password. 

We actually haven't set up any authentication logic yet -- part of this logic will be turning the plain password the user enters into a password digest that is safe to store in our database.


Uncomment your `bcrypt` in your `Gemfile`:


`Gemfile`

```ruby
...

# Use ActiveModel has_secure_password
gem 'bcrypt'

...
```

Once bcrypt is added, we can use the `has_secure_password` method in our user model:

```ruby
class User < ApplicationRecord
  has_secure_password
end
```


Reload the page to make sure this hasn't caused any errors.

We changed the Gemfile by bringing in `bcrypt` - did you remember to `bundle install`? You may also need to restart your server. 


Now when we post the form for the user, you'll see the user being created. The difference now is that the password is being properly hashed and salted into a `password_digest`, so it's safe to store.  Thanks for `has_secure_password`, Rails!



### The `GET /users/:id` route should show a view with all of the information about the user with id `:id`.

Now we'll add a route to `GET /users/:id`.

```ruby

Rails.application.routes.draw do
  root to: 'users#index'

  get '/users/new', to: 'users#new', as: 'new_user'
  post '/users', to: 'users#create'
  get '/users/:id', to: 'users#show', as: 'user'
end

```

Guess what fun error you'll get later if you put the `/users/:id` route before the `/users/new` route!


Rails routes!

```
  Prefix Verb URI Pattern          Controller#Action
    root GET  /                    users#index
new_user GET  /users/new(.:format) users#new
   users POST /users(.:format)     users#create
    user GET  /users/:id(.:format) users#show
```

Also  add a `users#show` controller action.


```ruby

class UsersController < ApplicationController
  #...
  def show
    @user = User.find_by_id(params[:id])
  end

end

```


Try visiting `/users/1` in the browser.  We need a `users/show.html.erb` to display the user's information.


```bash
touch app/views/users/show.html.erb
```

```html

<div>
  Welcome, <%= @user.first_name %>!
</div>

```


Let's test what we've got so far by going to the show page of an existing user in the browser.

## Managing Sessions for Existing Users

Now that we can create a user, we need to let existing users log in and out.

### The GET /login route should show a form to log in.

Logging in and logging out out is a concern of a new controller, the sessions controller.


```ruby

Rails.application.routes.draw do

  #...

  get '/login', to: 'sessions#new'

end

```

**Self-check for understanding**: Justify the choice to use `sessions#new` for the log in form.

**Self-check for understanding**: Which `sessions` controller action will we use to actually set the session and log the user in?

**Self-check for understanding**: Which `sessions` controller action will we use to log out?


Let's generate the new controller.

```
rails g controller sessions --no-assets
```

This will create  `sessions_controller.rb`, `sessions_helper.rb` and a `views/sessions/` directory, but it will skip adding `app/assets/javascripts/sessions.coffee` and `app/assets/stylesheets/sessions.scss`.


Now we need to add the `sessions#new` action. This will just show a log in form that takes a user's password and email. 


```ruby

class SessionsController < ApplicationController

  def new
    @user = User.new
  end

end
```


Then we need to add a view for the `sessions/new.html.erb`:


```bash
touch app/views/sessions/new.html.erb
```




This login form can look very similar to the form for sign in, but we'll need to be a little more specific about the `form_for` line, but it only needs email and password fields:


```html

Login

<%= form_for @user, url: "/sessions", method: "post" do |f| %>
  <div>
    <%= f.text_field :email, placeholder: "Email" %>
  </div>
  <div>
    <%= f.password_field :password, placeholder: "Password" %>
  </div>
  <%= f.submit "Log In" %>
<% end %>

```


Try using an `email_field` for some built-in client side validataions and a `password_field` to obscure the password as the user types.

Verify that you can see the log in form.  What error do you get when you submit?

### POSTing to /sessions should log a user in if the email/password combination was correct.

Note that the form is getting submited to `POST /sessions`. We don't have a `sessions#create` however or a route to handle the post.


```ruby

Rails.application.routes.draw do

  # ...

  get '/login', to: 'sessions#new'
  post '/sessions', to: 'sessions#create'

end
```


Verify your routes:

```
    root GET  /                    users#index
new_user GET  /users/new(.:format) users#new
   users POST /users(.:format)     users#create
    user GET  /users/:id(.:format) users#show
   login GET  /login(.:format)     sessions#new
sessions POST /sessions(.:format)  sessions#create
```

Note that the `POST /sessions` route has automatically been assigned the prefix `sessions`. This may seem odd, but its url or path (`sessions_path`, `"/sessions"`) is actually the same as the `sessions#index` route where we'd usually expect to see this prefix. That said, we won't use the prefix in our code. 


Now let's add the `sessions#create` controller action. It should log the user in by saving their id into the session.

This will involve:
- creating a `User.confirm` method in the user model
- creating `login` and `current_user` helper methods in the sessions helpers file
- including the session helper methods in the application controller


```ruby

class SessionsController < ApplicationController

  def create
    user_params = params.require(:user).permit(:email, :password)
    # confirm that email/password combination is correct
    @user = User.confirm(user_params)
    if @user
      login(@user)
      redirect_to @user
    else
      redirect_to login_path
    end
  end
end
```


HOLD THE HORSES! What is `User.confirm`?  The comment claims to tell us what it's doing, but where did it come from? Is this a built-in model method? Does it come with `has_secure_password`??

Nope, it's something we suggest you add to your `User` model as a custom model method.  This will make your code more modular.



Before we go forward let's go ahead and drop in a very key piece of confirmation logic into our `User` model. Create a `confirm` class method that checks whether the email and password from the parameters are a matching pair.   Use `authenticate` from `has_secure_password`.


```ruby
class User < ApplicationRecord
  has_secure_password

  def self.confirm(params)
    @user = User.find_by({email: params[:email]})
    @user ? @user.authenticate(params[:password]) : false
  end
end
```

HOLD THOSE HORSES!  What's up with ` ?  : `?  Don't worry, it's just your friendly neighborhood ternary operator.  It's keeping us from trying to call `@user.authenticate` when the `@user` is `nil`.  

BUT WOOAH, HORSES!  What is `@user.authenticate`?!? Where does that come from?  What is it doing?  Hint: [`has_secure_password`](http://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password).



You can test this is working by trying it out in your rails console:

```bash
rails c
> reload! # use this if you already had the console open
> User.confirm({email: "test@test.com", password: "123"})
> User.confirm({email: "test@test.com", password: "WRONG"})
```

Try with an existing correct email/password combination and with an incorrect password/email combination. 


Okay, back to the `sessions#create` action.  If we confirm this is an authentic user, we should log them in. Write code that logs in confirmed users and sends them to their show page, and write code that redirects non-confirmed visitors to the login path. (You may want to create and use a `login` session helper method). 


```ruby

class SessionsController < ApplicationController

  def create
    user_params = params.require(:user).permit(:email, :password)
    # confirm that email/password combination is correct
    @user = User.confirm(user_params)
    if @user
      login(@user)
      redirect_to @user
    else
      redirect_to login_path
    end
  end
end
```

HORSE, STOP!  What the heck is this `login` method?  It's a method we suggest you add to the helper methods for this controller. 



Find the sessions helper file and add:

```ruby

module SessionsHelper

  def login(user)
    session[:user_id] = user.id
    @current_user = user
  end

  def current_user
    @current_user ||= User.find_by_id(session[:user_id])
  end

end
```

Note that we've also snuck in a  `@current_user` instance variable and `current_user` method. This is so we can look up the logged in user from the session later, like in views.

Before we can use the methods, though, we have to add these methods to the `ApplicationController`.

```ruby

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include SessionsHelper
end

```

Now try to log in using the form, both with a correct email/password combination and an incorrect one.  Do you see a welcome when you use the correct information? And do you see the log in form again if you enter the wrong one (hm, a flash message would be nice here)? If so, you're ready to continue. Otherwise, you should start debug before moving on.

### Refactor: Signing up should also log a user in.

After a user is signed up they should be logged in. Thank goodness we have a convenient `login` helper to keep our code DRY! Refactor the controller action that handles signing up so that it calls this `login` method for the new user and redirects to the user show page. 


```ruby

class UsersController < ApplicationController

  def create
    @user = User.create(user_params)
    login(@user) # <-- log the user in
    redirect_to @user # <-- go to show
  end

end

```


Try signing up - you should see the welcome message from the user show page. 

### The GET /logout route should log the user out.

Start with the route! We'll use the `sessions#destroy` controller action to handle logging out. 


```ruby
Rails.application.routes.draw do
  # ...
  get '/login', to: 'sessions#new'
  get '/logout', to: 'sessions#destroy'
  post '/sessions', to: 'sessions#create'
end
```


Run `rails routes`!

```
  Prefix Verb URI Pattern          Controller#Action
    root GET  /                    users#index
new_user GET  /users/new(.:format) users#new
   users POST /users(.:format)     users#create
    user GET  /users/:id(.:format) users#show
   login GET  /login(.:format)     sessions#new
sessions POST /sessions(.:format)  sessions#create
```


We decided to use `sessions#destroy` because all of the information that's keeping a user logged in is in the user's session.

Strictly speaking, it isn't RESTful to do a destroy with the `GET` method (it should be `DELETE`). However, it's super convenient to do log out this way so we can add a log out link on each page. 


The `sessions#destroy` controller action needs to clear the `user_id` from the session. This is a great time to start thinking about using a `logout` session helper method, too. 


```ruby
class SessionsController < ApplicationController
    ...

    def destroy
      logout # coming soon in SessionsHelper
      redirect_to root_path
    end

end
```


Let's go ahead and add that `logout` helper method to correspond to the `login` we wrote before.


```ruby
module SessionsHelper

  def login(user)
    session[:user_id] = user.id
    @current_user = user
  end

  def current_user
    @current_user ||= User.find_by_id(session[:user_id])
  end

  def logout
    @current_user = session[:user_id] = nil
  end

end
```


Now we can go directly to the `/logout` URL to log out (delete the session user_id), but we should also have a "Log Out" button somewhere.

Even better would be a navbar with all the login/signup/logout options. Let's add a very simple list of navigation links to `views/layouts/application.html.erb` with some conditional logic, depending on whether we have a current user logged in:


```html
<body>
  <ul>
    <% if current_user %>
      <li><%= link_to "Profile", user_path(current_user) %></li>
      <li><%= link_to "Log Out", logout_path %></li>
    <% else %>
      <li><%= link_to "Create Account", new_user_path %></li>
      <li><%= link_to "Log In", login_path %></li>
    <% end %>
  </ul>

<%= yield %>
<!-- ... -->
</body>

```


Go ahead and check all your links are working (try it both logged in and logged out).

As a final touch, let's add "flash" messages to inform the user that they are "Successfully logged in" and "Successfully logged out". Start by setting up the flash messages in the controller. 


``` ruby
class SessionsController < ApplicationController
  # ...

  def create
    user_params = params.require(:user).permit(:email, :password)
    @user = User.confirm(user_params)
    if @user
      login(@user)
      flash[:notice] = "Successfully logged in."      # <--- Add this flash notice
      redirect_to @user
    else
      flash[:error] = "Incorrect email or password."  # <--- Add this flash error
      redirect_to login_path
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = "Successfully logged out."        # <--- Add this flash notice
    redirect_to root_path
  end

end
```


Update `views/layouts/application.html.erb` to display the messages.


``` html
<body>
<!-- ... -->
<% flash.each do |name, msg| %>
  <p>
    <small> <%= name.capitalize %>: <%= msg %> </small>
  </p>
<% end %>
<!-- ... -->
<%= yield %>

</body>
```


Try logging in with correct and incorrect information, and try logging out. Ensure that these are working. 


Nice work! We're finished with Authentication!



### Practice!

Now  do it all again!!!  This time, don't use "user" as your user object - try "gymgoers", "moms", "singers", "tacos" or whatever you'd like - just no users allowed. The point is that we want you to build this again with a critical eye for the name of the model and the name of the variables. You can't just copy/paste, you'll need to make informed decisions about how to replicate the functionality. Once you've completed the app to this level another time, you can move on to any bonuses you're interested in below.


## Bonus

1. On the profile page, display when the user created their account. To format the date, use Ruby's built in time formatter, [strftime](http://ruby-doc.org/core-2.2.0/Time.html#method-i-strftime).

1.  Right now, all the user profile pages can be seen by anyone, no matter if they're logged in or not. Make it so that `/users/:id` can only be viewed if that is the profile of the currently logged in user, otherwise, redirect to home.
  <details>
    <summary>HINT</summary>
    use the `current_user` method from the session helper
  </details>

1. Create another route only available to logged in users. Call it whatever you'd like!

1. Right now, you can create users with the same email. Create a validation on the user model that disallows this behavior.
