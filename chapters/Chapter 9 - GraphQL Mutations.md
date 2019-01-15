# Chapter 10 - GraphQL Mutations

Much like Queries, and different to Controllers, each Mutation lives in its own class and file.
There's already a couple of Mutations defined for you, which you can use for reference:
 - [`Mutations::LogIn`](../app/graphql/mutations/log_in.rb)
 - [`Mutations::LogOut`](../app/graphql/mutations/log_out.rb)

Our frontend will need the following mutations:
 - `Mutations::CreateTaskList`, to create a new `TaskList`.
 - `Mutations::UpdateTaskList`, to edit an existing `TaskList`.
 - `Mutations::CreateTask`, to create a new `Task`.
 - `Mutations::UpdateTask`, to edit an existing `Task`.
 - `Mutations::CompleteTask`, to mark a `Task` as having been completed.

## Defining Mutations

```ruby
class Mutations::CreateTaskList < Mutations::BaseMutation
  def resolve
  end
end
```

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

```ruby
class Mutations::CreateTaskList < Mutations::BaseMutation
  argument :input, Types::CreateTaskListInputType, required: true

  field :task_list, Types::TaskListType, null: true
  field :errors, [String], null: false

  def resolve(input:)
  end
end
```

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

```ruby
def resolve(input:)
  authorize(TaskList, :create?)
  task_list = TaskList.create!(input.to_h) do |task_list|
    task_list.user = current_user
  end

  { task_list: task_list, errors: [] }
end
```

## Testing Mutations with RSpec

# Chapter 10 - Checklist
