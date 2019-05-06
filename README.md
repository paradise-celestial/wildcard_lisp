# WildcardLISP

An implementation of LISP for [Celestial](https://github.com/paradise-celestial).

## Installation

Add the dependency to your `shard.yml`:

```yaml
dependencies:
  wildcard_lisp:
    github: paradise-celestial/wildcard_lisp
```

Then, run `shards install`.

## Usage

```crystal
require "wildcard_lisp"

WildcardLISP.exec "(join (list 'hello' 'world'))" # => "Hello World"
```

## Development

No non-Crystal libraries are needed; simply run `shards install`.

## Contributing

1. Fork it (<https://github.com/paradise-celestial/wildcard_lisp/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [microlith57](https://github.com/microlith57) - creator and maintainer
- [neauoire](https://github.com/neauoire) - creator of original WildcardLISP implementation; inspiration for project
