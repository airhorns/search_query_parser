(function() {
  var Parser, SearchQueryParser;

  Parser = require('./basic_parser');

  SearchQueryParser = (function() {
    var operator, token, _ref;

    function SearchQueryParser() {}

    SearchQueryParser.TOKEN_TO_OPERATOR = {
      less_than: '<',
      less_than_or_equals: '<=',
      greater_than: '>',
      greater_than_or_equals: '>=',
      equals: ''
    };

    SearchQueryParser.OPERATOR_TO_TOKEN = {};

    _ref = SearchQueryParser.TOKEN_TO_OPERATOR;
    for (token in _ref) {
      operator = _ref[token];
      SearchQueryParser.OPERATOR_TO_TOKEN[operator] = token;
    }

    SearchQueryParser.NOT_TOKEN = {
      greater_than: 'less_than',
      less_than: 'greater_than',
      equals: 'not_equals',
      not_equals: 'equals',
      greater_than_or_equals: 'less_than_or_equals',
      less_than_or_equals: 'greater_than_or_equals'
    };

    SearchQueryParser.tokenize = function(input) {
      var key, positiveMatch, results, tree, word,
        _this = this;
      tree = Parser.parse(input);
      results = [];
      word = positiveMatch = key = operator = void 0;
      if (tree.children.length < 1) {
        throw new Error("Couldn't parse search query!");
      }
      tree.traverse({
        traversesTextNodes: false,
        enteredNode: function(node) {
          if (node.error) {
            throw new Error(node.message());
          }
          switch (node.name) {
            case "Definition":
              positiveMatch = true;
              key = 'default';
              operator = 'equals';
              return true;
            case "MatchMode":
              positiveMatch = node.innerText() === '+';
              return true;
            case "Integer":
              word = parseInt(node.innerText(), 10);
              return false;
            case "Float":
              word = parseFloat(node.innerText());
              return false;
            case "Date":
              word = new Date(node.innerText());
              return false;
            case "String":
              if (node.children[0].name === 'BareWord') {
                word = node.innerText();
              } else {
                word = node.innerText().slice(1, -1);
                word = word.trim();
              }
              return false;
            case "Operator":
              operator = _this.OPERATOR_TO_TOKEN[node.innerText()];
              return false;
            default:
              return true;
          }
        },
        exitedNode: function(node) {
          switch (node.name) {
            case "Pair":
              return key = node.children[0].innerText();
            case "Definition":
              if (!positiveMatch) {
                operator = _this.NOT_TOKEN[operator];
              }
              return results.push([key, operator, word]);
          }
        }
      });
      return results;
    };

    SearchQueryParser.parse = function(input) {
      var attributes, key, opt, q, value, _i, _len, _ref1, _ref2;
      q = [];
      attributes = {};
      _ref1 = this.tokenize(input);
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        _ref2 = _ref1[_i], key = _ref2[0], opt = _ref2[1], value = _ref2[2];
        if (key === 'default') {
          q.push(value);
        } else {
          (attributes[key] || (attributes[key] = [])).push([opt, value]);
        }
      }
      return {
        q: q,
        attributes: attributes
      };
    };

    SearchQueryParser.sanitize = function(query) {
      var filters, params, results;
      params = this.parse(query);
      filters = this.attributesToFilters(params.attributes);
      results = {};
      if (params.q.length) {
        results.q = params.q.join(' ');
      }
      if (filters.length) {
        results.f = filters;
      }
      return results;
    };

    SearchQueryParser.attributesToFilters = function(attributes) {
      var key, result, tuples, value, _i, _len, _ref1;
      result = [];
      for (key in attributes) {
        tuples = attributes[key];
        for (_i = 0, _len = tuples.length; _i < _len; _i++) {
          _ref1 = tuples[_i], operator = _ref1[0], value = _ref1[1];
          result.push("" + key + ":" + this.TOKEN_TO_OPERATOR[operator] + value);
        }
      }
      return result;
    };

    return SearchQueryParser;

  })();

  module.exports = SearchQueryParser;

}).call(this);
