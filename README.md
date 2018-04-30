# Bootcamp Project Backend - Todo List App

## Getting Started
First things first, we need to install the dependencies for the Todo app.
We're using the `bundler` gem to manage the Ruby gems our app depends on. Dependencies are defined in the `Gemfile`.
To do this, we run:

```bash
bundle install
```

Bundler also looks for a file called `Gemfile.lock`. This file is automatically generated, and contains the versions
of the gems that need to be installed. This helps to ensure that the same versions are installed for everyone.

### Preparing the Database
Before we can start development, we need to prepare the database.
Rails provides tasks that manage our database for us, which we need to invoke before we start:

```bash
rails db:create db:migrate db:seed
```

This line runs 3 different tasks in sequence:
 - `db:create` creates databases in Postgres for both the development and test environments.
 - `db:migrate` runs database migrations (found under `db/migrate`) that create tables, modify the schema, etc.
 - `db:seed` runs the code in `db/seeds.rb` which should populate our database which initial data.

### Running the Rails Server
To start the our server, we run the following command:

```bash
rails server
```

Alternatively, we can also use its shortened form:

```bash
rails s
```

Once the server starts, it's available at http://localhost:3000/.

### Running the Rails Console
During development, we run an interactive console in our app's environment.
To start the rails console:

```bash
rails console
```

Alternatively, we can also use its shortened form:

```bash
rails c
```

Once the console is ready, we can run whatever Ruby code we want in the context of our app.
For example, if we wanted to see all the users in our database, we can use:

```ruby
User.all
```

To improve readability, we use a gem called `awesome_print`, which can be called using `ap`.
To view that same list of users in a more readable way:

```ruby
ap User.all
```

To close the rails console, we can use `quit` or `exit`.

## Getting Familiar with Rails
TODO [Examples about creating, updating, and deleting Users]

### Models
Models are also used to retrieve records from, and also to create and edit records in the database.
Each instance of a model represents a single row that exists in the corresponding database table.

In the starter code, we already have a `User` model, which maps to the `users` table in the database.
The model is found in `app/models/user.rb`.

#### Querying the Database
Let's quickly run through some basic ways of querying the database. We'll do this by example.
Say you wanted to fetch the first User in the database, or within some list of users. Rails provides a
function called `.first` for our convenience.

```ruby
user = User.first
user.email # => "test@platterz.ca"
user.password # => nil
user.password_digest # => "$2a$10$..."
```

If we wanted to fetch a specific User by their Primary Key (in most cases, the ID column), we use `.find(...)`.
This fetches a specific record by its defined primary key, or throws an exception if it can't find the record.

```ruby
User.find(1)    # => #<User id: 1, ...>
User.find(1000) # => ActiveRecord::RecordNotFound: Couldn't find User with 'id'=1000
```

Sometimes, we might want to find a User by a column other that the ID. The Rails function `.find_by(...)` accepts
a Hash which contains columns and their associated values, and then tries to fetch a record that matches these
specified constraints. Unlike `.find(...)`, this function returns `nil` if the record isn't found.

```ruby
User.find_by(email: 'test@platterz.ca') # => #<User id: 1, ...>
User.find_by(email: 'fake') # => nil
```

If you wanted to match the behaviour of `.find(...)` and throw a error, the `.find_by!(...)` function behaves the
same way as its normal counterpart `.find_by(...)`, but throws an error if no record is found matching the
requested criteria.

```ruby
User.find_by!(email: 'test@platterz.ca') # => #<User id: 1, ...>
User.find_by!(email: 'fake') # => ActiveRecord::RecordNotFound: Couldn't find User
```

For more information about the Query Interface, and examples of how to use it:
http://guides.rubyonrails.org/active_record_querying.html#retrieving-objects-from-the-database

#### Creating Records
To create a new User record, we can just construct it like as normal Ruby object, passing attributes
we want to set as a Hash. To persist the change to the database, we call `.save`.

```ruby
user = User.new(email: 'foo@bar.ca', password: 'password')
user.save # => true
```

We can also use the `.create` method, which encapsulates both construction and saving the record in single call:

```ruby
user = User.create(email: 'foo@bar.ca', password: 'password')
```

For more examples: http://guides.rubyonrails.org/active_record_basics.html#create

#### Updating Records
Updating an existing record in database works similarly. Attributes can be assigned like any normal attribute
on a Ruby object, and any changes made are saved to the database with `.save`.

```ruby
user = User.find(1)
user.email = 'foo-bar@platterz.ca'
user.save
```

We can also use the `.update` method, which assigns attributes from a Hash and saves changes in a single call:

```ruby
user = User.last
user.update(email: 'foo-bar@platterz.ca')
```

For more examples: http://guides.rubyonrails.org/active_record_basics.html#update

#### Deleting Records
Deleting a record in pretty straight forward:

```ruby
user = User.last
user.destroy
```

For more examples: http://guides.rubyonrails.org/active_record_basics.html#delete

## Step 1 - The Task Model
If you're not familiar with MVC, or you want to know more about how Rails' models work,
here's an excellent resource that covers their general purpose and functionality:
http://guides.rubyonrails.org/active_record_basics.html#what-is-active-record-questionmark

### Using Model Generators
For our Todo list, we want to represent each individual item in the list as a `Task`.
Each Task should correlate to a record (or row) in the database, associated to the User that owns it.

To create the Task model, we can use Rails' generators. Generators allow us to quickly generate scaffold
code, creating files for us in their appropriate locations with some basic content for structure.
Generating models can be done with:

```bash
rails generate model Task
```

Alternatively, we can also use its shortened form:

```bash
rails g model Task
```

This generator creates the following files:
 - `app/models/task.rb` which is the model file itself.
 - `db/migrate/####_create_tasks.rb` is the database migration to create the `tasks` table in our database.
 - `spec/factories/tasks.rb` contains a factory that used to construct Tasks with placeholder data, for testing.
 - `spec/models/task_spec.rb` is an RSpec file, where unit tests for the Task model are defined.

In addition, we can also provide a list of attributes to include on the model as part of the call to the
generator. Attributes are given in `name:type` format. For example:

```bash
rails g model Task user:references name:string
```

This will automatically include these columns in our database migration, the association in our model,
and placeholders for these attributes in the model's factory.

### Database Migrations
Before we begin, here's a link to where you can find more information about Rails' migrations:
http://guides.rubyonrails.org/active_record_basics.html#migrations

Migrations are how we make changes to our schema. They're executed in order, so we can consistently version
and control how our database in structured. By default, they include a `change` method, where we define the
actions that we want to perform as part of the migration.

When we ran the model generator, it should have created a new migration that's named `create_tasks.rb`.
It's responsible for creating the `tasks` table in the database, with its starting list of columns.
Generally, the contents of the file should look something like:

```ruby
class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.timestamps
    end
  end
end
```

We want to include the following columns in our tasks table:

| Name | Type | Description |
| --- | --- | --- |
| user_id | integer | The User that owns the Task |
| name | string | The name of the Task |
| completed | boolean | The completion state of the Task |
| completed_at | timestamp | When the task was completed |

For each column, also consider:
 - Does it make sense for this column to be null?
 - Should this column have a default value?

Once you're happy with your table structure, and you're ready to run migrations:

```bash
rails db:migrate
```

If you've made a mistake, or just want to undo the migration, you can run:

```bash
rails db:rollback
```

This will rollback the last migration that was applied to the database.

### Defining Associations
Rails provides excellent resources about associations:
http://guides.rubyonrails.org/association_basics.html

At a high level, associations are relationships between multiple models. They reflect the relationships in our
database, and translate them into something that we can use conveniently in Ruby.

For example, the `tasks` table should have a `user_id` column, which refers to an entry in the `users` table.
It represents the User that owns the Task. In Rails terminology, it would be said that the Task belongs to the
User. Similarly, the User has many Tasks.

When defining these associations in our models, we use that same terminology.
For example, in the `Task` model, we would define:

```ruby
class Task < ApplicationRecord
  ...
  belongs_to :user
  ...
end
```

Rails will automatically infer that this association is bound to the `user_id` attribute, and that it refers
to the `User` model.

Similarly, it we wanted to define the inverse association, we would write:

```ruby
class User < ApplicationRecord
  ...
  has_many :tasks
  ...
end
```

For examples of how associations are defined and used, see `app/models/user.rb` and `app/models/session.rb`.

### Adding Data Validations
Before starting, you might want to have a look at this guide about Rails validations:
http://guides.rubyonrails.org/active_record_validations.html

Once the database table is ready, we can move onto adding validations to our model.
Validations should ensure that the data being saved to the database makes sense. Validations that fail
apply errors to the model, which can be presented to the user to help them correct their input.

For example: If we wanted to ensure that the user doesn't create a task without a name, we would write:

```ruby
validates :name, presence: true
```

The Rails presense validation relies on the `.present?` method defined on all objects. It returns `false` for
things like `nil`, `false`, `[]` (empty array), `{}` (empty Hash), `''` (empty String).
In our case, this would ensure that the name is not `nil` or an empty string.

For this task, it's up to you which validations you use.
As examples for this task, feel free to look at the validations in `app/models/user.rb` and `app/models/session.rb`.

### Adding Callbacks (Side Effects)
For more information about callbacks, there's information available in this guide:
http://guides.rubyonrails.org/active_record_callbacks.html

We'll also need Rails' change tracking in this section, which you can read more about here:
http://api.rubyonrails.org/classes/ActiveModel/Dirty.html

For certain actions, we need to include additional side-effects that are applied to the model.
What this really means is we add code that is triggered by certain events in our models.

Examples of when we might use this is:
 - Setting a timestamp when the status of a model changes
 - Creating or destroying an associated record when a model is created or destroyed
 - Synchronizing the state of a model with an external system
 - Triggering a job, email, or event when a model is saved

In our Todo app, we want to keep track of when a Task is completed. To do this, we can use a callback to set
the `completed_at` attribute on the Task when `completed` becomes true.

For some examples of callbacks in action, take a look at `app/models/session.rb`.

### Defining Factories for Models
We use a gem called FactoryBot to create data for use during testing. We define factories that contain information
about how to construct instances of a particular model. You can read more about FactoryBot here:
https://github.com/thoughtbot/factory_bot

We also use a gem called Faker to create fake data. It generates things like fake names, passwords, email addresses,
phone numbers, etc. You can find the documentation for it here:
https://github.com/stympy/faker

You can also look at the factories that are already defined in the starter code:
 - `spec/factories/users.rb`
 - `spec/factories/sessions.rb`

#### Writing Factories
The Rails generator should have created an empty factory for the `Task` model when we created it. By default,
it should look something like this:

```ruby
FactoryBot.define do
  factory :task do
  end
end
```

Inside of this factory block, we define how we want attributes on the model to be initialized when we called
the factory. For example, if we wanted every Task to be created with a name, we can do:

```ruby
factory :task do
  name 'My Task'
end
```

However, this will create every Task with the same name: 'My Task'. If we wanted to generate a random name
everytime, we can use Faker:

```ruby
factory :task do
  name { Faker::Hipster.sentence }
end
```

**NOTE:** See the curly braces around the call to Faker? That tells FactoryBot to evaluate the block every time
the factory is called. Without them, Faker would be called when the factory is first loaded, and the result
would be baked-in to the factory. So, we'd have the same name every time!

#### Using Factories in the Console
If you open up the Rails console, you can call any of these factories through FactoryBot. It provides a couple
of methods that we care about in particular. The `.build(...)` method constructs a new instance of a model without
saving it to the database:

```ruby
FactoryBot.build(:user) # => #<User id: nil, email: "legros_2_kennedy_ms@haag.co", ...>
FactoryBot.build(:user, email: 'test@platterz.ca') # => #<User id: nil, email: "test@platterz.ca", ...>
```

It also provides a `.create(...)` function that behaves like `.build(...)`, but also saves the record to the database
by calling `.save!`. If saving the record fails (ie. there's a validation error), it will throw an error.

```ruby
FactoryBot.create(:user) # => #<User id: 1, email: "legros_2_kennedy_ms@haag.co", ...>
FactoryBot.create(:user, email: 'test@platterz.ca') # => #<User id: 2, email: "test@platterz.ca", ...>
FactoryBot.create(:user, email: '') # => ActiveRecord::RecordInvalid: Validation failed: Email can't be blank
```

Finally, it provides a function called `.attributes_for(...)` which returns a Hash containing the attributes that
would be passed to the model when creating it. We'll use this later when testing controllers:

```ruby
FactoryBot.attributes_for(:user) # => {:email=>"3.dds.clare.balistreri@okuneva.org", :password=>"4h2gTpEfOcJp960b"}
```

### Writing RSpecs (Unit Testing)
Before you start, you might want to read up on testing with RSpec:
https://relishapp.com/rspec/rspec-core/v/3-7/docs/subject/explicit-subject
https://relishapp.com/rspec/rspec-expectations/docs/built-in-matchers

You can also take a look at some of the existing model specs in:
 - `spec/models/user_spec.rb`
 - `spec/models/session_spec.rb`

To run our entire RSpec suite, we use:

```bash
rspec
```

We can also run only specific folders or files:

```bash
rspec spec/controllers
rspec spec/models/user_spec.rb
```

#### Verifying the Factory
Since we use FactoryBot factories to generate testing data for our RSpecs, a good first step is to verify
that the output of the factory is valid. We do this simply by saying:

```ruby
subject { build(:task) }

it 'has a valid factory' do
  should be_valid
end
```

Here we're doing 2 things:
 1. Define the subject, which we'll also be using for our subsequent specs.
 2. Define an expectation that the subject is valid in its initial state.

**NOTE:** When calling factories from RSpec, we don't need to explicitly use the `FactoryBot` namespace.
So, instead of calling `FactoryBot.build(:task)` we can just say `build(:task)`.

Before we go any further, we'll want to make sure our factory is valid according to our model's validations.
We can do this by running our test suite, or just this specific file:

```bash
rspec spec/models/task_spec.rb
```

#### Writing our RSpecs
In the model's RSpec file, we want to test any functionality that we defined on the model.
This includes:
 - Validations that we've defined: We want to make sure they catch invalid inputs and allow valid inputs.
 - Callbacks that we're using: Make sure that they're triggered when they should be and have the right effects.
 - Scope that we've defined: Ensure that they include the records we want, and exclude the records we don't.
 - Any public methods we've added: They need to do what we expect them to.

It's important that we only test what our model is doing! It's easy to get carried away and start testing code
that our model calls or relies on. In general, that's an antipattern.

## Step 2 - The Task Serializer
To send information to our Frontend, we'll need to serialize it into a format the Frontend can understand.
In our case, we're using JSON. To do this, we need to decide how our object is serialized, and which attributes
are included in the serialization.

We use Serializers to control how the response is structured. They're provided by the `active_model_serializers`
gem that's defined in our `Gemfile`.

### Using Serializer Generators
To serializer Tasks, we'll want to create a `TaskSerializer`. We can generate the scaffold for one using the
built-in generator:

```bash
rails g serializer Task
```

This will create a new serializer stub in `app/serializers/task_serializer.rb`.
By default, your serializer will look something like this:

```ruby
class TaskSerializer < ApplicationSerializer
  attributes :id
end
```

This default serializer will only include the `id` property in the output JSON.
To include other attributes, or include associated models in our serialization, we'll need to define
additional serialized attributes.

### Defining Serialized Attributes
There are two types of entries we define in our serializer:
 1. Attributes, which are simple fields like strings, integers, boolean, etc.
 2. Associations, which refer to associated models.

There's two ways to define simple attributes. We can define them all at once using the `attributes` method.
For example:

```ruby
class TaskSerializer < ApplicationSerializer
  attributes :id, :name, :completed, ...
end
```

We can also define them one-per-line, using the `attribute` method. It also allows us to override the value,
add conditions to when the attribute is returned, and several other small differences. In general,
we prefer the one-per-line syntax.
For example:

```ruby
class TaskSerializer < ApplicationSerializer
  attribute :id
  attribute :name
  attribute :completed
  ...
end
```

#### Serializing Associations
In addition to simple attributes, we can define associations that are serialized with the Task.
For example, if we wanted to include the User that owns the Task in the response:

```ruby
class TaskSerializer < ApplicationSerializer
  attribute :id
  attribute :name
  ...

  belongs_to :user
end
```

There are two primary differences between attributes and associations:
 1. Associations will always try to use a serializer. (ie. `belongs_to :user` will use the `UserSerializer`.)
 2. Associations are only serialized to 1 layer of depth by default.
 
So, if we defined associations in our `UserSerializer`, they wouldn't be included in the User serialized
by the `user` attribute in the `TaskSerializer`.

For examples of serializers, take a look at others in `app/serializers`.

## Step 3 - The Tasks Controller

The Frontend needs to be able to:
 - View all of the User's Tasks
 - Fetch a specific Task, by its ID
 - Create a new Task
 - Edit an existing Task
 - Delete a Task

### Using Controller Generators

```bash
rails g controller Tasks
```

This generator creates the following files:
 - `app/controllers/tasks_controller.rb` which is the actual controller.
 - `spec/controllers/tasks_controller_spec.rb` is an RSpec file, where we define tests for the controller.

### Defining Actions

### Routing
Once we have our controller in place, we need to tell Rails how to route requests to the methods in the controller.
Rails' routing is described in detail by this guide:
http://guides.rubyonrails.org/routing.html#the-purpose-of-the-rails-router

In our case, we want to define a resource, which Rails has a convenient helper for:

```ruby
resources :tasks
```

**NOTE:** There's a difference between `resources` and `resource`. In our case, we want to use `resources`,
because we're defining a plural (rather than a singular) resource.
If you're interested in the difference, it's described in detail by this guide:
http://guides.rubyonrails.org/routing.html#singular-resources

### Writing RSpecs

## Step 4 - The Task Policy

### Using Policy Generators

```bash
rails g pundit:policy Task
```

### Permitted Actions

### Permitted Attributes

### Policy Scopes

### Writing RSpecs

## Step 5 - Wrapping Up

### Rubocop (The Linter)
At Platterz, we use Rubocop as our linting tool for Ruby. If you're not familiar with linters or Rubocop, it
automatically checks that code conforms to our style guide. This includes things like method length, class length,
naming, whitespace and indentation, some Rails specific conventions, and general best practices.
This isn't a catch-all solution, but it's a good base-line for what you should or should not do.

To run Rubocop from your terminal, you can use:

```bash
rubocop
```

Rubocop can also automatically correct some violations (usually things related to whitespace and indentation).
To automatically correct any style issues that are encountered, pass the `-a` flag:

```bash
rubocop -a
```

Rubocop also accepts file paths, so if we wanted to only clean up the `Task` model:

```bash
rubocop -a app/models/task.rb
```

**NOTE:** Remember to look over any corrections that Rubocop does before you commit them! Sometimes,
it may choose to indent or align things in some pretty wonky ways. If you're ever in doubt,
poke someone about what Rubocop is telling you to do, and we'll steer you in the right direction.

## Bonus - User Sign Up
