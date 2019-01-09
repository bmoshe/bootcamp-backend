# Chapter 3 - The Tasks and TaskLists Controllers
Before we start, you can read more about Rails controllers here:
http://guides.rubyonrails.org/action_controller_overview.html#what-does-a-controller-do-questionmark

Controllers are the part of our system that receives incoming requests from the client, and dispatches method calls
into our codebase. They serve as the interface which the client can call, almost as if it were calling a function.

Our frontend needs to interact with both Tasks and TaskLists.
For TaskLists, the frontend needs to be able to:
 - View all of the User's Task Lists
 - Fetch a specific Task List, by its ID
 - Create a new Task List
 - Edit an existing Task List
 - Delete a Task List

For Tasks, the following operations are needed:
 - View all the Tasks in a specific Task List
 - Add a Task to an existing Task List
 - Edit an existing Task
 - Mark as Task as completed
 - Delete a Task

These actions will be performed by controllers, which will also be responsible for deciding what the client
receives as a response, once the actions are complete.

## Part 1 - The TaskLists Controller

## Using Controller Generators
To get started, we'll be using Rails' generators to scaffold our controller.
We're going to start with the `TaskListsController`, and then move onto the `TasksController`.
To generate a new controller, we write:

```bash
rails g controller TaskLists
```

**NOTE:** Controller names are plural! A controller represents the entire collection of a particular resource
(ie. In our case, all of the TaskLists that exist in the system), and Rails expects them to have a pluralized name
in order to be able to route calls to them correctly.

This generator creates the following files:
 - `app/controllers/task_lists_controller.rb` which is the actual controller.
 - `spec/controllers/task_lists_controller_spec.rb` is an RSpec file, where we define tests for the controller.

## Defining Actions
Controller actions represent methods that the client is able to remotely call.

As an API, we have 5 basic actions that we care about:

| Name | Description |
| ---- | ----------- |
| index | Get a list of items. For example, get a list of all Task Lists. |
| show | Fetch a specific item, by ID. |
| create | Create a new item. |
| update | Edit an existing item. |
| destroy | Delete an existing item. |

These correspond to specific HTTP verbs and URLs. Let's take Task Lists for example:

| Verb | Path | Action |
| ---- | ---- | ------ |
| GET  | /task_lists | index |
| GET  | /task_lists/:id | show |
| POST | /task_lists | create |
| PATCH | /task_lists/:id | update |
| DELETE | /task_lists/:id | destroy |

### Rendering JSON
In a traditional Rails App, controllers hand off data to views which render either HTML or XML using ERB.
Stuff we don't really care about.
Since we're an API, that's not going to work for us. Luckily, we (should) have already defined a serializer
for out Task List model, which will take care of the heavy lifting for us.

All we need to do is tell the controller to call the serializer. All we need to do is call `render(...)` and
pass the object we want to serialize under the `json` key of a Hash. For example:

```ruby
def show
  @task_list = TaskList.find(params[:id])
  render json: @task_list
end
```

ActiveModelSerializers automatically hooks into Rails controllers and takes over from here. It'll look up a
serializer based on the class of the parameter, convert it into JSON, and Rails will send that off to the client.

### Strong Parameters
For the `create` and `update` actions, we'll need to accept parameters from the client. However, we can't trust
that the client will send what we want them to! It's very important that we filter the parameters we receive,
and only use those that we require.

Rails provides a mechanism for keeping inputs clean, called Strong Parameters. Here's a link we you can find
more information on the subject:
http://edgeguides.rubyonrails.org/action_controller_overview.html#strong-parameters

In our case, we want the user to be able to set the `name` flag on a `TaskList`, but we don't want
them to be able to touch any of the others. To do this, we'd define a `task_list_params` method:

```ruby
def task_list_params
  params.require(:task_list).permit(:name, :completed)
end
```

The `.require(:task_list)` call we make tells Rails to verify that the incoming parameters includes a `task_list: {}`.
If it's missing, it'll throw an error, and that'll automatically be converted to an HTTP error code.
Otherwise, it returns the contents of the `task_list: {}` object.

Essentially, we're expecting the parameters to be wrapped in a `task_list` object, like so:

```json
{
  "task_list": {
    "name": "Upcoming Tasks"
  }
}
```

The `.require(...)` returns the object containing the `name` field, which we whitelist with the
subsequent call to `.permit(...)`.

### Clean up with Callbacks
Much like models, controllers support callbacks that allow us to automatically call methods at specific points in
time. Rails refers to callbacks in controllers as 'Filters'. You can read more about them here:
http://guides.rubyonrails.org/action_controller_overview.html#filters

In our case, we can use them to clean up a bit of duplicated set up logic. The `show`, `update`, and `destroy`
actions refer to a specific resource, (ie. they're called on a specific `TaskList`), so we can pull out the logic
that loads that `TaskList` from the DB.

To do this, we write:

```ruby
class TaskListsController < ApplicationController
  before_action :set_task_list, only: %i[show update destroy]

  ...

  def set_task_list
    @task_list = TaskList.find(params[:id])
  end
end
```

Now we have a `@task_list` instance variable predefined for all of these actions!

### Error Handling
Our `ApplicationController` (the base class for all our controllers) already implements interceptors that catch
exceptions and gracefully render error messages or status codes back to the client.

Currently, it's set up to handle:
 - `ActiveRecord::RecordNotFound`
 - `ActiveRecord::RecordInvalid`
 - `ActiveRecord::RecordNotSaved`
 - `ActiveRecord::RecordNotDestroyed`

Have a look at what throws these exceptions in Rails, and how you can leverage those systems to use the error handling
we already have in place.

## Routing
Once we have our controller in place, we need to tell Rails how to route requests to the methods in the controller.
Rails' routing is described in detail by this guide:
http://guides.rubyonrails.org/routing.html#the-purpose-of-the-rails-router

Routes are defined in `config/routes.rb`.
In our case, we want to define a resource, which Rails has a convenient helper for:

```ruby
resources :task_lists
```

**NOTE:** There's a difference between `resources` and `resource`. In our case, we want to use `resources`,
because we're defining a plural (rather than a singular) resource.
If you're interested in the difference, it's described in detail by this guide:
http://guides.rubyonrails.org/routing.html#singular-resources

To view all of the routes currently in our app, we can run:

```bash
rails routes
```

## Part 2 - Moving onto the Tasks Controller
If you haven't done so yet, it's time to create the `TasksController`. We can do so using the generator:

```bash
rails g controller Tasks
```

The `TasksController` is going to work a little differently, however.
For tasks, we only really need them in the context of some specific task list.
(For example: If you're looking at your 'Work' list, you don't care about tasks from your 'Side Projects' list.)

We're going to structure our API to reflect this, by making tasks a sub-resource of task lists.
This means the routes are going to be a little different:

| Verb | Path | Action |
| ---- | ---- | ------ |
| GET  | /task_lists/:task_list_id/tasks | index |
| GET  | /task_lists/:task_list_id/tasks/:id | show |
| POST | /task_lists/:task_list_id/tasks | create |
| PATCH | /task_lists/:task_list_id/tasks/:id | update |
| DELETE | /task_lists/:task_list_id/tasks/:id | destroy |

Notice how the `:task_list_id` parameter appears as part of every route.

### Working with Sub-Resources
With sub-resources, we're working with multiple models, instead of just one.
If you recall the `show` method we wrote for the `TaskListsController`, it would lookup a `TaskList` by ID.
Since we're dealing with multiple IDs now, we'll need to use each of them to drill downwards.

The change is actually simpler than it sounds:
```ruby
def show
  @task_list = TaskList.find(params[:task_list_id])
  @task = @task_list.tasks.find(params[:id])
  render json: @task
end
```

Note how we use the `tasks` association that we defined on the `TaskList`.
This will ensure that the `:id` parameter actually corresponds to a task in the task list specified by `:task_list_id`,
(so, it won't find the task if it's part of a different task list).

### Using Callbacks for Structure
In every action of the `TasksController`, we will have access to a `:task_list_id` parameter, which will contain
the ID of the parent task list. Since the logic to look-up the task list will be identical for each action, we can
use a callback to extract the handling into a single method.

This should look something like:

```ruby
class TasksController < ApplicationController
  before_action :set_task_list
  before_action :set_task, only: %i[show update destroy]

private

  def set_task_list
    @task_list = TaskList.find(params[:task_list_id])
  end

  def set_task
    @task = @task_list.tasks.find(params[:id])
  end
end
```

Above, the `set_task` function also demonstrates how we can pull out the common logic of fetching a `Task` by its ID.

### Routing with Sub-Resources
Defining the routes for our sub-resource is actually very simple, and the structure is fairly intuitive.
In routes file (`config/routes.rb`), we nest the `tasks` resource under `task_lists`, like so:

```ruby
resources :task_lists do
  resources :tasks
end
```

You can verify that everything is set up correctly by running:

```bash
rails routes
```

## Writing RSpecs
There's already specs for the `SessionsController`, which might be useful as a reference when writing tests for your
own controller. You can find them in `spec/controllers/sessions_controller_spec.rb`.
In particular, it demonstrates how to create authenticate with the API using a Session.

# Chapter 3 - Checklist
Here's a checklist of things that you should've covered by the time you've finished with this chapter:

- [ ] Create a `TaskListsController` and define its routes.
- [ ] Implement the `index`, `show`, `create`, `update`, and `destroy` actions in `TaskListsController`.
- [ ] Create a `TasksController` as a sub-resource of task lists.
- [ ] Implement the `index`, `create`, `update`, and `destroy` action in `TasksController`.
- [ ] Moved common logic between actions into callbacks.
- [ ] Write RSpecs for `TaskListsController` and `TasksController`.

(Checked off everything on the list? Looks like you're in control of the situation.)

| [&larr; Chapter 2](./Chapter%202%20-%20Serializers.md) | [Back to Intro](../README.md) | [Chapter 4 &rarr;](./Chapter%204%20-%20Policies.md) |
| --:| --:| --: |
