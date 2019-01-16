# Chapter 7 - GraphQL Types
Until now, we've been working on a REST API for our application. At Platterz, we use a combination of REST and GraphQL.
Much of the original API still relies on REST, whereas a lost of newer features are starting to take advantage of
the features and benefits of GraphQL.

In Rails, we use a gem called GraphQL Ruby (creatively named, I know) to handle all of the heavy-lifting required to
implement a GraphQL API. Our application only needs to define the Schema (types), and implement the endpoints
(queries and mutations).

GraphQL was covered at a high-level in the first week of bootcamp. Now, we're going to put your learnings to the test,
and build a GraphQL API for your TODO list application.

## Getting Started
It's strongly recommended that you install a GraphQL IDE for this upcoming segment.
At Platterz, we prefer GraphQL Playground. If you've been using Postman to interact with the REST API,
this will fill the same niche, but provide you with features tailored towards GraphQL.

Unlike REST, all GraphQL interactions use the `POST` HTTP verb, and are made to the same URL.
Further, the GraphQL Playground includes features like type-checking, autocompletion, and error highlighting.

You can install GraphQL Playground using `brew cask` from the command line:

```bash
brew cask install graphql-playground
```

It's a graphical application, so after the installation finishes, you'll find it in yours apps folder.
It includes a graphical schema viewer, which can help you introspect and examine your GraphQL schema.
The GraphQL API is served from `http://localhost:3000/graphql` when your Rails server is running.

## Defining GraphQL Types
GraphQL is statically typed. This means that type information about the API is known before the start of execution.
Our API is responsible for defining all of the types and data structures that it makes use of, which the frontend
will consume. Collectively, all these types and behaviours are known as our schema.

We're going to be using a few different kinds of types:
 - Scalars, which are simple types like Integers and Strings
 - Types, which represent aggregate types (in our case, these are our models)
 - Interfaces, which represent encapsulate attributes and behaviours, and are implemented by other types

### Using the GraphQL Generators
First off, we'll define types for our `TaskList` and `Task` models.
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
GraphQL types are very similar to serializers, as they define which fields on the model are available on the frontend.
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
Much like concerns, GraphQL interfaces in Ruby are modules, not classes.

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
For example: A `TaskList` can potentially contain hundreds of tasks. If we use a connection here,
the frontend would then be able to fetch the tasks in small batches, as apposed to all in a single,
massive (and potentially very slow) request.

The GraphQL Ruby gem supports connections out of the box. In fact, every GraphQL type automatically has a
default connection type defined for it.
So, if we wanted to define a `tasks` connection on the `Types::TaskLikeType`, we write:

```ruby
class Types::TaskListType < Types::BaseObject
  ...
  field :tasks, Types::TaskType.connection_type, null: false
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

- [ ] Add GraphQL types `Types::TaskListType` and `Types::TaskType`.
- [ ] Define fields in your types which should be available to the frontend.
- [ ] Add a GraphQL Interface `Types::TaggableType`.
- [ ] Make `Types::TaskListType` and `Types::TaskType` implement `Types::TaggableType`.
- [ ] Add a connection to `task_lists` from the `Types::UserType`.
- [ ] Add a connection to `tasks` from the `Types::TaskListType`.

(GraphQL has always been my preferred type of API.)

| [&larr; Chapter 6](./Chapter%206%20-%20Concerns.md) | [Back to Intro](../README.md) | [Chapter 8 &rarr;](./Chapter%208%20-%20GraphQL%20Queries.md) |
| --:| --:| --: |
