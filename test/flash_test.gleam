import gleam/option.{None, Some}
import gleeunit
import gleeunit/should
import flash

pub fn main() {
  gleeunit.main()
}

pub fn default_test() {
  flash.default.level
  |> should.equal(flash.InfoLevel)

  flash.default.writer
  |> should.equal(flash.text_writer)

  flash.default.parent
  |> should.equal(None)

  flash.default.group
  |> should.equal("")

  flash.default.attrs
  |> should.equal([])
}

pub fn parse_level_test() {
  flash.parse_level("debug")
  |> should.equal(Ok(flash.DebugLevel))
  flash.parse_level("Debug")
  |> should.equal(Ok(flash.DebugLevel))
  flash.parse_level("DEBUG")
  |> should.equal(Ok(flash.DebugLevel))

  flash.parse_level("info")
  |> should.equal(Ok(flash.InfoLevel))
  flash.parse_level("Info")
  |> should.equal(Ok(flash.InfoLevel))
  flash.parse_level("INFO")
  |> should.equal(Ok(flash.InfoLevel))

  flash.parse_level("warn")
  |> should.equal(Ok(flash.WarnLevel))
  flash.parse_level("Warn")
  |> should.equal(Ok(flash.WarnLevel))
  flash.parse_level("WARN")
  |> should.equal(Ok(flash.WarnLevel))

  flash.parse_level("error")
  |> should.equal(Ok(flash.ErrorLevel))
  flash.parse_level("Error")
  |> should.equal(Ok(flash.ErrorLevel))
  flash.parse_level("ERROR")
  |> should.equal(Ok(flash.ErrorLevel))

  flash.parse_level("foobar")
  |> should.be_error()
  flash.parse_level("")
  |> should.be_error()
}

pub fn level_to_string_test() {
  flash.level_to_string(flash.DebugLevel)
  |> should.equal("debug")

  flash.level_to_string(flash.InfoLevel)
  |> should.equal("info")

  flash.level_to_string(flash.WarnLevel)
  |> should.equal("warn")

  flash.level_to_string(flash.ErrorLevel)
  |> should.equal("error")
}

pub fn new_test() {
  flash.new(flash.WarnLevel, flash.text_writer)
  |> should.equal(
    flash.Logger(flash.WarnLevel, flash.text_writer, None, "", []),
  )
}

pub fn with_attr_test() {
  let logger =
    flash.default
    |> flash.with_attr(flash.StringAttr("string", "value"))
    |> flash.with_attr(flash.BoolAttr("bool", True))

  logger.attrs
  |> should.equal([
    flash.StringAttr("string", "value"),
    flash.BoolAttr("bool", True),
  ])
}

pub fn with_attrs_test() {
  let logger =
    flash.default
    |> flash.with_attrs([
      flash.StringAttr("string", "value"),
      flash.BoolAttr("bool", True),
    ])

  logger.attrs
  |> should.equal([
    flash.StringAttr("string", "value"),
    flash.BoolAttr("bool", True),
  ])
}

pub fn with_group_test() {
  flash.with_group(flash.default, "group")
  |> should.equal(
    flash.Logger(
      ..flash.default,
      parent: Some(flash.default),
      group: "group",
      attrs: [],
    ),
  )
}

pub fn enabled_test() {
  flash.enabled(flash.default, flash.DebugLevel)
  |> should.be_false()

  flash.enabled(flash.default, flash.InfoLevel)
  |> should.be_true()

  flash.enabled(flash.default, flash.WarnLevel)
  |> should.be_true()

  flash.enabled(flash.default, flash.ErrorLevel)
  |> should.be_true()
}

pub fn text_writer_test() {
  flash.text_writer
  |> fn(_writer: flash.Writer) { True }
  |> should.be_true()
}

pub fn json_writer_test() {
  flash.json_writer
  |> fn(_writer: flash.Writer) { True }
  |> should.be_true()
}
