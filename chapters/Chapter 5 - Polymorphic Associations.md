# Chapter 5 - Polymorhpic Associations
By now, we should have a functioning system for creating Task Lists and Tasks. The next part of this project will focus
on adding Tags to both Task Lists and Tasks.

To do this, we'll be using the `Tag` model, which is already provided for you. The `Tag` model represents a tag that
can be attached to some other record in the database.
However, unlike the existing relationships in our data structure, a single Tag might be attached to many different Tasks,
and a single Task might have many different Tags attached to it. This kind of relationship is said to be Many-to-Many.

In order to implement this, we'll need another table (which is called a join-table or pivot table), where represents the
relationship between any one Tag and any one object that it's attached to.
Furthermore, a Tag can be attached to both Task Lists and Tasks. To support this behaviour, we're going to use a
Polymorphic Association.

## Creating the ObjectTag Model
The `ObjectTag` model will represent the relationship between any one `Tag` and any of `Taggable` object.
To create the table and it's model, we use a generator.
Refer to [Chapter 1](./Chapter%201%20-%20Models.md) if you need to refresh your memory on model genrators.

Each `ObjectTag` will belong to a `Tag`, and also belong to a `Taggable` object.
In our migration, we would write this as follows:

```ruby
create_table :object_tags do |t|
  t.references :tag, foreign_key: true, null: false
  t.references :taggable, polymorphic: true, null: false
  ...
end
```

This portion of the migration will do the following:
 - Create a `tag_id` column, which acts a reference to a `Tag`.
 - Create a `taggable_id` and `taggable_type` column, which acts as a reference to some model.

This additional `taggable_type` column will store a name of a model, allowing a relationship to many different tables,
instead of just one. Unfortunately, this kind of relationship doesn't permit us to use a foreign key constraint.
However, tags are generally non-essential information, so it's not too big of an issue.

To declare these relationships in the `ObjectTag` model, we write:

```ruby
class ObjectTag < ApplicationRecord
  belongs_to :tag
  belongs_to :taggable, polymorphic: true
  ...
end
```

The `polymorphic:` flag tells Rails to look for the corresponding `_type` field, in addition to the `_id` that's normally used.

## Adding Associations to Taggable Objects
In our system, we consider Task List and Task to be taggable. This means that they can have attached tags.
To support this, we need to declare associations on the `TaskList` and `Task` models.

Below is an example of how this would look for the `TaskList` model:

```ruby
class TaskList < ApplicationRecord
  ...
  has_many :object_tags, as: :taggable, dependent: :destroy
  has_many :tags, through: :object_tags
  ...
end
```

Above, we use the `as: :taggable` property to inform Rails that this is the object that goes into the `:taggable`
polymorphic association. This is necessary, since Rails cannot automatically infer which association we're referring to.
We also use the `dependent: :destroy` property to ask Rails to clean up any orphaned records. This way, if we delete the
`TaskList`, any associated `ObjectTag` records will also get deleted.

Finally, we define the `:tags` association using the `through: :object_tags` property. Tags aren't directly associated
to the TaskList, but the association does exist through the `object_tags` table. To make use of this, we tell Rails
to tunnel through another association.

**NOTE**: Remember to also declare these associations on the `Task` model.

### Interacting with Tags
Now that the `TaskList` and `Task` models have associations to `Tag`, we can start attaching them.
Below, we'll go over a couple of common operations we can perform on tags.

To add a single Tag to a Task:

```ruby
tag  = Tag.first
task = Task.first
task.tags << tag
```

To add multiple Tags to a Task:

```ruby
tags = Tag.first(3)
task = Task.first
task.tags += tags
```

To set the list of Tags on a Task:

```ruby
task = Task.first
task.tags = [Tag.first, Tag.last]
```

To set the list of Tags using IDs:

```ruby
task = Task.first
task.tag_ids = [1, 2, 3]
```

To clear the list of Tags:

```ruby
task = Task.first
task.tags = []
# OR
task.tag_ids = []
```

### Including Tags in Serialization
So that Tags can be displayed on the frontend, they'll need to be included in the serialization of Task Lists and Tasks.
Adding Tags to a serializer is pretty simple. For example, to add them to the `TaskSerializer`:

```ruby
class TaskSerializer < ApplicationSerializer
  ...
  has_many :tasks
end
```

The `TagSerializer` will automatically be used to serialize the records in the association into JSON.

### Permitting Task in Policies
The frontend should be able to set which Tags are attached to a Task or TaskList. We'll need to update the Policies to
accept parameters from the frontend.
To do this, we'll need to permit the `tag_ids` parameter. This way, the frontend can send a list of Tag IDs, and Rails
will take care of adding or removing Tags are necessary.

Below is what this might look life for the `TaskListPolicy`:

```ruby
def permitted_attributes
  [:name, :tag_ids, tag_ids: []]
end
```

**NOTE**: Notice how `tag_ids` appears twice? The first occurrence (`:tag_ids`) permits a scalar value, whereas the
second occurrence (`tag_ids: []`) permits an Array of scalars. We do this because we want to be able to accept a list
of IDs, but also need to accept an empty with (to remove all tags). Rails coerces an empty array `[]` into a scalar
value `null`.

# Chapter 5 - Checklist
Here's a checklist of things that you should've covered by the time you've finished with this chapter:

- [ ] Create an `ObjectTag` model.
- [ ] Add the `tags` associations to both `TaskList` and `Task`.
- [ ] Include `tags` in the serialization of both `TaskList` and `Task`.
- [ ] Accept the `tag_ids` parameter from the frontend.

(Checked off everything on the list? Looks like you're in control of the situation.)

| [&larr; Chapter 4](./Chapter%204%20-%20Policies.md) | [Back to Intro](../README.md) | [Chapter 6 &rarr;](./Chapter%206%20-%20Concerns.md) |
| --:| --:| --: |
