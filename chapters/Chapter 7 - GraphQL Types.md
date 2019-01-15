# Chapter 7 - GraphQL Types

## Defining GraphQL Types
To generate a GraphQL type, we can use the provided Rails generator:

```bash
rails g graphql:object Task
```

This will generate a new file in `app/graphql/types/task_type.rb`.
Initially, the content of the file should look something like this:

```ruby
class Types::TaskType < Types::BaseObject
end
```

**NOTE**: Remember to generate types for both the `TaskList` and `Task` models.

### Adding Fields to GraphQL Types
GraphQL Types are very similar to serializers, as they define which fields on the model are available on the frontend.
Unlike serializers however, they include type information about the field.
For example:

```ruby
field :name, String, null: false
```

The line above defines a field called `name`, which is a `String` and cannot be `null`.
When the frontend queries the schema, the API will automatically send it this information.

Also, feel free to look at the existing GraphQL types as examples:
 - [Types::TagType](../app/graphql/types/tag_type.rb)
 - [Types::UserType](../app/graphql/types/user_type.rb)

Let's start adding fields to the `Types::TaskType`. If we wanted to add the `id` and `name` fields to the type,
that would look something like this:

```ruby
class Types::TaskType < Types::BaseObject
  field :id, ID, null: false
  field :name, String, null: false
  ...
end
```

Once you're happy with your `Types::TaskType`, you can move onto the `Types::TaskListType`.

### Scalar Types
The GraphQL Ruby guide includes some documentation on scalar (simple) types:
http://graphql-ruby.org/type_definitions/scalars.html

In summary, GraphQL provides the following scalar types:
 - `Int`
 - `Float`
 - `Boolean`
 - `String`
 - `ID`

The `ISO8601DateTime` is also provided, but we prefer to use our own `Types::DateTimeType`.

## Interface Types
In our data structure, we use the `Taggable` concern to encapsulate the fact that both `TaskList` and `Task`
may have attached tags. In our GraphQL schema, we can use an interface type to represent this information.
Much like conerns, GraphQL interfaces in Ruby are modules, not classes.

To generate a GraphQL interface, we can use the provided Rails generator:

```bash
rails g graphql:interface Taggable
```

This will generate a new file in `app/graphql/types/taggable_type.rb`.
Initially, the content of the file should look something like this:

```ruby
module Types::TaggableType
  include Types::BaseInterface
end
```

### Adding Fields to GraphQL Interfaces
Adding fields to interfaces works exactly the same as it does for types.
In our case, we want to add `tags` to the `Types::TaggableType` interface.
We've already provided you with a [Types::TagType](../app/graphql/tag_type.rb), to represent each attached tag.

However, unlike the fields we've added so far, a `Taggable` object has many tags.
To represent this, we'll define the field to have an `Array` type:

```ruby
field :tags, [Types::TagType], null: false
```

### Implementing Interfaces on GraphQL Types
Now that we've defined our `Types::TaggableType` interface, and added the `tags` field to it, we can attach the interface
to our other types. In particular, we want to attach it to `Types::TaskListType` and `Types::TaskType`.

```ruby
class Types::TaskType < Types::BaseObject
  implements Types::TaggableType

  ...
end
```

**NOTE**: When implementing an interface, we use the `implements` DSL function.
It's inherited from the `Types::BaseObject` parent class, and is specifically used to implement interfaces.

## GraphQL Connections
In GraphQL, connections represent relationships between nodes in a graph.
Below is an article that explains what GraphQL connections are excellently:
https://blog.apollographql.com/explaining-graphql-connections-c48b7c3d6976

We use connections when we need to be able to paginate - that is, divide a large set of records into smaller
chucks (or pages).
For example: A `TaskList` can potentionally contain hundreds of tasks. If we use a connection here,
the frontend would then be able to fetch the tasks in small batches, as apposed to all in a single,
massive (and potentially very slow) request.

The GraphQL Ruby gem supports connections out of the box. In fact, every GraphQL type automatically has a
default connection type defined for it.
So, if we wanted to define a `tasks` connection on the `Types::TaskLikeType`, we write:

```ruby
class Types::TaskListType < Types::BaseObject
  ...
  field :tasks, Types::TaskListType.connection_type, null: false
end
```

The `connection_type` method returns the default GraphQL connection type, which is generated for each type you define.
It automatically includes `first` and `last` arguments (which restrict how many records are returned), as well as
`before` and `after` arguments (which accept cursors and paginate through the dataset).

More information about GraphQL Ruby's connections can be found here:
http://graphql-ruby.org/relay/connections.html

For our application, we'll want the following connections:
 - `user -> task_lists`, to list all `TaskLists` owned by the `User`.
 - `task_list -> tasks`, to list `Tasks` within a `TaskList`.

# Chapter 7 - Checklist
Here's a checklist of things that you should've covered by the time you've finished with this chapter:

- [ ] Add GraphQL Types `Types::TaskListType` and `Types::TaskType`.
- [ ] Define fields in your types which should be available to the frontend.
- [ ] Add a GraphQL Interface `Types::TaggableType`.
- [ ] Make `Types::TaskListType` and `Types::TaskType` implement `Types::TaggableType`.
- [ ] Add a connection to `task_lists` from the `Types::UserType`.
- [ ] Add a connection to `tasks` from the `Types::TaskListType`.

(GraphQL has always been my preferred type of API.)

| [&larr; Chapter 6](./Chapter%206%20-%20Concerns.md) | [Back to Intro](../README.md) | [Chapter 8 &rarr;](./Chapter%208%20-%20GraphQL%20Queries.md) |
| --:| --:| --: |
