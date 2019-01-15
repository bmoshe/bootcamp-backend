# Chapter 8 - GraphQL Queries
Once the data structure we use in our API are ready, it's time to start implementing the GraphQL API logic.
GraphQL makes a distinction between Queries (operations that read data) and Mutations (operations that write data).
We'll start with implementing our Queries.

For our REST API, all actions that relate to a particular model are implemented as different methods in a
single controller. GraphQL works a bit differently; each action is placed in a separate class.
There's already a couple of Queries defined for you, which you can use for reference:
 - [`Queries::CurrentSession`](../app/graphql/queries/current_session.rb)
 - [`Queries::CurrentUser`](../app/graphql/queries/current_user.rb)
 - [`Queries::Tags`](../app/graphql/queries/tags.rb)

The frontend app will need two additional queries:
 - `Queries::TaskList`, which will return a `TaskList` given an ID.
 - `Queries::Task`, which will return a `Task` given an ID.

What about lists of records (like the controller `index` methods)? In our case, we can just use the connections from
the `user -> task_lists` to list `TaskLists`, and `task_list -> tasks` to list `Tasks`.

## Defining GraphQL Queries
GraphQL Queries are placed into the `app/graphql/queries` folder. Unfortunately, there's no generator for them, so you'll
need to create and populate the files manually.
Below is the general structure for the `Queries::Task` Query. It should be placed in `app/graphql/queries/task.rb`:

```ruby
class Queries::Task < Queries::BaseQuery
  def resolve
  end
end
```

All queries must inherit the `Queries::BaseQuery` parent class, and define `resolve` method.
The `resolve` method is what actually implements the logic of the query.

Inside of the `resolve` method, you have access to many of the same functions you do in a controller action:
 - `current_session` and `current_user`, which get you the current login session and the association user
 - `authorize(...)`, which validates an action using a Policy
 - `policy_scope(...)`, which calls the Policy::Scope to restrict a data set to what a user can see

### Defining Arguments and Return Types
Since GraphQL is statically typed, we'll need to provide it with a bit of additional type information.
Notably:
 - The return type of the Query
 - The names and types of any arguments it accepts

For the `Queries::Task` query, the return type will be a `Types::TaskType`. It shouldn't be nullable, since we want
to return an error if the client requests a `Task` that doesn't exist.
In terms of arguments, we'll need to accept the `id` of the `Task`.

Below is an example of how this would look:

```ruby
class Queries::Task < Queries::BaseQuery
  type Types::TaskType, null: false

  argument :id, ID, required: true

  def resolve(id:)
  end
end
```

**NOTE**: We also update the `resolve(...)` method to accept a named-parameter called `id`.
Unlike controllers, where incoming parameters are available from the `params` method,
GraphQL Ruby will automatically pass the `id` argument it receives from the frontend as this parameter.

### Implementing the Task Query
Once we've defined the type information for our schema, we can start implementing the logic.
The `Queries::Task` Query should behave like the `show` method in a controller.
It accepts an ID, and then returns the corresponding record.

```ruby
def resolve(id:)
  task = Task.find(id)
  authorize(task, :show?)
  task
end
```

**NOTE**: When we call `authorize(...)` in a Query or Mutation, we need to pass a second argument which is the method
in the policy that we want to call. In a controller, `authorize(...)` will automatically infer the method to call based
on the controller action. However, in a Query, it's not able to do so.
In this case, calling `authorize(task, :show?)` calls the `show?` method in the `TaskPolicy`. Beyond that, the method
behaves as it would in a controller.

## Adding Queries to the Schema
Once we've defined our queries, they need to be included in the GraphQL schema.
To do this, we add them as a field to the [`Types::QueryType`](../app/graphql/types/query_type.rb).

The `Types::QueryType` class is known as a root-type. This means it represents the root of the schema.
You can read more about root types here:
http://graphql-ruby.org/schema/root_types.html

To add the `Queries::Task` query to our schema, we write:

```ruby
field :task, resolver: Queries::Task
```

## Testing Queries with RSpec
GraphQL Queries are implemented as POROs (Plain-Old Ruby Objects).
This means you can construct them and call methods as you would for any other normal object.

The construct of the query excepts two named parameters:
 - `object`, which refers to the parent object of the field. Since our Query is on the root of the schema, this is always `nil`.
 - `context`, which is a Hash containing contextual information. This is how we pass the `current_session`.

Once you've constructed an instance of the Query, you can call `resolve` as you would any other method.
For example, here's how we'd call the `Queries::Task` query from the console:

```ruby
session = Session.last
query   = Queries::Task.new(object: nil, context: { current_session: session })
task    = query.resolve(id: 1) # => #<Task id: 1, ...>
```

There's a couple of examples of how to test GraphQL queries in the `spec` folder:
 - [Queries::CurrentSession](../spec/graphql/queries/current_session_spec.rb)
 - [Queries::Tags](../spec/graphql/queries/tags_spec.rb)

Unfortunately, there's no generators for GraphQL Queries, so you'll need to create the files manually.

In general, tests should ensure that:
 - The Query returns the correct result
 - The Query raises the correct errors when the input is incorrect
 - The Query raises correctly raises authorization errors

# Chapter 8 - Checklist
Here's a checklist of things that you should've covered by the time you've finished with this chapter:

- [ ] Define and implement `Queries::TaskList` and `Queries::Task`.
- [ ] Add the queries to the `Types::QueryType` (the root type).
- [ ] Write RSpecs for `Queries::TaskList` and `Queries::Task`.

(If you've got any outstanding queries, feel free to direct them to us!)

| [&larr; Chapter 7](./Chapter%207%20-%20GraphQL%20Types.md) | [Back to Intro](../README.md) | [Chapter 9 &rarr;](./Chapter%209%20-%20GraphQL%20Mutations.md) |
| --:| --:| --: |
