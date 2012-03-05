# Emotions

**Store emotions in Redis.** *Emotions* allows the storage of emotions in
Redis, a fast and atomic structured data store. If one's users *hate*, *love*,
*appreciate*, *despise* or *just-don-t-care*, one can store that easily via a
simple API.

It is not bound to `ActiveRecord`, and any model conforming to the `ActiveModel`
conventions should work just as well.

``` ruby
class CatPicture < ActiveRecord::Base

  include Emotions::Emotive
  emotions :like, :dislike

end
```

This simple example shows that in our logical model cat pictures can either be
liked, or disliked. The following methods are available to all instances of `CatPicture`:

 * `number_of_like`
 * `number_of_likes` (if `ActiveSupport::Inclector` is available.)
 * `emotion_summary` Returns a hash such as: `{like: 456, dislike: 3}`

On the flip-side, one needs a way to share one's feelings, from the model representing
a user, or rater, or similar, one can easily use the opposite:

``` ruby
class User < ActiveRecord::Base
  
  include Emotions::Emotional

end
```

This module will mix-into the `User` the following methods:

 * `like(something_likeable)`
 * `cancel_like(something_likeable)`
 * `dislike(something_dislikeable)`
 * `cancel_dislike(something_dislikeable)`
 * `like?(something_likeable)`

These methods can be passed instances of any class which has those emotions defined.

**Passing anything else will cause undefined behaviour.**

There's another module, not strictly related, but one may find it useful.

``` ruby
class Suggestion
  include Emotion::Dismissable
end
```

The `Dismissable` module allows a special-case emotion `_dismissed_`, to stored that can 
be used to represent whatever concept makes sense in the project scope. In this example case 
we have a `Suggestion`, which may, or may not be persisted. 

The *dismissed* emotion is special because it will serialize the `Suggestion` 
The `Suggestion` instance will be
serialized and stored, and the `Emotional` item that dismissed the Suggestion will have a

## Inspiration

*Emotions* is inspired by [`schneems/likeable`](https://github.com/schneems/Likeable). A few
things concerned me about that project, so I wrote *emotions* after contributing
significant fixes to *likeable*.

### What's different from *likeable*?

* There are no hard-coded assumptions about which emotions you'll be using, that's
  up to your project needs.

* There are no callbacks, these are better handled with observers, either in the 
  classical OOP meaning of the word, or your framework's pattern. (In Rails they're
  the samne thing)

* A *very* comprehensive test suite, written with *Minitest*. *Likeable* is quite
  simple, and has about ~35 tests, that might be OK for you, and Gowalla, but I'd
  feel better with real unit, functional and integration tests.

* It's not *totally* bound to Redis. Internally there's a Key/Value store proxy, this
  uses Redis out of the box, but it should be easy for someone to replace this with
  MongoDB, Riak, DynamoDB, SQLite, etc.

* It does not depend on `ActiveSupport`, *likeable* depends on *keytar*, which depends
  on `ActiveSupport` for inflection and `ActiveSupport::Concern.`

* It does not depend on `Keytar`, Keytar is a handy tool for building NoSQL keys for 
  objects, however it's a little bit over-featured for this use-case.

## Installation

Add this line to your application's Gemfile:

    gem 'emotions'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install emotions

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## Sample Key Structure

Given the following example, the key 
structure would be:

``` ruby
class Recommendation
  iclude Emotions::Emotive
  emotions :like
end

class User
  include Emotions::Emotional
end

User.find(123).like(Recommendation.find(789)
User.find(123).like(Recommendation.find(987)

User.find(321).like(Recommendation.find(789)
```

The resulting Redis structure would be something like this:

``` text
user:like:123:recommendation
  "789" "2012-11-13 00:01:02 +01:00"
  "987" "2011-02-01 00:03:01 +01:00"

user:like:321:recommendation
  "789" "2014-02-01 17:15:01 +01:00"

recommendation:like:789:user
  "123" "2012-11-13 00:01:02 +01:00"
  "321" "2014-02-01 17:15:01 +01:00"

recommendation:like:987:user
  "123" "2011-02-01 00:03:01 +01:00"
```
