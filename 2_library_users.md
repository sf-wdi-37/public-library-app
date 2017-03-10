# <img src="https://cloud.githubusercontent.com/assets/7833470/10899314/63829980-8188-11e5-8cdd-4ded5bcb6e36.png" height="60"> Public Library App

### Part 2: Library Users

### A Library Model

Let's add our second model, a `Library`!

<details><summary>click for code</summary>
```bash
rails g model library name:string floor_count:integer floor_area:integer
```
</details>

We want a `user` to be able to join multiple libraries, but each library can also have multiple members. This means a many-to-many or `n:n` relationship.

Thus, we need a `library_user` model for our join table. It should have foreign keys for both other models.

<details><summary>click for code</summary>
```ruby
rails g model library_user user:belongs_to library:belongs_to
```
</details>

In the future we can store other things on the `library_user` model that are relevant to someone's membership in a library like join date, membership "level", etc.

We will also need two different controllers for `library` and `library_user`.  Let's start by implementing CRUD with libraries in the library controller.

```
rails g controller libraries
```

### A Library Index

Add a route to be able to view all the libraries.

<details><summary>click for code</summary>
```ruby

Rails.application.routes.draw do
  ...
  get '/libraries', to: 'libraries#index'
end
```
</details>

Add a `libraries#index` method to the libraries controller.

<details><summary>click for code</summary>
```ruby

class LibrariesController < ApplicationController

  def index
    @libraries = Library.all
  end

end
```
</details>

Add a basic view for all libraries.

<details><summary>click for code</summary>
```html
<% @libraries.each do |library| %>
  <div>
    <h3><%= library.name %></h3>
  </div>
  <br>
<% end %>
```
</details>

### A New Library

To be able to add a new library, we need a `GET /libraries/new` route to display the form.

<details><summary>click for code</summary>
```ruby

Rails.application.routes.draw do
...
  get '/libraries/new', to: 'libraries#new', as: 'new_library'
end

```
</details>

Add a `libraries#new` controller action.

<details><summary>click for code</summary>
```ruby
class LibrariesController < ApplicationController
...
  def new
    @library = Library.new
  end
end
```
</details>

Add a view for the new library form.

<details><summary>click for code</summary>
```html

<%= form_for @library do |f| %>
  <div>
    <%= f.text_field :name, placeholder: "Name" %>
  </div>
  <div>
    <%= f.number_field :floor_count, placeholder: "Floor Count" %>
  </div>
  <div>
    <%= f.number_field :floor_area, placeholder: "Floor Area" %>
  </div>
  <%= f.submit %>
<% end %>
```
</details>

This form has nowhere to go; if we try to submit it we get an error because there is no `POST /libraries` route.  Add one.

<details><summary>click for code</summary>

```ruby

Rails.application.routes.draw do
...
  post '/libraries', to: 'libraries#create'
end
```
</details>

Then we need a corresponding `libraries#create`.

<details><summary>click for code</summary>
```ruby

class LibrariesController < ApplicationController

  def create
    @library = Library.create(library_params)
    redirect_to libraries_path  # very light on the error handling, for now!
  end

  private

  def library_params   
    params.require(:library).permit(:name, :floor_count, :floor_area)
  end
end
```
</details>

### CRUDing Libraries
We now have the ability to view all libraries  and create new libraries.

**Independent Practice**: Implement `libraries#show` on your own. You will need to create routes, controller actions, and views.

Bonus: We recommend you also try to implement `edit`, `update`, `show`, and `delete`, but these aren't required for our initial setup.

### Associating Users and Libraries
Before we get start letting users become library members,  we need to wire together all of our models to know about these associations. Use the `has_many` `through` pattern to set up the many-to-many association in the models.

<details><summary>click for code</summary>
```ruby
class LibraryUser < ApplicationRecord
  belongs_to :user
  belongs_to :library
end
```

The above will already be in the LibraryUser model! How could that be? Rails guesses that a library-user will be the join table for users and libraries and builds the model accordingly.

```ruby
class User < ApplicationRecord
  has_many :library_users, dependent: :destroy
  has_many :libraries, through: :library_users
  # ...
end
```

```ruby
class Library < ApplicationRecord
  has_many :library_users, dependent: :destroy
  has_many :users, through: :library_users
end
```
</details>

You should now test this out in the console.

```bash
> user = User.first
> user.libraries
#=> []
> sfpl = Library.create({name: "SFPL"}) # San Francisco Public Library
> sfpl.users
#=> []
> sfpl.users.push(user)
> sfpl.users
#=> [ <#User ... @id=1> ]
> LibraryUser.count
#=> 1
> reload!
> user.libraries
#=> [ <#Library ... @name="SFPL" @id=1> ]
```

### `library_users` Controller

In order for us to have users become members libraries, we need to first create a `library_users` controller. Generate that now.

<details><summary>click for code</summary>
```bash
rails g controller library_users
```
</details>

We want to be able to view all user memberships to a library. We need to decide on a route for this. Based on RESTful routing, we could choose `/users/:user_id/libraries` or `/libraries/:library_id/users`.  Either one would be okay, but an application should not have both.  We'll choose the first since this app is more centered on users than libraries.

<details><summary>click for code</summary>
```ruby

Rails.application.routes.draw do
  ...
  get '/users/:user_id/libraries', to: 'library_users#index', as: 'user_libraries'
end
```
</details>

We also need the corresponding `index` method in the `library_users` controller.

<details><summary>click for code</summary>
```ruby
class LibraryUsersController < ApplicationController

  def index
    @user = User.find(params[:user_id])
    @libraries = @user.libraries # so we type less in the view
  end
end
```
</details>

Then we can have the `index` view list the user's libraries (`app/views/library_users/index.html.erb`):

<details><summary>click for code</summary>
```html

<div><%= @user.first_name %> is a member of the following libraries</div>

<ul>
  <% @libraries.each do |lib| %>   
    <li><%= lib.name %></li>
  <% end %>
</ul>
```
</details>

We can test this by going to `localhost:3000/users/1/libraries`. If you want, you can test that this is working by launching your `rails console` and adding a library to a user, then refreshing the page.


### Add A Membership

We should make a button that allows a user to become a member of a library!

Let's go back to the `libraries#index` view and add a button to do just that.

<details><summary>click for code</summary>
```html

<% @libraries.each do |library| %>
  <div>
    <h3><%= library.name %></h3>
    <% if current_user %>
      <%= button_to "Join", library_users_path(library) %>
    <% end %>
  </div>
  <br>
<% end %>
```
</details>

We don't have an endpoint yet that allows a user to join a library, so let's add that now so that our form will work.


<details><summary>click for code</summary>
```ruby
Rails.application.routes.draw do
  ...
  get '/users/:user_id/libraries', to: 'library_users#index', as: 'user_libraries'
  post '/libraries/:library_id/users', to: 'library_users#create', as: 'library_users'
end

```
</details>

Then, we need to add a `create` action in `LibraryUsersController` that adds the user to the library.

<details><summary>click for code</summary>
```ruby
class LibraryUsersController < ApplicationController

  ...

  def create
    @library = Library.find(params[:library_id])
    @library.users.push(current_user)  # no error handling currently

    redirect_to current_user
  end
end

```
</details>


### Authorization

Let's say that in order to visit a `users#show` page, you have to be logged in. Use a special `before_action` to check for this. Set up a `require_login` session helper to make help keep the controller "skinny."

<details><summary>click for code</summary>
```ruby
class UsersController < ApplicationController

  before_action :require_login, only: [:show]

  ...

  def show
    @user = User.find(params[:id])
    render :show
  end

end
```

This `before_action` line means there must be a `logged_in?` method somewhere that will be called before the show action is run.  Add a `logged_in?` helper method to the sessions helper to check whether there is a current user.
</details>

What other endpoints should be protected? Should an unauthenticated user be able to CRUD resources? Think about POST, PUT, and DELETE!

### Cleanup

Before moving on to bonuses, take a moment to make your site more user friendly. Link pages together so that a user can navigate more easily from their profile to their list of libraries, and from the library index to an individual library. Consider adding a better menu/navbar to make navigation easier.

### Bonuses

* Can you add books to the application?
    - For starters, just create a `Book` model and the associated views.
* Can you add books to the library?
    - What kind of a relationship is that? Where would foreign keys like `book_id` and `library_id` live in your database tables?
