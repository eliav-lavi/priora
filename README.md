# Priora: An Object Prioritization Utility for Ruby
[![Gem Version](https://badge.fury.io/rb/priora.svg)](https://badge.fury.io/rb/priora)
[![Maintainability](https://api.codeclimate.com/v1/badges/7a45f13797375a92b558/maintainability)](https://codeclimate.com/github/eliav-lavi/priora/maintainability)

Priora supplies an easy and intuitive way to prioritize a collection of objects in Ruby.
It serves as a useful utility for working with a collection of several instances of some data class.
Often, we would like to get that collection arranged according to some prioritization logic.  
Instead of writing custom sorting blocks or implementing the spaceship operator (`<=>`) in your class,
Priora offers a declarative style in order to obtain ready-for-consumption collections.

For example, let's assume we have a simple `Post` class, holding data regarding the author name,
how many likes did it receive and whether this post is sponsored:

```ruby
class Post
  attr_reader :author, :like_count, :is_sponsored

  def initialize(author:, like_count:, is_sponsored:)
    @author = author
    @like_count = like_count
    @is_sponsored = is_sponsored
  end
end
``` 

Then, in a given scenario, we have three instances at hand (these examples will be used throughout this README):

```ruby
low_like_count_sponsored = Post.new(author: 'Jay C.', like_count: 10, is_sponsored: true)
high_like_count_unsponsored = Post.new(author: 'Aaron R.', like_count: 90, is_sponsored: false)
high_like_count_sponsored = Post.new(author: 'Don Y.', like_count: 90, is_sponsored: true)
```

Using Priora, we can easily get the collection prioritized according to our needs:

```ruby
unprioritized_array = [high_like_count_unsponsored, low_like_count_sponsored, high_like_count_sponsored]
prioritized_array =  [high_like_count_sponsored, high_like_count_unsponsored, low_like_count_sponsored]
Priora.prioritize(unprioritized_array, by: [:like_count, :is_sponsored]) == prioritized_array
=> true
```

In case we can commit to the prioritization between `Post` objects - i.e. we do not need the flexibility of
changing the priorities each time - we can include the `Priora` module in our class and
declare the priorities using the `prioritize_by` class macro and gain shorter invocation.
Our class would then read like this:
 
```ruby
class Post
  include Priora
  prioritize_by :like_count, :is_sponsored

  attr_reader :author, :like_count, :is_sponsored

  def initialize(author:, like_count:, is_sponsored:)
    @author = author
    @like_count = like_count
    @is_sponsored = is_sponsored
  end
end
``` 

And getting the prioritized array would read like this:

```ruby
Priora.prioritize(unprioritized_array) == prioritized_array
=> true
```

Using the `prioritize_by` class macro increases the readability of your code for the cost of flexibility.
By adopting this usage, priorities are declared in-class and Priora can fetch it implicitly.
For some cases this might be the right choice while for others the explicit style is more suitable.

### Advantages Over Using Custom `sort` Or Implementing `<=>` 
One might come up with the following snippet as an equivalent solution:

```ruby
unprioritized_array.sort { |a, b| [a.like_count, a.is_sponsored ? 1 : 0 ] <=> [b.like_count, b.is_sponsored ? 1 : 0] }.reverse == prioritized_array
=> true
```

Which is, of course, correct. However, I find several issues with this code:
* It is more verbose and prone to errors.
* It declares the prioritization logic twice.
* It handles the conversion of a boolean value (`true` / `false`) into a sortable value (`1` / `0`) inline,
thus mixing levels of abstractions and confusing the potential reader.

Another possible alternative is implementing the spaceship operator (`<=>`) for `Post` instances,
and then simply employ reverse sorting.
I regard this approach as somewhat more elegant, but its main problem is that it assumes our sorting logic is always the same
for a given class, which is not always true.
Priora solves this problem by supporting the explicit `by` parameter.

I created Priora after having encountered a few scenarios in which I needed to get some collections prioritized in some
specific manner, and having to supply these explicit blocks again and again was quite annoying.
I figured out a modest library solving this problem could be nice to have.  

### Reverse Sorting, Extended: An Agenda

Priora is based on the presumption that when we talk about a prioritized collection,
we often refer to the outcome of sorting it and then reversing the result.
This is because we naturally think about sorting in an ascending fashion, from small to large,
while when we talk about "top priorities" we usually think of the largest items first.

#### Directional Priorities

Obviously, this is not always true and some prioritization processes should give precedence to smaller items first;
Priora supports this scenario as well.
You may change the prioritization direction for a specific priority:

```ruby
Priora.prioritize(unprioritized_array, by: [[like_count: :asc], :is_sponsored])
=> [low_like_count_sponsored, high_like_count_sponsored, high_like_count_unsponsored]
```

We can see that the `Post` with the low `like_count` comes up first,
however the two high `like_count` posts are prioritized by `is_sponsored`, so the sponsored `Post` comes up first.

If you have several priorities for which you wish to specify direction, you need to do so for each separately:
```ruby
Priora.prioritize(unprioritized_array, by: [[like_count: :asc], [is_sponsored: :asc]])
=> [low_like_count_sponsored, high_like_count_unsponsored, high_like_count_sponsored]
```

### Implicit Conversions

As you might have noted, Priora also takes care of converting non-sortable values,
such as `true`, `false` or `nil`, into sortable values.
By default, it assumes that `true` is larger than `false` and that `nil` evaluates to `0`.  

You may override these implicit conversions with your own lambdas,
as well as supply your own custom lambdas for other classes (and perhaps override their sorting logic!).

For example, if we wished to sort attributes of class `String` by their length,
we could configure `Priora` accordingly beforehand:

```ruby
Priora.configuration.add_conversion_lambda(String, lambda { |value| value.length })
```

Conversion lambdas are also removable, should that need arise:

```ruby
Priora.configuration.remove_conversion_lambda(String)
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'priora'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install priora

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/eliav-lavi/priora.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
