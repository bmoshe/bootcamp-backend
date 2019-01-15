# Chapter 6 - Concerns
In a Rails application, concerns act as a container for shared logic.
Unlike inheritance however, concerns are intended to encapsulate individual, unrelated behaviours.
For example: We'll we adding a `Taggable` concern to encapsulate behaviours related to an object that has attached tags.

Other examples of what concerns might be used for:
 - A `Searchable` concern might be used to add a `search` method to a model
 - A `Completable` concern might add `incomplete_fields` and `complete?` methods to a model
 - A `Lockable` concern could add functions that lock/unlock a record, and prevent it from being changed

If you've worked with a language that has mixins, partial classes,
or even interfaces with default method implementations, concerns largely fill the same niche.

## Defining the Taggable Concern
The Rails documentation includes a section on Concerns, which you can find here:
https://api.rubyonrails.org/classes/ActiveSupport/Concern.html

We'll start by defining the `Taggable` concern. Rails doesn't provide a generator for concerns,
so start by creating a file at `app/models/concerns/taggable.rb`.

Unlike models, controllers, policies, etc. which are `class`es, concerns are `module`s which are intended to be
included into other classes, rather than being used directly.
Below is general structure for our concern:

```ruby
module Taggable
  extend ActiveSupport::Concern

  included do
  end
end
```

### Include, Extend, and Prepend
Ruby modules and classes both provide the family of functions: `include`, `extend`, and `prepend`.
Their behaviours and differences are a little nuanced, however the article below explains each of them fairly well:
https://medium.com/@leo_hetsch/ruby-modules-include-vs-prepend-vs-extend-f09837a5b073

In particular, note that we use `extend` in our `Taggable` concern. This provides us with the `included` DSL function
(in addition to other DSL functions which we're not using right now).
The content of the block we pass to the `included` function is interpolated into whatever module or class we `include`
our concern into.

For `Taggable` objects, it makes sense that they would have tags attached, so we can add the association directly into
the concern, like so:

```ruby
included do
  has_many :object_tags, as: :taggable, dependent: :destroy
  has_many :tags, through: :object_tags
end
```

## Making Models Taggable
Now that we've defined the `Taggable` concern, we're ready to use it in our models. Currently, `TaskList` and `Task` both
have associations to the `Tag` model.
We can replace them by including the `Taggable` concern into the model:

```ruby
class TaskList < ApplicationRecord
  include Taggable

  ...
end
```

Once the concern is included in both `TaskList` and `Task`, we can remove the associations we previously defined directly
on the model. We can quickly verify that everything still works in the console:

```ruby
task = Task.last
task.tags
```

# Chapter 6 - Checklist
Here's a checklist of things that you should've covered by the time you've finished with this chapter:

- [ ] Define the `Taggable` concern.
- [ ] Add the `object_tags` and `tags` association to the `Taggable` concern.
- [ ] Include the `Taggable` concern in the `TaskList` and `Task` model.

(If you're concerned that you've missed something, just ask for help!)

| [&larr; Chapter 5](./Chapter%205%20-%20Polymorphic%20Associations.md) | [Back to Intro](../README.md) | [Chapter 7 &rarr;](./Chapter%207%20-%20GraphQL%20Types.md) |
| --:| --:| --: |
