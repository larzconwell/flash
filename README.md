# shine

[![Package Version](https://img.shields.io/hexpm/v/shine)](https://hex.pm/packages/shine)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/shine/)
[![License](https://img.shields.io/badge/License-BSD_2--Clause_+_Patent-blue.svg)](https://github.com/larzconwell/shine/blob/main/LICENSE)
[![Test](https://github.com/larzconwell/shine/actions/workflows/test.yml/badge.svg)](https://github.com/larzconwell/shine/actions)

`shine` is a Gleam package enabling structured logging in both Erlang and JavaScript environments.

## Usage

```
gleam add shine
```

```gleam
import shine

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
