# Chapter 9 - GraphQL Mutations
In the previous chapter, we added GraphQL queries to our API to allow the frontend to read information from our system.
Now it's time add support for write operations. In GraphQL, write operations are handling by mutations.
Writes operations are anything that change the state of the database;
create, update, and delete operations are all mutations.

Much like Queries, and different to Controllers, each mutation lives in its own class and file.
There's already a couple of Mutations defined for you, which you can use for reference:
 - [`Mutations::LogIn`](../app/graphql/mutations/log_in.rb)
 - [`Mutations::LogOut`](../app/graphql/mutations/log_out.rb)

Our frontend will need the following mutations:
 - `Mutations::CreateTaskList`, to create a new `TaskList`.
 - `Mutations::UpdateTaskList`, to edit an existing `TaskList`.
 - `Mutations::CreateTask`, to create a new `Task`.
 - `Mutations::UpdateTask`, to edit an existing `Task`.
 - `Mutations::CompleteTask`, to mark a `Task` as having been completed.

Notice how we've split up editing a task from marking it complete. This is a design decision that is more in line with
how GraphQL API are usually structured. Less focus on CRUD, and more focus on representative actions.
We could have actually done the same for our REST API, but we kept the actions together for purposes of simplicity.

## Defining Mutations

**NOTE**: While GraphQL Ruby does provide generators for mutations, they do not behave correctly at the moment.
Refrain from using them (for the time being), as doing so will leave your code full of syntax errors.

Since we can't use generators to create mutations, we'll do so manually. Mutations live in `app/graphql/mutations`.
The name of the mutation should reflect what it does.
To start, let's create the `Mutations::CreateTaskList` (in `app/graphql/mutations/create_task_list.rb`).
An empty mutation would look very similar to a query:

```ruby
class Mutations::CreateTaskList < Mutations::BaseMutation
  def resolve
  end
end
```

Much like with queries, the `resolve` method is responsible for implementing the logic of the mutation.

### GraphQL Input Types
Before we implement our mutation, we need to define the data type that the mutation accepts as an input.
GraphQL Ruby refers to these types as "Input Objects". Unlike normal types, input types have arguments, not fields.
For an example of an input type, [`Types::LogInInputType`](../app/graphql/types/log_in_input_type.rb) is implemented for you.

You can find a bit more information on input types in the GraphQL Ruby guide:
http://graphql-ruby.org/type_definitions/input_objects.html

Let's start by defining the input type for the `Mutations::CreateTaskList` mutation.
Inputs types are named after the mutation that they correspond to, and they're kept in the `app/graphql/types` directory.
Start by creating a file in `app/graphql/types/create_task_list_input_type.rb`. Your input type might look something like:

```ruby
class Types::CreateTaskListInputType < Types::BaseInputObject
  argument :name, String, required: true
  ...
end
```

You'll need to define input types for any mutations that have aggregate (complex) inputs.
For the TODO list application, this will be:
 - `Mutations::CreateTaskListInputType`
 - `Mutations::UpdateTaskListInputType`
 - `Mutations::CreateTaskInputType`
 - `Mutations::UpdateTaskInputType`

We don't need input types for our `Delete___` mutations, since will only require an ID.
The `Mutations::CompleteTask` mutation also doesn't require one, since it should also only require an ID.

### Defining Arguments and Return Types
Similar to queries, mutations must define a return type and arguments. However, for mutations, we define fields that
are returned as part of the result of the mutation. GraphQL Ruby will then generate a type that contains these fields,
and assign that as the result of the mutation.

Mutations will generally need to return two pieces of information:
 - The object which the mutation was interacting with
 - A list of errors that ocurred, which should be presented to the user

Going with our example of the `Mutations::CreateTaskList` mutation, we would define something like:

```ruby
class Mutations::CreateTaskList < Mutations::BaseMutation
  argument :input, Types::CreateTaskListInputType, required: true

  field :task_list, Types::TaskListType, null: true
  field :errors, [String], null: false

  def resolve(input:)
  end
end
```

Above, we've defined our mutation to accept an argument `input`, which is the input type that was defined for this mutation.
We also defined that the mutation returns an object containing two fields:
 - `task_list`, which is the `TaskList` record that was created
 - `errors`, which is a list of error messages

**NOTE**: We defined `task_list` as being nullable! This is because we don't want to return the `TaskList` if it's invalid.
If the create operation fails, a list of `errors` will be returned, and the `task_list` property will be `null`.

#### Error Handling in Mutations
Note how our mutation includes an `errors` field, which is an Array of Strings.
This field is used to return validation errors (things that the user can fix, in some way) back to the frontend.

```ruby
field :errors, [String], null: false
```

We've already added a mechanism that will automatically populate this field, if your mutation raises an exception.
This means you should use `create!`, `update!`, and `save!` in your mutations (rather than `create`, `update`, or
`save`), since they can automatically make use of this error handling.

### Implementing the Create Task List Mutation
The body of our `Mutations::CreateTaskList` mutation will be very similar to the `create` method in the controller.
We need to `authorize(...)` the action using the `TaskListPolicy`, associate the `TaskList` to the current user,
and save the record into the database.

Once we've finished with all the logic we need to perform, we need to return the result of the mutation.
Since the result of our mutation has multiple fields, we return a Hash that contains keys for each field that
we want to return.

Using the `Mutations::CreateTaskList` mutation as an example, this would look like:

```ruby
def resolve(input:)
  authorize(TaskList, :create?)
  task_list = TaskList.create!(input.to_h) do |task_list|
    task_list.user = current_user
  end

  { task_list: task_list, errors: [] }
end
```

**NOTE**: We return an empty Array of `errors` when the mutation is successful.
This is because we defined our `errors` field to be non-nullable. Having `errors` be `nil`, or not including it
in the Hash would result in a GraphQL Error being raised.

## Testing Mutations with RSpec
Much like queries, GraphQL mutations are implemented as POROs in Ruby, which makes testing them very easy.
There's a couple of examples of how to test GraphQL mutations in the `spec` folder:
 - [Mutations::LogIn](../spec/graphql/mutations/log_in_spec.rb)
 - [Mutations::LogOut](../spec/graphql/mutations/log_out_spec.rb)

In general, tests should ensure that:
 - The mutation returns the correct result
 - The mutation correctly modifies the state of the database
 - The mutation raises validation errors when the input is invalid
 - The mutation raises correctly raises authorization errors

### Writing Factories for Input Types
Mutations that accept complex inputs (like the `Mutations::CreateTaskList` mutation) can get messy, when constructing
the input object. To keep them clean, we can construct the input object using a factory, much like we do with models.

Factories for input types are kept in `spec/factories/graphql`, and like all factories, the file name should be plural.
ie. The `Types::CreateTaskListInputType` factory would live in `spec/factories/graphql/create_task_list_inputs.rb`,
and it would look something like this:

```ruby
FactoryBot.define do
  factory :create_task_list_input, class: OpenStruct do
    name { Faker::Lorem.sentence }
    ...
  end
end
```

**NOTE**: The class constructed by this factory is an `OpenStruct`. This is a datatype provided by Ruby that behaves
similarly to the input object we receive from GraphQL Ruby, when the mutation is called.

This factory can be used like any other factory.
For example, we can use it to call the mutation from the console:

```ruby
session   = Session.last
input     = FactoryBot.build(:create_task_list_input)
mutation  = Mutations::CreateTaskList.new(object: nil, context: { current_session: session })
task_list = mutation.call(input: input) # => #<TaskList id: 1, ...>
```

# Chapter 9 - Checklist
Here's a checklist of things that you should've covered by the time you've finished with this chapter:

- [ ] Define and implement `CreateTaskList`, `UpdateTaskList`, and `DeleteTaskList` mutations.
- [ ] Define and implement `CreateTask`, `UpdateTask`, `DeleteTask`, and `CompleteTask` mutations.
- [ ] Define input types for your mutations.
- [ ] Add the mutations to the `Types::MutationType` (the root type).
- [ ] Write RSpecs for each of your mutations.

(Something, something, terrible joke involving the word 'mutation'.)

| [&larr; Chapter 8](./Chapter%208%20-%20GraphQL%20Queries.md) | [Back to Intro](../README.md) |
| --:| --:|
