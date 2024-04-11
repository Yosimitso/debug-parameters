![alt text](https://github.com/Yosimitso/debug-parameters/blob/master/addons/debug_parameters/example_1.png?raw=true)

An editor and in game panel to test your game with different parameters

A Godot 4 GDScript plugin

# From editor
## 1/ Choose a profile
You an use the global profile or create a new one base on set of parameters (ex: hard conditions for a racing game)

The selected profile is the current profile

**When your run your game the global profile parameters will always be loaded in addition of the current profile**,
so you'll be able to get param from both profiles

The current profile will override the global profile if two parameters have the same slug

## 2/ Create your parameters
From the "add parameter" block, only "slug" must not be empty
- Type : restrict values based on your business logic, ex a boolean correspond to a checkbox, a string could correspond to text or list type
- Label : only used in editor dock
- Slug : string to get your parameter's value in your game, ex to get parameter "player_name" you will use DebugParameters.get_value('player_name')
- Tooltip : additional information about the parameter

The created parameter will be added to the current profile

## 3/ Set parameters' values to test with
Fill the values according to your test, you can use static or dynamic values (see below)

### Dynamic values
The plugin supports dynamic value from a Callable

The Callable can refers to :
- a function, static function, const or enum from a singleton class (autoload)
- a static function, const or enum from a class name (registered with class_name)

Be careful, the value returned by your function is not checked against the parameter type and affected as-is  

The plugin won't instantiate any custom class

To use a dynamic value :
- use the syntax : ``YourClass.your_function_or_others(args)``
- if you use an argument, it will be evaluated if it's among :
  - profile_name = current profile name
- example : ``Player.get_random_car(profile_name)`` 

## 4/ Run a scene or the whole game
# From a running scene

Get parameter's value
------------------------
Use ``DebugParameters.get_value('your_slug')``

Set up a callback when a parameter's value is updated
-----------------------------------
If you modify values from the ingame dock, the addon will emit the new value, to get the signal and connect it, use :
``DebugParameters.get_param_update_signal('your_slug').connect(your_function)``

or ``DebugParameters.get_param_update_signal('your_slug').connect(func(new_value): whatever)``
