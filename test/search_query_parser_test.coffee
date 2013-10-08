nodeunit = require 'nodeunit'
SearchQueryParser = require '../lib/search_query_parser'

NAME                                     = 'bruce williams'
NAME_AND_AGE                             = 'bruce williams age:16'
NAME_QUOTED_AND_AGE                      = '"bruce williams" age:16'
NAME_AND_QUOTED_AGE                      = 'bruce williams age:16'
DEFAULT_AGE_WITH_QUOTED_AGE              = '16 name:"bruce williams"'
DEFAULT_AGE_WITH_SINGLE_QUOTED_AGE       = "16 name:'bruce williams'"
NAME_WITH_NESTED_SINGLE_QUOTES           = '''"d'arcy d'uberville" age:16'''
NAME_MIN_AGE_AND_CITY                    = "bruce age:>16 city:austin"
GROUPED_NAMES_AND_AGE                    = """coda bruce 'hale' "williams" age:16"""
GROUPED_NAMES_AND_AGE_WITH_MIN           = 'john age:<16'
GROUPED_NAMES_AND_AGE_WITH_MIN_MAX       = 'john age:>16 age:<30'
GROUPED_NAMES_AND_AGE_WITH_MAX_OR_EQUALS = 'john age:>=16'
GROUPED_NAMES_AND_AGE_WITH_NEG_MATCH_MIN = 'john -age:>16'
MULTIPLE_ATTRIBUTES                      = 'john smith total_orders:>100 total_spent:<100.00 total_spent:>21.50'
SINGLE_DIGIT_ATTRIBUTE                   = 'john total_orders:>5'
NAME_AND_BOOLEAN_FALSE                   = 'john agrees:0'
NAME_AND_MONEY                           = 'john total_orders:>$5'
ILLEGAL_CHARACTER                        = 'john@doe.com'
MIXED_FLOAT_STRING                       = 'something:10.01_broken'

exports['identifier retreival'] = nodeunit.testCase
  "test name": (test) ->
    tokens = [
      ['default', 'equals', "bruce"],
      ['default', 'equals',  'williams']
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize(NAME)
    test.equal NAME, SearchQueryParser.build(tokens)
    test.done()

  "name and age": (test) ->
    tokens = [
      ['default', 'equals', "bruce"],
      ['default', 'equals',  'williams'],
      ['age', 'equals',  16]
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize(NAME_AND_AGE)
    test.equal NAME_AND_AGE, SearchQueryParser.build(tokens)
    test.done()

  "name and age minimum value": (test) ->
    tokens = [
      ['default', 'equals', "john"],
      ['age', 'less_than', 16]
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize(GROUPED_NAMES_AND_AGE_WITH_MIN)
    test.equal GROUPED_NAMES_AND_AGE_WITH_MIN, SearchQueryParser.build(tokens)
    test.done()

  "name and age greater or equal value": (test) ->
    tokens = [
      ['default', 'equals', "john"],
      ['age', 'greater_than_or_equals', 16]
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize(GROUPED_NAMES_AND_AGE_WITH_MAX_OR_EQUALS)
    test.equal GROUPED_NAMES_AND_AGE_WITH_MAX_OR_EQUALS, SearchQueryParser.build(tokens)
    test.done()

  "name and age minimum value and negative match": (test) ->
    tokens = [
      ['default', 'equals', "john"],
      ['age', 'less_than', 16]
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize(GROUPED_NAMES_AND_AGE_WITH_NEG_MATCH_MIN)
    test.equal GROUPED_NAMES_AND_AGE_WITH_MIN, SearchQueryParser.build(tokens)
    test.done()

  "name min age and city": (test) ->
    tokens = [
      ['default', 'equals', "bruce"],
      ['age', 'greater_than', 16],
      ['city', 'equals', 'austin']
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize(NAME_MIN_AGE_AND_CITY)
    test.equal NAME_MIN_AGE_AND_CITY, SearchQueryParser.build(tokens)
    test.done()

  "grouped default keywords": (test) ->
    tokens = [
      ['default', 'equals', "coda"],
      ['default', 'equals', "bruce"],
      ['default', 'equals', "hale"],
      ['default', 'equals', "williams"],
      ["age", 'equals', 16]
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize(GROUPED_NAMES_AND_AGE)
    test.equal "coda bruce hale williams age:16", SearchQueryParser.build(tokens)
    test.done()

  "unquoted keyword term": (test) ->
    tokens = [
      ['default', 'equals', "bruce"],
      ['default', 'equals', "williams"],
      ["age", 'equals', 16],
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize(NAME_AND_AGE)
    test.equal NAME_AND_AGE, SearchQueryParser.build(tokens)
    test.done()

  "single digit attribute": (test) ->
    tokens = [
      ['default', 'equals', "john"],
      ["total_orders", 'greater_than', 5],
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize(SINGLE_DIGIT_ATTRIBUTE)
    test.equal SINGLE_DIGIT_ATTRIBUTE, SearchQueryParser.build(tokens)
    test.done()

  "multi single digit attribute": (test) ->
    tokens = [
      ['default', 'equals', "john"],
      ["total_orders", 'greater_than', "$5"],
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize(NAME_AND_MONEY)
    test.equal NAME_AND_MONEY, SearchQueryParser.build(tokens)
    test.done()

  "quoted default keyword term": (test) ->
    tokens = [
      ['default', 'equals', "bruce williams"],
      ["age", 'equals', 16]
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize(NAME_QUOTED_AND_AGE)
    test.equal NAME_QUOTED_AND_AGE, SearchQueryParser.build(tokens)
    test.done()

  "qouted keyword term": (test) ->
    tokens = [
      ['default', 'equals', "bruce"],
      ['default', 'equals', "williams"],
      ["age", 'equals', 16]
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize(NAME_AND_QUOTED_AGE)
    test.equal NAME_AND_QUOTED_AGE, SearchQueryParser.build(tokens)
    test.done()

  "quoted keyword term with whitespace": (test) ->
    tokens = [
      ['default', 'equals', "16"],
      ["name", 'equals', "bruce williams"]
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize(DEFAULT_AGE_WITH_QUOTED_AGE)
    test.equal DEFAULT_AGE_WITH_QUOTED_AGE, SearchQueryParser.build(tokens)
    test.done()

  "single quoted keyword term with whitespace": (test) ->
    tokens = [
      ['default', 'equals', "16"],
      ["name", 'equals', "bruce williams"]
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize(DEFAULT_AGE_WITH_SINGLE_QUOTED_AGE)
    test.equal '16 name:"bruce williams"', SearchQueryParser.build(tokens)
    test.done()

  "nested single quote is accumulated": (test) ->
    tokens = [
      ['default', 'equals', "d'arcy d'uberville"],
      ["age", 'equals', 16]
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize(NAME_WITH_NESTED_SINGLE_QUOTES)
    test.equal NAME_WITH_NESTED_SINGLE_QUOTES, SearchQueryParser.build(tokens)
    test.done()

  "nested double quote is accumulated": (test) ->
    tokens = [
      ['default', 'equals', 'he was called "jake"']
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize("""'he was called "jake"'""")
    test.equal '"he was called \"jake\""', SearchQueryParser.build(tokens)
    test.done()

  "bare single quote in unqouted literal is accumulated": (test) ->
    tokens = [
      ['default', 'equals', "bruce's"],
      ["age", 'equals', 16]
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize("bruce's age:16")
    test.equal "bruce's age:16", SearchQueryParser.build(tokens)
    test.done()

  "single quoted literal is accumulated": (test) ->
    tokens = [
      ['default', 'equals', "foo"],
      ['default', 'equals', "bruce williams"],
      ["age", 'equals', 16]
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize("foo 'bruce williams' age:16")
    test.equal 'foo "bruce williams" age:16', SearchQueryParser.build(tokens)
    test.done()

  "period in literial is accumulated": (test) ->
    tokens = [
      ['default', 'equals', "okay..."],
      ["age", 'equals', 16]
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize("okay... age:16")
    test.equal "okay... age:16", SearchQueryParser.build(tokens)
    test.done()

  "period floating point": (test) ->
    tokens = [
      ["price", 'equals', 16.12]
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize("price:16.12")
    test.equal "price:16.12", SearchQueryParser.build(tokens)
    test.done()

  "tokenize as string if integer starts with zero": (test) ->
    tokens = [
      ["zipcode", 'equals', "01612"]
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize("zipcode:01612")
    test.equal "zipcode:01612", SearchQueryParser.build(tokens)
    test.done()

  "date parsing": (test) ->
    tokens = [
      ["order_placed", 'equals', new Date("2007-01-01")]
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize("order_placed:2007-01-01")
    test.equal "order_placed:2007-01-01", SearchQueryParser.build(tokens)
    test.done()

  "tokenize error results in exception": (test) ->
    test.throws -> SearchQueryParser.tokenize("we_do_not_allow:! or ::")
    test.done()

  "can use apostrophes in unquoted literal": (test) ->
    tokens = [
      ['default', 'equals', "d'correct"]
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize("d'correct")
    test.equal "d'correct", SearchQueryParser.build(tokens)
    test.done()

  "can use apostrophes in unquoted literal values": (test) ->
    tokens = [
      ['text', 'equals', "d'correct"]
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize("text:d'correct")
    test.equal "text:d'correct", SearchQueryParser.build(tokens)
    test.done()

  "cannot use an apostrophe at the beginning on an unquoted literal": (test) ->
    test.throws -> SearchQueryParser.tokenize("'thisiswrong")
    test.done()

  "keywords are case sensitive": (test) ->
    tokens = [
      ['Text', 'equals', "justtesting"]
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize("Text:justtesting")
    test.equal "Text:justtesting", SearchQueryParser.build(tokens)
    test.done()

  "values are case sensitive": (test) ->
    tokens = [
      ['Text', 'equals', "Big"]
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize("Text:Big")
    test.equal "Text:Big", SearchQueryParser.build(tokens)
    test.done()

  "spaces are condensed": (test) ->
    tokens = [
      ['default', 'equals', "this"],
      ['default', 'equals', "is"],
      ['default', 'equals', "some"],
      ['default', 'equals', "text"]
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize("  this  is  some  text  ")
    test.equal "this is some text", SearchQueryParser.build(tokens)
    test.done()

  "empty search is successful": (test) ->
    tokens = []
    test.deepEqual tokens, SearchQueryParser.tokenize("")
    test.equal "", SearchQueryParser.build(tokens)
    test.done()

  "negative search": (test) ->
    tokens = [
      ["site", 'not_equals', "google.com"]
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize("-site:google.com")
    test.equal "-site:google.com", SearchQueryParser.build(tokens)
    test.done()

  "positive search": (test) ->
    tokens = [
      ["site", 'equals', "google.com"]
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize("+site:google.com")
    test.equal "site:google.com", SearchQueryParser.build(tokens)
    test.done()

  "positive negative search": (test) ->
    tokens = [
      ['default', 'equals', "text"],
      ['default', 'not_equals', "google.com"],
      ['default', 'equals', "search"]
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize("""text -google.com search""")
    test.equal """text -google.com search""", SearchQueryParser.build(tokens)
    test.done()

  "negative search to the default keyword with quotes": (test) ->
    tokens = [
      ['default', 'not_equals', "google.com"]
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize("""-google.com""")
    test.equal """-google.com""", SearchQueryParser.build(tokens)
    test.done()

  "tokenize syntax error": (test) ->
    test.throws -> SearchQueryParser.tokenize("""age:(16)""")
    test.throws -> SearchQueryParser.tokenize("""age: test""")
    test.done()

  "name and boolean false": (test) ->
    tokens = [
      ['default', 'equals', "john"],
      ['agrees', 'equals',  0]
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize(NAME_AND_BOOLEAN_FALSE)
    test.equal NAME_AND_BOOLEAN_FALSE, SearchQueryParser.build(tokens)
    test.done()

  "tokenize handles floats mixed with strings": (test) ->
    tokens = [
      ['something', 'equals', '10.01_broken']
    ]
    test.deepEqual tokens, SearchQueryParser.tokenize(MIXED_FLOAT_STRING)
    test.equal MIXED_FLOAT_STRING, SearchQueryParser.build(tokens)
    test.done()
