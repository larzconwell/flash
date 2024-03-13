import gleam/io
import gleam/bool
import gleam/float
import gleam/int
import gleam/string
import gleam/string_builder
import gleam/list
import gleam/order
import gleam/json
import birl

/// Default logger that omits debug level logs and outputs a text format.
pub const default = Logger(InfoLevel, text_writer, [])

/// Function type for custom writer implementations.
pub type Writer =
  fn(Level, String, List(Attr)) -> Nil

/// Collection of typed attributes to add data to loggers.
pub type Attr {
  BoolAttr(key: String, value: Bool)
  FloatAttr(key: String, value: Float)
  GroupAttr(key: String, value: List(Attr))
  IntAttr(key: String, value: Int)
  StringAttr(key: String, value: String)
}

/// Available log levels, where debug is the lowest level and error is the highest level.
pub type Level {
  DebugLevel
  InfoLevel
  WarnLevel
  ErrorLevel
}

/// Parses a string representation of a level to the equivalent level variant.
pub fn parse_level(level: String) -> Result(Level, Nil) {
  case string.lowercase(level) {
    "debug" -> Ok(DebugLevel)
    "info" -> Ok(InfoLevel)
    "warn" -> Ok(WarnLevel)
    "error" -> Ok(ErrorLevel)
    _ -> Error(Nil)
  }
}

/// Converts a level variant to an equivalent string representation.
pub fn level_to_string(level: Level) -> String {
  case level {
    DebugLevel -> "debug"
    InfoLevel -> "info"
    WarnLevel -> "warn"
    ErrorLevel -> "error"
  }
}

pub opaque type Logger {
  Logger(level: Level, writer: Writer, attrs: List(Attr))
}

/// Creates a logger that logs for levels greater than or equal to
/// the given level and writes using the given writer.
pub fn new(level: Level, writer: Writer) -> Logger {
  Logger(level, writer, [])
}

/// Adds the given attribute to the logger.
pub fn with_attr(logger: Logger, attr: Attr) -> Logger {
  with_attrs(logger, [attr])
}

/// Adds the list of attributes to the logger.
pub fn with_attrs(logger: Logger, attrs: List(Attr)) -> Logger {
  Logger(..logger, attrs: list.append(logger.attrs, attrs))
}

/// Logs the message and any attributes if the logger is enabled to
/// log at the given log level.
pub fn log(logger: Logger, level: Level, message: String) -> Nil {
  case level_to_int(level) >= level_to_int(logger.level) {
    True -> logger.writer(level, message, logger.attrs)
    False -> Nil
  }
}

/// Logs the message and any attributes at the debug level.
pub fn debug(logger: Logger, message: String) -> Nil {
  log(logger, DebugLevel, message)
}

/// Logs the message and any attributes at the info level.
pub fn info(logger: Logger, message: String) -> Nil {
  log(logger, InfoLevel, message)
}

/// Logs the message and any attributes at the warn level.
pub fn warn(logger: Logger, message: String) -> Nil {
  log(logger, WarnLevel, message)
}

/// Logs the message and any attributes at the error level.
pub fn error(logger: Logger, message: String) -> Nil {
  log(logger, ErrorLevel, message)
}

/// A writer that writes to standard out using a JSON representation.
/// Here's some example code and the associated JSON output:
///
/// ```
/// let logger = with_attr(logger, StringAttr("request_id", "foobar"))
/// info(logger, "/health")
/// ```
///
/// ```
/// {"level":"info","time":"2024-03-09T12:52:43.657-05:00","message":"/health","request_id":"foobar"}
/// ```
///
/// The `level`, `time`, and `message` attributes are added automatically and will be
/// ordered before other attributes. Other attributes are sorted lexicographically with
/// groups being sorted after non group attributes. If multiple attributes in the same
/// group share a key, the last attribute with the key is chosen.
pub fn json_writer(level: Level, message: String, attrs: List(Attr)) -> Nil {
  let attrs =
    attrs
    |> prepare_attrs
    |> list.map(fn(attr) { #(attr.key, attr_to_json_value(attr)) })

  json.object([
    #("level", json.string(level_to_string(level))),
    #("time", json.string(birl.to_iso8601(birl.now()))),
    #("message", json.string(message)),
    ..attrs
  ])
  |> json.to_string
  |> io.println
}

/// A writer that writes to standard out using a text representation.
/// Here's some example code and the associated text output:
///
/// ```
/// let logger = with_attr(logger, StringAttr("request_id", "foobar"))
/// info(logger, "/health")
/// ```
///
/// ```
/// 12:59:37 INFO  /health                                       request_id=foobar
/// ```
///
/// Attributes are sorted lexicographically with groups being sorted after non
/// group attributes. If multiple attributes in the same group share a key, the
/// last attribute with the key is chosen.
pub fn text_writer(level: Level, message: String, attrs: List(Attr)) -> Nil {
  let now = birl.get_time_of_day(birl.now())
  let message = string.pad_right(message, 45, " ")
  let level =
    level_to_string(level)
    |> string.uppercase
    |> string.pad_right(to: 5, with: " ")

  let time_builder =
    string_builder.from_strings([
      string.pad_left(int.to_string(now.hour), 2, "0"),
      ":",
      string.pad_left(int.to_string(now.minute), 2, "0"),
      ":",
      string.pad_left(int.to_string(now.second), 2, "0"),
    ])

  let attrs =
    attrs
    |> prepare_attrs
    |> list.map(attr_to_text)

  string_builder.join(
    [
      time_builder,
      string_builder.from_string(level),
      string_builder.from_string(message),
      ..attrs
    ],
    " ",
  )
  |> string_builder.to_string
  |> io.println
}

fn level_to_int(level) {
  case level {
    DebugLevel -> 0
    InfoLevel -> 1
    WarnLevel -> 2
    ErrorLevel -> 3
  }
}

fn attr_compare(a: Attr, b: Attr) {
  let a_is_group = case a {
    GroupAttr(_, _) -> True
    _ -> False
  }
  let b_is_group = case b {
    GroupAttr(_, _) -> True
    _ -> False
  }

  case a_is_group, b_is_group {
    True, True -> string.compare(a.key, b.key)
    False, False -> string.compare(a.key, b.key)
    True, False -> order.Gt
    _, _ -> order.Lt
  }
}

fn prepare_attrs(attrs: List(Attr)) {
  attrs
  |> list.filter(fn(attr) {
    case attr {
      GroupAttr(_, value) -> value != []
      _ -> True
    }
  })
  |> list.reverse
  |> unique_by(fn(a, b) { a.key != b.key })
  |> list.sort(attr_compare)
  |> list.map(fn(attr) {
    case attr {
      GroupAttr(key, value) -> GroupAttr(key, prepare_attrs(value))
      _ -> attr
    }
  })
}

fn attr_to_json_value(attr) {
  case attr {
    BoolAttr(_, value) -> json.bool(value)
    FloatAttr(_, value) -> json.float(value)
    GroupAttr(_, value) ->
      value
      |> list.map(fn(attr) { #(attr.key, attr_to_json_value(attr)) })
      |> json.object
    IntAttr(_, value) -> json.int(value)
    StringAttr(_, value) -> json.string(value)
  }
}

fn attr_to_text(attr) {
  let from_strings = string_builder.from_strings

  case attr {
    BoolAttr(key, value) -> from_strings([key, "=", bool.to_string(value)])
    FloatAttr(key, value) -> from_strings([key, "=", float.to_string(value)])
    GroupAttr(key, value) ->
      value
      |> list.map(fn(attr) {
        let key = string.join([key, attr.key], ".")

        attr_to_text(case attr {
          BoolAttr(_, value) -> BoolAttr(key, value)
          FloatAttr(_, value) -> FloatAttr(key, value)
          GroupAttr(_, value) -> GroupAttr(key, value)
          IntAttr(_, value) -> IntAttr(key, value)
          StringAttr(_, value) -> StringAttr(key, value)
        })
      })
      |> string_builder.join(with: " ")
    IntAttr(key, value) -> from_strings([key, "=", int.to_string(value)])
    StringAttr(key, value) -> from_strings([key, "=", value])
  }
}

fn unique_by(list, predicate) {
  case list {
    [] -> []
    [x, ..rest] -> [
      x,
      ..unique_by(list.filter(rest, fn(y) { predicate(x, y) }), predicate)
    ]
  }
}
