# ActiveGraphQL

[![Build Status](https://travis-ci.org/wakoopa/activegraphql.png)](https://travis-ci.org/wakoopa/activegraphql)

ActiveGraphQL connects classes to [GraphQL](http://graphql.org/) services.

## Installation

Add this line to your application's Gemfile:

```
gem 'activegraphql'
```

And then execute:

```
$ bundle
```

## How it works?

The library provides an `ActiveGraphQL::Model` class that, when subclassed and configured, encapsulates the communication with the service.

```ruby
class MyModel < ActiveGraphQL::Model
  configure url: 'http://some-graphql-service/endpoint'
end
```

Any subclass of `ActiveGraphQL::Model` provides the following methods:

- **all:** Retrive all objects for the entity.
- **where(conditions):** Retrieve all objects for the entity finding by conditions.
- **find_by(conditions):** Retrieve first object for the entity finding by conditions.

Any one of these methods returns an `ActiveGraphQL::Fetcher` who provides the method `fetch(*graph)` that is responsible of calling the service. The `*graph` arguments allow to specify how the response format will be.

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

## Localisation support
Any fetcher provides the `in_locale(locale)` method that makes the call to include the `HTTP_ACCEPT_LANGUAGE` header to get the content localized in case of the service supporting it.

```ruby
>> MyModel.all.in_locale(:en).fetch(:some_attribute).first.some_attribute
=> "This is my text"

>> MyModel.all.in_locale(:es).fetch(:some_attribute).first.some_attribute
=> "Este es mi texto"

# Also accepts strings as locale
>> MyModel.all.in_locale('es_ES').fetch(:some_attribute).first.some_attribute
=> "Este es mi texto"
```

## Configuration
### Http
`ActiveGraphQL::Query` uses [HttParty](https://github.com/jnunemaker/httparty) as codebase for http calls.
The [http options](http://www.rubydoc.info/github/jnunemaker/httparty/HTTParty/ClassMethods) used to perform requests can be configured.

```ruby
class MyModel < ActiveGraphQL::Model
  configure http: { timeout: 0.1 }
end
```

### Retriable
This gem supports retriable strategy with randomized exponential backoff, based on [Retriable](https://github.com/kamui/retriable).
Retriable is disabled by default, so `ActiveGraphQL::Model.configure` accepts the available options for [Retriable#retriable](https://github.com/kamui/retriable#options).

NOTE: Configuring `retriable: true` will activate `Retriable` with its defaults.

```ruby
class MyModel < ActiveGraphQL::Model
  configure retriable: { on: [Timeout::Error, Errno::ECONNRESET],
                         tries: 10,
                         base_interval: 0.5,
                         max_interval: 1 }
end
```

### Authorization
It's currently supporting simple bearer authorization using `auth` option.

It basically offers two configuration params:

- `strategy`: Currently, `bearer` strategy is the only one available.
- `class`: The existing strategy uses your own custom class to encode a token (the class must provide at least an `.encode` class method).

Your encoder class may look like that:
```ruby
class YourEncoderClass
  def self.secret 
    'your-safely-secured-secret'
  end

  def self.encode
    # You could have custom stuff here like adding expiration to the payload.
    payload = { exp: (Time.current.to_i + 100) }
    JWT.encode(payload, secret)
  end
  
  def self.decode(token)
    JWT.decode(token, secret)
  end
end
```

Then your configuration would look like the next:
```ruby
class MyModel < ActiveGraphQL::Model
  configure auth: { strategy: :bearer, class: YourEncoderClass }
end
```


