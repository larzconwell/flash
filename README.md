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

With the default text writer output:
```gleam
import flash.{InfoLevel, GroupAttr, StringAttr}

pub fn main() {
  flash.new(InfoLevel, flash.text_writer)
  |> flash.with_attr(
    GroupAttr("request", [
      StringAttr("method", "POST"),
      StringAttr("path", "/user/create"),
      StringAttr("id", "foobar"),
    ]),
  )
  |> flash.info("request")
}
```

```
21:24:12 INFO  request                                       request.id=foobar request.method=POST request.path=/user/create
```

With the default json writer output:
```gleam
import flash.{InfoLevel, GroupAttr, StringAttr}

pub fn main() {
  flash.new(InfoLevel, flash.json_writer)
  |> flash.with_attr(
    GroupAttr("request", [
      StringAttr("method", "POST"),
      StringAttr("path", "/user/create"),
      StringAttr("id", "foobar"),
    ]),
  )
  |> flash.info("request")
}
```

```
{"level":"info","time":"2024-03-12T21:25:03.022-04:00","message":"request","request":{"id":"foobar","method":"POST","path":"/user/create"}}
```

## Developing

```shell
ln -s $(pwd)/.hooks/pre-commit .git/hooks/pre-commit
gleam format
gleam build
gleam test
```
