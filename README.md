# Sinatra/PG Custom Model

An attempt to understand/recreate the inner workings of ActiveRecord. More an educational exercise than an attempt to re-invent the wheel.

Please feel free to fork and play around with it.

## BaseModel class

All the magic is happening in `/models/base_class.rb`

There's some real nice methods that I was able to use:

Method name | Type  | Description |
------------|-------|-------------|
`inherited` | Class | Fired when a subclass is instantiated, so you can run some setup on the new class. Pretty baller. |
`class_eval`| Class | A guess a bit like `eval` in JavaScript, takes a string, and attemptes to evaluate it in the context of the class. I used it to dynamically create `attr_accessors` based on the database table's field names. |
`instance_variable_set`| Class | Used to dynamically create instnace variables. |
`instance_methods` | Instance | Returns an array of the instance methods, expressed as `symbols`. Used to create SQL statements based on the instance's reader methods |

## Issues

- Not fully tested
- I have no idea if its safe to use in production
- Only works with Postgres
- Only tested with a very simple model
- No real error handling
- No tests