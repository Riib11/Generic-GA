# Generic GA

A generic genetic algorithm implementation. Using Crystal.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  generic_ga:
    github: riib11/generic-ga
```

## Usage

```crystal
require "generic_ga"

world = GenericGA::World.new 10   # make a world with 100 agents
world.simulate 100                # simulate 100 selections, with console feedback
```


## Development

TODO

## Contributing

1. Fork it ( https://github.com/riib11/generic-ga/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [[riib11]](https://github.com/riib11) Henry - creator, maintainer
