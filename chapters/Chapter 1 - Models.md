# Chapter 1 - The Task and TaskList Models
Models are M in MVC. They're the primary way of interacting with data in the database.

If you're not familiar with MVC, or you want to know more about how Rails' models work,
here's an excellent resource that covers their general purpose and functionality:
http://guides.rubyonrails.org/active_record_basics.html#what-is-active-record-questionmark

Also, there's a few models already defined for you in the starter code, which will help with
authentication and user management. You can find whem in the `app/models/` directory.
They can also be helpful as a visual reference for what models look like, and how they're structured.

## Using Model Generators
For our Todo list, we want to represent each individual item in the list as a `TaskList`.
Each TaskList should correlate to a record (or row) in the database, associated to the User that owns it.

To create the TaskList model, we can use Rails' generators. Generators allow us to quickly generate scaffold
code, creating files for us in their appropriate locations with some basic content for structure.
Generating models can be done with:

```bash
rails generate model TaskList
```

Alternatively, we can also use its shortened form:

```bash
rails g model TaskList
```

This generator creates the following files:
 - `app/models/task_list.rb` which is the model file itself.
 - `db/migrate/####_create_task_lists.rb` is the database migration to create the `task_lists` table in our database.
 - `spec/factories/task_lists.rb` contains a factory that used to construct TaskLists with placeholder data, for testing.
 - `spec/models/task_list_spec.rb` is an RSpec file, where unit tests for the TaskList model are defined.

In addition, we can also provide a list of attributes to include on the model as part of the call to the
generator. Attributes are given in `name:type` format. For example:

```bash
rails g model TaskList user:references name:string tasks_count:integer
```

This will automatically include these columns in our database migration, the association in our model,
and placeholders for these attributes in the model's factory.

## Database Migrations
Before we begin, here's a link to where you can find more information about Rails' migrations:
http://guides.rubyonrails.org/active_record_basics.html#migrations

Migrations are how we make changes to our schema. They're executed in order, so we can consistently version
and control how our database in structured. By default, they include a `change` method, where we define the
actions that we want to perform as part of the migration.

When we ran the model generator, it should have created a new migration that's named `create_task_lists.rb`.
It's responsible for creating the `task_lists` table in the database, with its starting list of columns.
Generally, the contents of the file should look something like:

```ruby
class CreateTaskLists < ActiveRecord::Migration[5.2]
  def change
    create_table :task_lists do |t|
      t.timestamps
    end
  end
end
```

We want to include the following columns in our tasks table:

| Name | Type | Description |
| --- | --- | --- |
| user_id | integer | The User that owns the TaskList |
| name | string | The name of the TaskList |
| tasks_count | integer | The number of Tasks in the TaskList |

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

## Defining Associations
Rails provides excellent resources about associations:
http://guides.rubyonrails.org/association_basics.html

At a high level, associations are relationships between multiple models. They reflect the relationships in our
database, and translate them into something that we can use conveniently in Ruby.

For example, the `task_lists` table should have a `user_id` column, which refers to an entry in the `users` table.
It represents the User that owns the TaskList. In Rails terminology, it would be said that the TaskList belongs to the
User. Similarly, the User has many TaskLists.

When defining these associations in our models, we use that same terminology.
For example, in the `TaskList` model, we would define:

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
  has_many :task_lists
  ...
end
```

For examples of how associations are defined and used, see `app/models/user.rb` and `app/models/session.rb`.

## Moving onto the Task Model
Once you've created your `TaskList` model, you'll need to also create a `Task` model.
It will be very similar to what you did before, but there's a couple of differences to keep in mind.

Specifically:
  - A `TaskList` belongs to a `User`, but a `Task` belongs to a `TaskList`.
  - Similarly, where a `User` has many `TaskLists`, a `TaskList` has many `Tasks`.

Finally, tasks would store a slightly different set of fields. In particular, we're interested in:

| Name | Type | Description |
| --- | --- | --- |
| task_list_id | integer | The TaskList that contains this Task |
| name | string | The name of the Task |
| completed | boolean | The completion state of the Task |
| completed_at | timestamp | When the task was completed |

**NOTE**: Make sure you define all the associations discussed here. You'll need them later on!

## Adding Data Validations
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

For this portion, it's up to you which validations you use.
As examples, feel free to look at the validations in `app/models/user.rb` and `app/models/tag.rb`.

## Adding Callbacks (Side Effects)
For more information about callbacks, there's information available in this guide:
http://guides.rubyonrails.org/active_record_callbacks.html

ActiveRecord models keep track of which attributes have been changed. This is useful for triggering code to run when
specific changes on the model happen. To read more about the Rails change tracking mechanism, it's documented here:
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

### Counter Caches
For convenience and performance, we've included a field called `tasks_count` on the `TaskList` model.
It should contain the number of `Task` records that are associated to that particular `TaskList`.
It would be fairly straightforward to add a callback that would keep this field up-to-date,
but we can also ask Rails to do this for us.

In our `Task` model, we should have an association to the `TaskList` that looks like this:

```ruby
belongs_to :task_list
```

To indicate that we want to keep a cache of the number of records that belong to the task list:

```ruby
belongs_to :task_list, counter_cache: true
```

Whenever a `Task` is created, the `tasks_count` is incremented.
Similarly, whenever a `Task` is destroyed, the `tasks_count` field is decremented.

## Defining Factories for Models
We use a gem called FactoryBot to create data for use during testing. We define factories that contain information
about how to construct instances of a particular model. You can read more about FactoryBot here:
https://github.com/thoughtbot/factory_bot

We also use a gem called Faker to create fake data. It generates things like fake names, passwords, email addresses,
phone numbers, etc. You can find the documentation for it here:
https://github.com/stympy/faker

You can also look at the factories that are already defined in the starter code:
 - `spec/factories/users.rb`
 - `spec/factories/sessions.rb`
 - `spec/factories/tags.rb`

### Writing Factories
The Rails generator should have created an empty factory for the `Task` model when we created it. By default,
it should look something like this:

```ruby
FactoryBot.define do
  factory :task do
  end
end
```

Inside of this factory block, we define how we want attributes on the model to be initialized when we call
the factory. For example, if we wanted every Task to be created with a name, we can do:

```ruby
factory :task do
  name { 'My Task' }
end
```

However, this will create every Task with the same name: 'My Task'. If we wanted to generate a random name
every time, we can use Faker:

```ruby
factory :task do
  name { Faker::Hipster.sentence }
end
```

**NOTE**: Remember to implement the factory for both the `Task` and `TaskList` model!

### Using Factories in the Console
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

## Writing RSpecs (Unit Testing)
Before you start, you might want to read up on testing with RSpec:
https://relishapp.com/rspec/rspec-core/v/3-7/docs/subject/explicit-subject
https://relishapp.com/rspec/rspec-expectations/docs/built-in-matchers

You can also take a look at some of the existing model specs in:
 - `spec/models/user_spec.rb`
 - `spec/models/session_spec.rb`
 - `spec/models/tag_spec.rb`

To run our entire RSpec suite, we use:

```bash
rspec
```

We can also run only specific folders or files:

```bash
rspec spec/controllers
rspec spec/models/user_spec.rb
```

### Verifying the Factory
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
We can do this by running our test suite, or just a specific file:

```bash
rspec spec/models/task_spec.rb
```

### Writing RSpecs
In the model's RSpec file, we want to test any functionality that we defined on the model.
This includes:
 - Validations that we've defined: We want to make sure they catch invalid inputs and allow valid inputs.
 - Callbacks that we're using: Make sure that they're triggered when they should be and have the right effects.
 - Scope that we've defined: Ensure that they include the records we want, and exclude the records we don't.
 - Any public methods we've added: They need to do what we expect them to.

It's important that we only test what our model is doing! It's easy to get carried away and start testing code
that our model calls or relies on. In general, that's an antipattern.

**NOTE**: Remember to write tests for both the `Task` and `TaskList` model!

# Chapter 1 - Checklist
Here's a checklist of things that you should've covered by the time you've finished with this chapter:

- [ ] Create your `Task` and `TaskList` models.
- [ ] Add data validations to `Task` and `TaskList`.
- [ ] Add associations between `User`, `TaskList`, and `Task`.
- [ ] Implement handling for `completed` and `completed_at` on `Task` using callbacks.
- [ ] Create factories for `Task` and `TaskList`.
- [ ] Write RSpecs for `Task` and `TaskList`.

(If only we had a TODO list app we could put these in!)

| [Chapter 0 &rarr;](./Chapter%200%20-%20Getting%20Started.md) | [Back to Intro](../README.md) | [Chapter 2 &rarr;](./Chapter%202%20-%20Serializers.md) |
| --:| --:| --:|
