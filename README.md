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

## Step 1 - The Task Model
If you're not familiar with MVC, or you want to know more about how Rails' models work,
Here's an excellent resource that covers their general purpose and functionality:
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

These generators create the following files:
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

For some examples of callbacks in actions, take a look at `app/models/session.rb`.

### Defining Factories for Models

### Writing RSpecs (Unit Testing)

## Step 2 - The Task Serializer

### Using Serializer Generators

## Step 3 - The Task Policy

### Using Policy Generators

### Permitted Actions

### Permitted Attributes

### Policy Scopes

### Writing RSpecs

## Step 4 - The Tasks Controller

### Using Controller Generators

### Defining Actions

### Routing

### Writing RSpecs
