# flash

[![Package Version](https://img.shields.io/hexpm/v/flash)](https://hex.pm/packages/flash)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/flash/)
[![License](https://img.shields.io/badge/License-BSD_2--Clause_+_Patent-blue.svg)](https://github.com/larzconwell/flash/blob/main/LICENSE)
[![Test](https://github.com/larzconwell/flash/actions/workflows/test.yml/badge.svg)](https://github.com/larzconwell/flash/actions)

`flash` is a Gleam package enabling structured logging in both Erlang and JavaScript environments.

## Usage

```
gleam add flash
```

```gleam
import flash

pub fn main() {
}
```

## Developing

```shell
ln -s $(pwd)/.hooks/pre-commit .git/hooks/pre-commit
gleam format
gleam build
gleam test
```
