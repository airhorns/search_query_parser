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

exports['identifier retreival'] = nodeunit.testCase
  "test name": (test) ->
    test.deepEqual [
      ['default', 'equals', "bruce"],
      ['default', 'equals',  'williams']
    ], SearchQueryParser.tokenize(NAME)
    test.done()

  "name and age": (test) ->
    test.deepEqual [
      ['default', 'equals', "bruce"],
      ['default', 'equals',  'williams'],
      ['age', 'equals',  16]
    ], SearchQueryParser.tokenize(NAME_AND_AGE)
    test.done()

  "name and age minimum value": (test) ->
    test.deepEqual [
      ['default', 'equals', "john"],
      ['age', 'less_than', 16]
    ], SearchQueryParser.tokenize(GROUPED_NAMES_AND_AGE_WITH_MIN)
    test.done()

  "name and age greater or equal value": (test) ->
    test.deepEqual [
      ['default', 'equals', "john"],
      ['age', 'greater_than_or_equals', 16]
    ], SearchQueryParser.tokenize(GROUPED_NAMES_AND_AGE_WITH_MAX_OR_EQUALS)
    test.done()

  "name and age minimum value and negative match": (test) ->
    test.deepEqual [
      ['default', 'equals', "john"],
      ['age', 'less_than', 16]
    ], SearchQueryParser.tokenize(GROUPED_NAMES_AND_AGE_WITH_NEG_MATCH_MIN)
    test.done()

  "name min age and city": (test) ->
    test.deepEqual [
      ['default', 'equals', "bruce"],
      ['age', 'greater_than', 16],
      ['city', 'equals', 'austin']
    ], SearchQueryParser.tokenize(NAME_MIN_AGE_AND_CITY)
    test.done()

  "grouped default keywords": (test) ->
    results = SearchQueryParser.tokenize(GROUPED_NAMES_AND_AGE)
    test.deepEqual [
      ['default', 'equals', "coda"],
      ['default', 'equals', "bruce"],
      ['default', 'equals', "hale"],
      ['default', 'equals', "williams"],
      ["age", 'equals', 16]
    ], results
    test.done()

  "unquoted keyword term": (test) ->
    results = SearchQueryParser.tokenize(NAME_AND_AGE)
    test.deepEqual [
      ['default', 'equals', "bruce"],
      ['default', 'equals', "williams"],
      ["age", 'equals', 16],
    ], results
    test.done()

  "single digit attribute": (test) ->
    results = SearchQueryParser.tokenize(SINGLE_DIGIT_ATTRIBUTE)
    test.deepEqual [
      ['default', 'equals', "john"],
      ["total_orders", 'greater_than', 5],
    ], results
    test.done()

  "multi single digit attribute": (test) ->
    results = SearchQueryParser.tokenize(NAME_AND_MONEY)
    test.deepEqual [
      ['default', 'equals', "john"],
      ["total_orders", 'greater_than', "$5"],
    ], results
    test.done()

  "quoted default keyword term": (test) ->
    results = SearchQueryParser.tokenize(NAME_QUOTED_AND_AGE)
    test.deepEqual [
      ['default', 'equals', "bruce williams"],
      ["age", 'equals', 16]
    ], results
    test.done()

  "qouted keyword term": (test) ->
    results = SearchQueryParser.tokenize(NAME_AND_QUOTED_AGE)
    test.deepEqual [
      ['default', 'equals', "bruce"],
      ['default', 'equals', "williams"],
      ["age", 'equals', 16]
    ], results
    test.done()

  "quoted keyword term with whitespace": (test) ->
    results = SearchQueryParser.tokenize(DEFAULT_AGE_WITH_QUOTED_AGE)
    test.deepEqual [
      ['default', 'equals', "16"],
      ["name", 'equals', "bruce williams"]
    ], results
    test.done()

  "single quoted keyword term with whitespace": (test) ->
    results = SearchQueryParser.tokenize(DEFAULT_AGE_WITH_SINGLE_QUOTED_AGE)
    test.deepEqual [
      ['default', 'equals', "16"],
      ["name", 'equals', "bruce williams"]
    ], results
    test.done()

  "nested single quote is accumulated": (test) ->
    results = SearchQueryParser.tokenize(NAME_WITH_NESTED_SINGLE_QUOTES)
    test.deepEqual [
      ['default', 'equals', "d'arcy d'uberville"],
      ["age", 'equals', 16]
    ], results
    test.done()

  "nested double quote is accumulated": (test) ->
    results = SearchQueryParser.tokenize("""'he was called "jake"'""")
    test.deepEqual [
      ['default', 'equals', 'he was called "jake"']
    ], results
    test.done()

  "bare single quote in unqouted literal is accumulated": (test) ->
    results = SearchQueryParser.tokenize("bruce's age:16")
    test.deepEqual [
      ['default', 'equals', "bruce's"],
      ["age", 'equals', 16]
    ], results
    test.done()

  "single quoted literal is accumuldated": (test) ->
    results = SearchQueryParser.tokenize("foo 'bruce williams' age:16")
    test.deepEqual [
      ['default', 'equals', "foo"],
      ['default', 'equals', "bruce williams"],
      ["age", 'equals', 16]
    ], results
    test.done()

  "period in literial is accumulated": (test) ->
    results = SearchQueryParser.tokenize("okay... age:16")
    test.deepEqual [
      ['default', 'equals', "okay..."],
      ["age", 'equals', 16]
    ], results
    test.done()

  "period floating point": (test) ->
    results = SearchQueryParser.tokenize("price:16.12")
    test.deepEqual [
      ["price", 'equals', 16.12]
    ], results
    test.done()

  "tokenize as string if integer starts with zero": (test) ->
    results = SearchQueryParser.tokenize("zipcode:01612")
    test.deepEqual [
      ["zipcode", 'equals', "01612"]
    ], results
    test.done()

  "date parsing": (test) ->
    results = SearchQueryParser.tokenize("order_placed:2007-01-01")
    test.deepEqual [
      ["order_placed", 'equals', new Date("2007-01-01")]
    ], results
    test.done()

  "tokenize error results in exception": (test) ->
    test.throws -> SearchQueryParser.tokenize("we_do_not_allow:! or ::")
    test.done()

  "can use apostrophes in unquoted literal": (test) ->
    results = SearchQueryParser.tokenize("d'correct")
    test.deepEqual [
      ['default', 'equals', "d'correct"]
    ], results
    test.done()

  "can use apostrophes in unquoted literal values": (test) ->
    results = SearchQueryParser.tokenize("text:d'correct")
    test.deepEqual [
      ['text', 'equals', "d'correct"]
    ], results
    test.done()

  "cannot use an apostrophe at the beginning on an unquoted literal": (test) ->
    test.throws -> SearchQueryParser.tokenize("'thisiswrong")
    test.done()

  "keywords are case sensitive": (test) ->
    results = SearchQueryParser.tokenize("Text:justtesting")
    test.deepEqual [
      ['Text', 'equals', "justtesting"]
    ], results
    test.done()

  "values are case sensitive": (test) ->
    results = SearchQueryParser.tokenize("Text:Big")
    test.deepEqual [
      ['Text', 'equals', "Big"]
    ], results
    test.done()

  "spaces are condensed": (test) ->
    results = SearchQueryParser.tokenize("  this  is  some  text  ")
    test.deepEqual [
      ['default', 'equals', "this"],
      ['default', 'equals', "is"],
      ['default', 'equals', "some"],
      ['default', 'equals', "text"]
    ], results
    test.done()

  "empty search is successful": (test) ->
    results = SearchQueryParser.tokenize("")
    test.deepEqual [], results
    test.done()

  "negative search": (test) ->
    results = SearchQueryParser.tokenize("-site:google.com")
    test.deepEqual [
      ["site", 'not_equals', "google.com"]
    ], results
    test.done()

  "positive search": (test) ->
    results = SearchQueryParser.tokenize("+site:google.com")
    test.deepEqual [
      ["site", 'equals', "google.com"]
    ], results
    test.done()

  "positive negative search": (test) ->
    results = SearchQueryParser.tokenize("""text -google.com search""")
    test.deepEqual [
      ['default', 'equals', "text"],
      ['default', 'not_equals', "google.com"],
      ['default', 'equals', "search"]
    ], results
    test.done()

  "negative search to the default keyword with quotes": (test) ->
    results = SearchQueryParser.tokenize("""-google.com""")
    test.deepEqual [
      ['default', 'not_equals', "google.com"]
    ], results
    test.done()

  "tokenize syntax error": (test) ->
    test.throws -> SearchQueryParser.tokenize("""age:(16)""")
    test.throws -> SearchQueryParser.tokenize("""age: test""")
    test.done()

  "parse": (test) ->
    results = SearchQueryParser.parse(GROUPED_NAMES_AND_AGE)
    expected =
      "age": [
        ['equals', 16]
      ]
    test.equal 2, Object.keys(results).length
    test.deepEqual ["coda","bruce","hale","williams"], results.q
    test.deepEqual expected, results.attributes
    test.done()

  "parse with range": (test) ->
    results = SearchQueryParser.parse(GROUPED_NAMES_AND_AGE_WITH_MIN_MAX)
    expected =
      "age": [
        ['greater_than', 16]
        ['less_than', 30]
      ]
    test.equal 2, Object.keys(results).length
    test.deepEqual ["john"], results.q
    test.deepEqual expected, results.attributes
    test.done()

  "parse with multiple attributes": (test) ->
    results = SearchQueryParser.parse(MULTIPLE_ATTRIBUTES)
    expected = {
      "total_orders": [
        ['greater_than', 100]
      ],
      "total_spent":  [
        ['less_than', 100.0],
        ['greater_than', 21.5]
      ]
    }

    test.equal 2, Object.keys(results).length
    test.deepEqual ["john", "smith"], results.q
    test.deepEqual expected, results.attributes
    test.done()

  "name and boolean false": (test) ->
    test.deepEqual [
      ['default', 'equals', "john"],
      ['agrees', 'equals',  0]
    ], SearchQueryParser.tokenize(NAME_AND_BOOLEAN_FALSE)
    test.done()

  "sanitize should return sane version of query": (test) ->
    expected = {q: 'bruce williams'}
    test.deepEqual expected, SearchQueryParser.sanitize(NAME)

    expected = {q: 'bruce williams', f: ['age:16']}
    test.deepEqual expected, SearchQueryParser.sanitize(NAME_AND_AGE)

    expected = {q: 'john', f: ['age:>16', 'age:<30']}
    test.deepEqual expected, SearchQueryParser.sanitize(GROUPED_NAMES_AND_AGE_WITH_MIN_MAX)
    test.done()

  "illegal character should be escaped": (test) ->
    escaped = 'john\@doe.com'
    expected = {q: [escaped], attributes: {}}
    test.deepEqual expected, SearchQueryParser.parse(ILLEGAL_CHARACTER)
    test.done()
