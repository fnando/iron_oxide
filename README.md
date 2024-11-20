# iron_oxide

[![Tests](https://github.com/fnando/iron_oxide/workflows/ruby-tests/badge.svg)](https://github.com/fnando/iron_oxide)
[![Gem](https://img.shields.io/gem/v/iron_oxide.svg)](https://rubygems.org/gems/iron_oxide)
[![Gem](https://img.shields.io/gem/dt/iron_oxide.svg)](https://rubygems.org/gems/iron_oxide)
[![MIT License](https://img.shields.io/:License-MIT-blue.svg)](https://tldrlegal.com/license/mit-license)

An experiment that brings most of Rust's `Result` and `Option` patterns to Ruby.

## Installation

```bash
gem install iron_oxide
```

Or add the following line to your project's Gemfile:

```ruby
gem "iron_oxide"
```

## Usage

```ruby
require "iron_oxide"

include IronOxide::Aliases

Some(1).some?
None.some?
None.none?

Ok(1).ok?
Err("oh noes!").ok?
```

Most of `Result` and `Option` has been ported to Ruby. You can
[check tests](https://github.com/fnando/iron_oxide/tree/main/test/iron_oxide)
for examples.

## Maintainer

- [Nando Vieira](https://github.com/fnando)

## Contributors

- https://github.com/fnando/iron_oxide/contributors

## Contributing

For more details about how to contribute, please read
https://github.com/fnando/iron_oxide/blob/main/CONTRIBUTING.md.

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT). A copy of the license can be
found at https://github.com/fnando/iron_oxide/blob/main/LICENSE.md.

## Code of Conduct

Everyone interacting in the iron_oxide project's codebases, issue trackers, chat
rooms and mailing lists is expected to follow the
[code of conduct](https://github.com/fnando/iron_oxide/blob/main/CODE_OF_CONDUCT.md).
