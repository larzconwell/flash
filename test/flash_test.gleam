import flash
import gleam/option.{None, Some}
import gleeunit

pub fn main() {
  gleeunit.main()
}

pub fn default_test() {
  assert flash.default.level == flash.InfoLevel
  assert flash.default.writer == flash.text_writer
  assert flash.default.parent == None
  assert flash.default.group == ""
  assert flash.default.attrs == []
}

pub fn parse_level_test() {
  assert flash.parse_level("debug") == Ok(flash.DebugLevel)
  assert flash.parse_level("Debug") == Ok(flash.DebugLevel)
  assert flash.parse_level("DEBUG") == Ok(flash.DebugLevel)

  assert flash.parse_level("info") == Ok(flash.InfoLevel)
  assert flash.parse_level("Info") == Ok(flash.InfoLevel)
  assert flash.parse_level("INFO") == Ok(flash.InfoLevel)

  assert flash.parse_level("warn") == Ok(flash.WarnLevel)
  assert flash.parse_level("Warn") == Ok(flash.WarnLevel)
  assert flash.parse_level("WARN") == Ok(flash.WarnLevel)

  assert flash.parse_level("error") == Ok(flash.ErrorLevel)
  assert flash.parse_level("Error") == Ok(flash.ErrorLevel)
  assert flash.parse_level("ERROR") == Ok(flash.ErrorLevel)

  let assert Error(_) = flash.parse_level("foobar")
  let assert Error(_) = flash.parse_level("")
}

pub fn level_to_string_test() {
  assert flash.level_to_string(flash.DebugLevel) == "debug"
  assert flash.level_to_string(flash.InfoLevel) == "info"
  assert flash.level_to_string(flash.WarnLevel) == "warn"
  assert flash.level_to_string(flash.ErrorLevel) == "error"
}

pub fn new_test() {
  assert flash.new(flash.WarnLevel, flash.text_writer)
    == flash.Logger(flash.WarnLevel, flash.text_writer, None, "", [])
}

pub fn with_attr_test() {
  let logger =
    flash.default
    |> flash.with_attr(flash.StringAttr("string", "value"))
    |> flash.with_attr(flash.BoolAttr("bool", True))

  assert logger.attrs
    == [
      flash.StringAttr("string", "value"),
      flash.BoolAttr("bool", True),
    ]
}

pub fn with_attrs_test() {
  let logger =
    flash.default
    |> flash.with_attrs([
      flash.StringAttr("string", "value"),
      flash.BoolAttr("bool", True),
    ])

  assert logger.attrs
    == [
      flash.StringAttr("string", "value"),
      flash.BoolAttr("bool", True),
    ]
}

pub fn with_group_test() {
  assert flash.with_group(flash.default, "group")
    == flash.Logger(
      ..flash.default,
      parent: Some(flash.default),
      group: "group",
      attrs: [],
    )
}

pub fn enabled_test() {
  assert flash.enabled(flash.default, flash.DebugLevel) == False
  assert flash.enabled(flash.default, flash.InfoLevel) == True
  assert flash.enabled(flash.default, flash.WarnLevel) == True
  assert flash.enabled(flash.default, flash.ErrorLevel) == True
}

pub fn text_writer_test() {
  let _writer: flash.Writer = flash.text_writer
}

pub fn json_writer_test() {
  let _writer: flash.Writer = flash.json_writer
}
