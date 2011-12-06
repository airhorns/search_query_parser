
/* line 1 "src/language/search_query.rl" */

/* line 110 "src/language/search_query.rl" */


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
    
/* line 33 "lib/basic_parser.js" */
const _parser_actions = [
	0, 1, 0, 1, 1, 1, 9, 1, 
	12, 2, 4, 2, 2, 4, 9, 2, 
	4, 13, 2, 8, 1, 2, 8, 12, 
	3, 1, 4, 13, 3, 4, 5, 9, 
	3, 4, 6, 9, 3, 4, 7, 9, 
	3, 10, 3, 1, 3, 10, 3, 12, 
	3, 11, 3, 1, 3, 11, 3, 12
];

const _parser_key_offsets = [
	0, 0, 8, 13, 23, 28, 29, 30, 
	32, 33, 34, 42, 49, 56, 64, 72, 
	81, 88, 96, 103, 110, 115, 121, 129, 
	137, 145, 153, 162, 170, 179, 187, 192, 
	197, 202, 207
];

const _parser_trans_keys = [
	0, 32, 34, 39, 40, 43, 45, 58, 
	0, 32, 34, 41, 58, 32, 34, 39, 
	40, 48, 58, 60, 62, 49, 57, 0, 
	32, 34, 41, 58, 34, 34, 0, 32, 
	39, 39, 0, 32, 34, 41, 46, 58, 
	48, 57, 0, 32, 34, 41, 58, 48, 
	57, 0, 32, 34, 41, 58, 48, 57, 
	0, 32, 34, 41, 46, 58, 48, 57, 
	0, 32, 34, 41, 46, 58, 48, 57, 
	0, 32, 34, 41, 45, 46, 58, 48, 
	57, 0, 32, 34, 41, 58, 48, 57, 
	0, 32, 34, 41, 45, 58, 48, 57, 
	0, 32, 34, 41, 58, 48, 57, 0, 
	32, 34, 41, 58, 48, 57, 0, 32, 
	34, 41, 58, 0, 32, 34, 41, 45, 
	58, 0, 32, 34, 41, 46, 58, 48, 
	57, 0, 32, 34, 41, 46, 58, 48, 
	57, 0, 32, 34, 41, 46, 58, 48, 
	57, 0, 32, 34, 41, 46, 58, 48, 
	57, 0, 32, 34, 41, 45, 46, 58, 
	48, 57, 0, 32, 34, 41, 46, 58, 
	48, 57, 32, 34, 39, 40, 48, 58, 
	61, 49, 57, 32, 34, 39, 40, 48, 
	58, 49, 57, 32, 34, 39, 40, 58, 
	32, 34, 39, 40, 58, 0, 32, 34, 
	41, 58, 0, 32, 34, 41, 58, 0
];

const _parser_single_lengths = [
	0, 8, 5, 8, 5, 1, 1, 2, 
	1, 1, 6, 5, 5, 6, 6, 7, 
	5, 6, 5, 5, 5, 6, 6, 6, 
	6, 6, 7, 6, 7, 6, 5, 5, 
	5, 5, 0
];

const _parser_range_lengths = [
	0, 0, 0, 1, 0, 0, 0, 0, 
	0, 0, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 0, 0, 1, 1, 
	1, 1, 1, 1, 1, 1, 0, 0, 
	0, 0, 0
];

const _parser_index_offsets = [
	0, 0, 9, 15, 25, 31, 33, 35, 
	38, 40, 42, 50, 57, 64, 72, 80, 
	89, 96, 104, 111, 118, 124, 131, 139, 
	147, 155, 163, 172, 180, 189, 197, 203, 
	209, 215, 221
];

const _parser_indicies = [
	1, 2, 3, 4, 5, 6, 7, 5, 
	0, 9, 10, 5, 5, 11, 8, 5, 
	13, 14, 5, 15, 5, 17, 17, 16, 
	12, 19, 10, 5, 5, 5, 18, 21, 
	20, 23, 22, 24, 25, 5, 21, 26, 
	23, 27, 28, 29, 5, 5, 30, 5, 
	31, 18, 19, 10, 5, 5, 5, 32, 
	18, 33, 34, 5, 5, 5, 32, 18, 
	19, 10, 5, 5, 30, 5, 35, 18, 
	19, 10, 5, 5, 30, 5, 36, 18, 
	19, 10, 5, 5, 37, 30, 5, 38, 
	18, 19, 10, 5, 5, 5, 39, 18, 
	19, 10, 5, 5, 40, 5, 41, 18, 
	19, 10, 5, 5, 5, 42, 18, 43, 
	44, 5, 5, 5, 45, 18, 43, 44, 
	5, 5, 5, 18, 19, 10, 5, 5, 
	40, 5, 18, 19, 10, 5, 5, 30, 
	5, 38, 18, 28, 29, 5, 5, 30, 
	5, 46, 18, 28, 29, 5, 5, 30, 
	5, 47, 18, 28, 29, 5, 5, 30, 
	5, 48, 18, 28, 29, 5, 5, 37, 
	30, 5, 49, 18, 28, 29, 5, 5, 
	30, 5, 49, 18, 5, 51, 52, 5, 
	53, 5, 55, 54, 50, 5, 51, 52, 
	5, 53, 5, 54, 50, 5, 3, 4, 
	5, 5, 0, 5, 57, 58, 5, 5, 
	56, 9, 10, 5, 5, 11, 8, 19, 
	10, 5, 5, 5, 18, 5, 0
];

const _parser_trans_targs = [
	2, 32, 1, 5, 8, 0, 30, 31, 
	2, 32, 1, 3, 4, 5, 8, 10, 
	23, 28, 4, 33, 6, 7, 6, 7, 
	34, 1, 9, 9, 33, 1, 11, 13, 
	12, 33, 1, 14, 15, 16, 22, 17, 
	18, 21, 19, 33, 1, 20, 24, 25, 
	26, 27, 4, 5, 8, 10, 23, 29, 
	2, 5, 8
];

const _parser_trans_actions = [
	48, 48, 0, 52, 52, 1, 0, 0, 
	0, 12, 12, 9, 3, 7, 7, 3, 
	3, 3, 0, 12, 3, 24, 0, 15, 
	5, 5, 3, 0, 28, 28, 0, 0, 
	0, 32, 32, 0, 0, 0, 0, 0, 
	0, 0, 0, 36, 36, 0, 0, 0, 
	0, 0, 18, 21, 21, 18, 18, 0, 
	40, 44, 44
];

const _parser_eof_actions = [
	0, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	0, 0, 0
];

const parser_start = 1;
const parser_first_final = 32;
const parser_error = 0;

const parser_en_main = 1;


/* line 137 "src/language/search_query.rl" */

    var eof, word, key, positive_match, negative_match, tokstart, opt;
    var quotes = 0;
    var p = 0;
    var pe = data.length;
    var results = [];
    eof = 0;

    
/* line 183 "lib/basic_parser.js" */
{
	 cs = parser_start;
} /* JSCodeGen::writeInit */

/* line 146 "src/language/search_query.rl" */
    
/* line 190 "lib/basic_parser.js" */
{
	var _klen, _trans, _keys, _ps, _widec, _acts, _nacts;
	var _goto_level, _resume, _eof_trans, _again, _test_eof;
	var _out;
	_klen = _trans = _keys = _acts = _nacts = null;
	_goto_level = 0;
	_resume = 10;
	_eof_trans = 15;
	_again = 20;
	_test_eof = 30;
	_out = 40;
	while (true) {
	_trigger_goto = false;
	if (_goto_level <= 0) {
	if (p == pe) {
		_goto_level = _test_eof;
		continue;
	}
	if (cs == 0) {
		_goto_level = _out;
		continue;
	}
	}
	if (_goto_level <= _resume) {
	_keys = _parser_key_offsets[cs];
	_trans = _parser_index_offsets[cs];
	_klen = _parser_single_lengths[cs];
	_break_match = false;
	
	do {
	  if (_klen > 0) {
	     _lower = _keys;
	     _upper = _keys + _klen - 1;

	     while (true) {
	        if (_upper < _lower) { break; }
	        _mid = _lower + ( (_upper - _lower) >> 1 );

	        if (data[p] < _parser_trans_keys[_mid]) {
	           _upper = _mid - 1;
	        } else if (data[p] > _parser_trans_keys[_mid]) {
	           _lower = _mid + 1;
	        } else {
	           _trans += (_mid - _keys);
	           _break_match = true;
	           break;
	        };
	     } /* while */
	     if (_break_match) { break; }
	     _keys += _klen;
	     _trans += _klen;
	  }
	  _klen = _parser_range_lengths[cs];
	  if (_klen > 0) {
	     _lower = _keys;
	     _upper = _keys + (_klen << 1) - 2;
	     while (true) {
	        if (_upper < _lower) { break; }
	        _mid = _lower + (((_upper-_lower) >> 1) & ~1);
	        if (data[p] < _parser_trans_keys[_mid]) {
	          _upper = _mid - 2;
	         } else if (data[p] > _parser_trans_keys[_mid+1]) {
	          _lower = _mid + 2;
	        } else {
	          _trans += ((_mid - _keys) >> 1);
	          _break_match = true;
	          break;
	        }
	     } /* while */
	     if (_break_match) { break; }
	     _trans += _klen
	  }
	} while (false);
	_trans = _parser_indicies[_trans];
	cs = _parser_trans_targs[_trans];
	if (_parser_trans_actions[_trans] != 0) {
		_acts = _parser_trans_actions[_trans];
		_nacts = _parser_actions[_acts];
		_acts += 1;
		while (_nacts > 0) {
			_nacts -= 1;
			_acts += 1;
			switch (_parser_actions[_acts - 1]) {
case 0:
/* line 4 "src/language/search_query.rl" */

    throw new ParseError("At offset " + p + ", near: '" + data.slice(p,10).join('') + "'")
  		break;
case 1:
/* line 8 "src/language/search_query.rl" */

    debugger;
    tokstart = p;
  		break;
case 2:
/* line 13 "src/language/search_query.rl" */

    debugger
    key = word;
  		break;
case 3:
/* line 18 "src/language/search_query.rl" */

    debugger
    key = 'default';
    opt = 'equals';
  		break;
case 4:
/* line 24 "src/language/search_query.rl" */

    debugger
    word = data.slice(tokstart, p-1).join('')
  		break;
case 5:
/* line 29 "src/language/search_query.rl" */

    debugger
    word = parseInt(data.slice(tokstart, p-1).join(''))
  		break;
case 6:
/* line 34 "src/language/search_query.rl" */

    debugger
    word = parseFloat(data.slice(tokstart,p-1).join(''))
  		break;
case 7:
/* line 39 "src/language/search_query.rl" */

    debugger
    word = new Date(data.slice(tokstart, p-1).join(''))
  		break;
case 8:
/* line 44 "src/language/search_query.rl" */

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
  		break;
case 9:
/* line 61 "src/language/search_query.rl" */

    operand = (positive_match ? opt : NOT[opt]);
    if (!operand) throw new ParseError("Unknown operand " + opt);
    debugger;
    results.push([ key, operand , word ]);
    word = undefined;
  		break;
case 10:
/* line 69 "src/language/search_query.rl" */

    positive_match = false;
  		break;
case 11:
/* line 73 "src/language/search_query.rl" */

    positive_match = true;
  		break;
case 12:
/* line 77 "src/language/search_query.rl" */
 quotes += 1; 		break;
case 13:
/* line 79 "src/language/search_query.rl" */
 quotes -= 1; 		break;
/* line 365 "lib/basic_parser.js" */
			} /* action switch */
		}
	}
	if (_trigger_goto) {
		continue;
	}
	}
	if (_goto_level <= _again) {
	if (cs == 0) {
		_goto_level = _out;
		continue;
	}
	p += 1;
	if (p != pe) {
		_goto_level = _resume;
		continue;
	}
	}
	if (_goto_level <= _test_eof) {
	if (p == eof) {
	__acts = _parser_eof_actions[cs];
	__nacts =  _parser_actions[__acts];
	__acts += 1;
	while (__nacts > 0) {
		__nacts -= 1;
		__acts += 1;
		switch (_parser_actions[__acts - 1]) {
case 0:
/* line 4 "src/language/search_query.rl" */

    throw new ParseError("At offset " + p + ", near: '" + data.slice(p,10).join('') + "'")
  		break;
/* line 398 "lib/basic_parser.js" */
		} /* eof action switch */
	}
	if (_trigger_goto) {
		continue;
	}
}
	}
	if (_goto_level <= _out) {
		break;
	}
	}
	}

/* line 147 "src/language/search_query.rl" */

    if (quotes === 0) {
      throw new ParseError("Unclosed quotes!");
    }

    return results;
  };

  /* node.js export */
  module.exports = Parser;
})();
