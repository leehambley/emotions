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
liked, or disliked.

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

These methods can be passed instances of any class which has those emotions defined.

Passing anything else will cause undefined behaviour.

## Inspiration

*Emotions* is inspired by ~~`gowalla`~~`schneems/likeable`. A few
things concerned me about that project, so I re-wrote after contributing
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
