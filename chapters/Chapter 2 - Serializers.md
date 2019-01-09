# Chapter 2 - The Task and TaskList Serializers
To send information to our Frontend, we'll need to serialize it into a format the Frontend can understand.
In our case, we're using JSON. To do this, we need to decide how our object is serialized, and which attributes
are included in the serialization.

We use Serializers to control how the response is structured. They're provided by the `active_model_serializers`
gem that's defined in our `Gemfile`.

## Using Serializer Generators
To serialize Tasks, we'll want to create a `TaskSerializer` and `TaskListSerializer`.
We can generate the scaffold for one using the built-in generator:

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

## Defining Serialized Attributes
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

### Serializing Associations
In addition to simple attributes, we can define associations that are serialized with the Task.
For example, if we wanted to include the User that owns the Task in the response:

```ruby
class TaskSerializer < ApplicationSerializer
  attribute :id
  attribute :name
  ...

  belongs_to :task_list
end
```

There are two primary differences between attributes and associations:
 1. Associations will always try to use a serializer. (ie. `belongs_to :task_list` will use the `TastListSerializer`.)
 2. Associations are only serialized to 1 layer of depth by default.
 
So, if we defined associations in our `TaskListSerializer`, they wouldn't be included in the User serialized
by the `task_list` attribute in the `TaskSerializer`.

For examples of serializers, take a look at others in `app/serializers`.

**NOTE**: Remember to define serializers for both the `Task` and `TaskList` models.

# Chapter 2 - Checklist

| [&larr; Chapter 1](./Chapter%201%20-%20Models.md) | [Back to Intro](../README.md) | [Chapter 3 &rarr;](./Chapter%203%20-%20Controllers.md) |
| --:| --:| --: |
