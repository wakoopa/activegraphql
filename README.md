# ActiveGraphql

ActiveGraphql connects classes to [GraphQL](http://graphql.org/) services.
The library provides a **Model** class that, when subclassed and configured, encapsulates the communication with the service.

```ruby
class MyModel < ActiveGraphql::Model
  configure url: 'http://some-graphql-service/endpoint'
end
```

Any subclass of `ActiveGraphql::Model` will provide the following methods:

- **all:** Retrive all objects for the entity.
- **where(conditions):** Retrieve all objects for the entity finding by conditions.
- **find_by(conditions):** Retrieve first object for the entity finding by conditions.

Any one of these methods returns an `ActiveGraphql::Fetcher` who provides the method `fetch(*graph)` that is responsible of calling the service. The `*graph` arguments allow to specify how the response format will be.

For convention, any method is performing a call to the service with a query, that is resolved based on: model class name, conditions and graph.

**Retrieving all `MyModel` objects (just ask for retrieving `id`)**

```ruby
>> MyModel.all.fetch(:id).first.id
=> "1"
```

Resolved query:

```
{ myModels { id } }
```

**Retrieving all `MyModel` objects with `value == "a"` (ask for `id` and `name`)**

```ruby
>> m = MyModel.where(value: 'a').fetch(:id, :name).first

>> m.id
=> "3"

>> m.name
=> "Whatever"
```

Resolved query:

```
{ myModels("value": "a") { id, name } }
```

**Retrieving `MyModel` object with `id == "5"` (ask for `id`, `name` and `nestedObject { id }`)**

```ruby
>> m = MyModel.find_by(id: '5').fetch(:id, :name, nested_object: [:description])

>> m.id
=> "5"

>> m.name
=> "Whatever"

>> m.nested_object.description
=> "Some description here"
```

Resolved query:

```
{ myModel("id": "5") { id, name, nestedObject { description } } }
```
