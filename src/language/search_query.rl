%%{
  machine parser;

  action error {
    throw new ParseError("At offset " + p + ", near: '" + data.slice(p,10).join('') + "'")
  }

  action start {
    debugger;
    tokstart = p;
  }

  action key {
    debugger
    key = word;
  }

  action setup {
    debugger
    key = 'default';
    opt = 'equals';
  }

  action word {
    debugger
    word = data.slice(tokstart, p-1).join('')
  }

  action num {
    debugger
    word = parseInt(data.slice(tokstart, p-1).join(''))
  }

  action float {
    debugger
    word = parseFloat(data.slice(tokstart,p-1).join(''))
  }

  action date {
    debugger
    word = new Date(data.slice(tokstart, p-1).join(''))
  }

  action opt {
    switch (data.slice(tokstart, p-1).join('')) {
      case '<':
        opt = 'less_than';
        break;
      case '>':
        opt = 'greater_than';
        break;
      case '>=':
        opt = 'greater_than_or_equals'
        break;
      case '<=':
        opt = 'less_than_or_equals'
        break;
    }
  }

  action value {
    operand = (positive_match ? opt : NOT[opt]);
    if (!operand) throw new ParseError("Unknown operand " + opt);
    debugger;
    results.push([ key, operand , word ]);
    word = undefined;
  }

  action negative_match {
    positive_match = false;
  }

  action positive_match {
    positive_match = true;
  }

  action quote { quotes += 1; }

  action unquote { quotes -= 1; }

  seperators = ' '+ | / *[,|] */ ;
  match_mode = ('-' % negative_match | '+'? % positive_match ) ;

  bareword = ( [^ '"(:] . [^ "):]* ) > start % word ; # allow apostrophes
  integer  = ('0' | [1-9]digit*) > start % num;
  date     = (digit{4} "-" digit{1,2} "-" digit{1,2}) > start % date;
  float    = (digit+ '\.' digit+) > start % float;
  dquoted  = '"' @ quote ( [^"]* > start % word ) :>> '"' @ unquote;
  squoted  = '\'' @ quote ( [^']* > start % word ) :>> '\'' @ unquote;
  operator = ( '<' | '>' | '<=' | '>=') > start % opt;

  string  = dquoted | squoted | bareword;
  numeric = integer | float;

  anyword  = (string) % value;
  anyvalue = (string | numeric | date) % value;

  #multivalues   = anyvalue ( seperators anyvalue )* ;
  #groupedvalues = '(' @ quote multivalues :>> ')' @ unquote;

  attribute = anyvalue;

  pair = bareword % key ':' operator? <: attribute ;

  definition = match_mode? <: ( pair | anyword ) > setup $!error;

  definitions = definition ( ' '+ definition )*;

  main := ' '* definitions? ' '* 0 $!error;
}%%

/* Javascript SearchQueryParser */
(function() {
  function ParseError(message) {
      this.name = "ParseError";
      this.message = (message || "");
  }

  ParseError.prototype = Error.prototype;

  var NOT = {
    'greater_than': 'less_than',
    'less_than': 'greater_than',
    'equals': 'not_equals',
    'not_equals': 'equals',
    'greater_than_or_equals': 'less_than_or_equals',
    'less_than_or_equals': 'greater_than_or_equals'
  };

  function Parser() {};

  Parser.tokenize = function(input) {
    var data = (input + " ").split('');

    /* Ragel Data */
    %% write data;

    var eof, word, key, positive_match, negative_match, tokstart, opt;
    var quotes = 0;
    var p = 0;
    var pe = data.length;
    var results = [];
    eof = 0;

    %% write init;
    %% write exec;

    if (quotes === 0) {
      throw new ParseError("Unclosed quotes!");
    }

    return results;
  };

  /* node.js export */
  module.exports = Parser;
})();
