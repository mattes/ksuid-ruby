# KSUID for Ruby

## Installation

Add this line to your application's Gemfile:

```ruby
gem "ksuid", github: "mattes/ksuid-ruby"
```

To automatically use KSUID as primary key in migrations, create the following initializer:

```ruby
# config/initializers/ksuid.rb
Rails.application.config.generators do |g|
  g.orm :active_record, primary_key_type: :ksuid
end
```

## Changes

This fork of [michaelherold/ksuid-ruby](https://github.com/michaelherold/ksuid-ruby) has a couple of changes:

### Native `ksuid` types for Postgres and SQLite

Previously each model had to be annotated with `act_as_ksuid` directives (see below). This fork adds native `ksuid` types
for Postgres and SQLite. For SQLite this works out of the box because of it's dynamic typing.  
For Postgres you will have to create a custom type by hand first by running `CREATE DOMAIN ksuid AS text` once.

Please note that MySQL does not support custom types, you're stuck with `act_as_ksuid`. 


### `act_as_ksuid`

Old way:

```ruby
class Event < ApplicationRecord
  include KSUID::ActiveRecord[:foobar]
end
```

New way:

```ruby
class Event < ApplicationRecord
  act_as_ksuid :foobar
end
```


### Initialize KSUIDs only for Primary Keys

Previously `act_as_ksuid` and `include KSUID::ActiveRecord[:foobar]` both blindly initialized ksuid attributes with
a new KSUID. Now it only initializes a KSUID for primary keys. I believe this is the expected behavior, much like Postgres'
serial auto-increment - it only updates the primary key, not foreign key's for example.


### Support for `to_json` and `to_yaml`

If you marshal a model to JSON or YAML, `to_json` and `to_yaml` will convert KSUIDs into strings.
