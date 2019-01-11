# Chapter 4 - The Task and TaskList Policies
Pundit is a gem we use to manage authorization. It provides a framework for us to be able to control which users
can take which actions, which records they're allowed to view and touch, and which attributes they're allowed to
change.
For more information about using Pundit, see:
https://github.com/varvet/pundit

You can also have a look at the policy we've already defined for Sessions in `app/policies/session_policy.rb`.

## Using Policy Generators

```bash
rails g pundit:policy TaskList
```

This generator creates the following files:
 - `app/policies/task_list_policy.rb` which is the policy itself.
 - `spec/policies/task_list_policy_spec.rb` is an RSpec file, where we define tests for the policy.

## Permitted Actions
Actions in policies correspond to actions in the controller. For example, if you wanted to control whether a
User is allowed to edit TaskLists, you'd define an `update?` method in your policy, which would be called by the
`update` method in your controller.

Let's say we wanted to let Users edit their own tasks. We'd want to verify two things:
 1. There is a logged-in User.
 2. The User that owns the TaskList matches the current User.

We could do this by writing:

```ruby
def update?
  current_user.present? && current_user == record.current_user
end
```

In a policy, the `current_user` attribute refers to the User that is currently logged in (it's automatically
passed in from the controller), and `record` refers to the record that you're checking authorization for.
In the case of `update?`, this would be the TaskList the current user is trying to edit.

Since `record` is a little ambiguous, we can add an alias to improve readability. At the top of the policy,
add:

```ruby
class TaskListPolicy < ApplicationPolicy
  alias task_list record
  ...
end
```

Now we can rewrite our `update?` method as:

```ruby
def update?
  current_user.present? && current_user == task_list.user
end
```

To call the policy in a controller, we use `authorize(...)`. For example:

```ruby
def update
  authorize(@task_list)
  @task_list.update!(task_list_params)
  render json: @task_list
end
```

The `.authorize(...)` method accepts a model, looks up the policy for it, and calls the appropriate method
to verify that the current action is permitted. If the policy returns `false`, an exception is thrown,
and the API will automatically return an HTTP error code.

Since `.authorize(...)` uses exceptions to enforce authorization, it just returns the input parameter upon
success. This makes it convenient for chaining calls together!

```ruby
def update
  authorize(@task_list).update!(task_list_params)
  render json: @task_list
end
```

### Permitted Actions on Tasks
Since the `Task` model is a logical child of the `TaskList`, we can use this to our advantage.
Instead of writing the ownership checks all over again, we can leverage the `TaskListPolicy`.

For example, if we know that a User is allowed to view a particular Task List, we can assume
that they should also be able to view the Tasks in that list.
In code, that would translate to:

```ruby
class TaskPolicy < ApplicationPolicy
  ...
  def show?
    Pundit.policy(current_user, task.task_list).show?
  end
  ...
end
```

The `policy(...)` method we called above constructed an instance of the `TaskListPolicy` for us.

## Permitted Attributes
Policies are also responsible for defining which attributes the client is allowed to change on the model.
We do this using the `permitted_attributes` method, which returns an array of attributes that are whitelisted.
For example, if we wanted to allow the User to set the `name` on a TaskList, we'd write:

```ruby
def permitted_attributes
  %i[name]
end
```

Now that we've defined our permitted attributes, the next step is to use them from the controller. We do this
with the `permitted_attributes(...)` method. It takes a model and automatically looks up the policy, fetches
the list of attributes permitted for the current action, and filters the incoming parameters.

This means we can get rid of our `task_list_params` function, and instead do:

```ruby
def update
  authorize(@task_list).update!(permitted_attributes(TaskList))
  render json: @task_list
end
```

The same applies to our `create` function.

### Action-Specified Permitted Attributes
We're also able to set which attributes are allowed, based on which action is being taken.
For this example, we're going to use the `Task` model.
Let's say we want to allow just the name during creation, but also allow the `completed` flag during edits:

```ruby
def permitted_attributes_for_create
  %i[name]
end

def permitted_attributes_for_update
  %i[name completed]
end
```

To use these attributes from the controller, we still just call `permitted_attributes(...)`. The correct set
of permitted attributes will automatically be inferred from the controller action that's been called.

## Policy Scopes
Before we go into scopes, it's a good idea to dive into how the Rails query builder works. You can find details
on it here: http://guides.rubyonrails.org/active_record_querying.html#retrieving-objects-from-the-database

Scopes are what defines what list of records is visible to a particular User. Since it would be horribly inefficient
to load every record in the database, and filter them with some function in memory, we need something to build a query
that contains only records the User has access to. That's the job of the Policy Scope.

The generator should've created a stub Scope for you already. It might look something like this:

```ruby
class Scope < Scope
  def resolve
    scope
  end
end
```

**NOTE:** Don't be alarmed by `Scope < Scope`! The second one refers to a class with the same name defined on the
parent class. It's essentially saying `class TaskListPolicy::Scope < ApplicationPolicy::Scope`.

This default `resolve` method is basically a no-op. It takes the input `scope` and returns it as-is. We want to
make sure that Users only see their own Tasks. To do this, we would change this to:

```ruby
def resolve
  scope.where(user: current_user)
end
```

Now we're reducing the Scope to only include TaskLists that are owned by the current user. However, we can make this
a little more efficient. If there's no current User (ie. the client isn't logged-in), this will still make a query
`WHERE task_lists.user_id IS NULL`. This query is unnecessary, since there shouldn't ever be TaskLists without a User.
To eliminate this unnecessary call:

```ruby
def resolve
  return scope.none if current_user.nil?

  scope.where(user: current_user)
end
```

This `.none` method implements a Null-Object Design Pattern. It behaves like a normal query, but always returns an
empty result without making an actual database call.

### Using Policy Scopes
Scopes are predominantly used in controllers. Since their role is restrict a set of records to those that a User
can see, controllers are the place where this becomes most relevant.

To use the Scope in a controller, we use the `policy_scope(...)` function.
For example, in the `index` action of our `TaskListsController`, we'd do something like this:

```ruby
def index
  authorize(TaskList)
  @task_lists = policy_scope(TaskList)
  render json: @task_lists
end
```

To use the Scope outside of a controller, we can just construct an instance of the object
(it's a plain-old Ruby object), and call the `resolve` method.

```ruby
user       = User.find(1)
scope      = TaskListPolicy::Scope.new(user, TaskList)
task_lists = scope.resolve
```

## Writing RSpecs
For an example of how to write specs for a Policy, take a look at the specs we already have for the `SessionPolicy`.
They can be found in `spec/policies/session_policy_spec.rb`.

# Chapter 4 - Checklist
Here's a checklist of things that you should've covered by the time you've finished with this chapter:

- [ ] Create a `TaskListsController` and define its routes.
- [ ] Implement the `index`, `show`, `create`, `update`, and `destroy` actions in `TaskListsController`.
- [ ] Create a `TasksController` as a sub-resource of task lists.
- [ ] Implement the `index`, `create`, `update`, and `destroy` actions in `TasksController`.
- [ ] Moved common logic between actions into callbacks.
- [ ] Write RSpecs for `TaskListsController` and `TasksController`.

(Checked off everything on the list? Looks like you're in control of the situation.)

| [&larr; Chapter 3](./Chapter%203%20-%20Controllers.md) | [Back to Intro](../README.md) | [Chapter 5 &rarr;](./Chapter%205%20-%20Polymorphic%20Associations.md) |
| --:| --:| --: |
