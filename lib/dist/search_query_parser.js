window.SearchQueryParser = (function(){var module = {exports: {}}; var exports = module.exports; (function() {
  var Parser, SearchQueryParser;

  Parser = (function(){var module = {exports: {}}; var exports = module.exports; 
var compiledGrammar = {"table":[[0,"source",1],[0,"start",2],[3,3,4],[0,"EOF",5],[4,6,7,3],[4,8,9],[0,"Definitions",10],[6,11],[9,12],[5,""],[4,7,13,14],[2,"[\\s]"],[1],[0,"Definition",15],[6,16],[4,17,18],[4,19,13],[8,20],[3,21,22],[7,11],[0,"MatchMode",23],[0,"Pair",24],[0,"AnyWord",25],[3,26,27],[4,28,29,30,31],[0,"String",32],[5,"-"],[5,"+"],[0,"BareWord",33],[5,":"],[8,34],[0,"Attribute",35],[3,36,37,28],[4,38,39],[0,"Operator",40],[0,"AnyValue",41],[0,"DoubleQuotedString",42],[0,"SingleQuotedString",43],[2,"[^\\s'\"(:]"],[6,44],[3,45,46,47,48],[3,49,50,25],[4,51,52,51],[4,53,54,53],[2,"[^ \"):]"],[5,"<="],[5,">="],[5,"<"],[5,">"],[0,"Date",55],[0,"Numeric",56],[5,"\""],[6,57],[5,"'"],[6,58],[4,59,59,59,59,60,59,61,60,59,61],[3,62,63],[2,"[^\"]"],[2,"[^']"],[2,"[0-9]"],[5,"-"],[8,59],[0,"Float",64],[0,"Integer",65],[4,66,67,66],[4,66,68],[7,59],[5,"."],[10,69],[3,11,3],[0,"%start",71],[3,72,73],[0,"%EOF",5],[4,74,7,72],[0,"%Definitions",75],[4,7,76,77],[0,"%Definition",78],[6,79],[4,80,81],[4,19,76],[8,82],[3,83,84],[0,"%MatchMode",23],[0,"%Pair",85],[0,"%AnyWord",86],[4,87,29,88,89],[0,"%String",90],[0,"%BareWord",33],[8,91],[0,"%Attribute",92],[3,93,94,87],[0,"%Operator",40],[0,"%AnyValue",95],[0,"%DoubleQuotedString",42],[0,"%SingleQuotedString",43],[3,96,97,86],[0,"%Date",55],[0,"%Numeric",98],[3,99,100],[0,"%Float",64],[0,"%Integer",101],[4,66,102],[10,103],[3,11,72]],"nameToUID":{"start":1,"EOF":3,"Definitions":6,"Definition":13,"MatchMode":20,"Pair":21,"AnyWord":22,"String":25,"BareWord":28,"Attribute":31,"Operator":34,"AnyValue":35,"DoubleQuotedString":36,"SingleQuotedString":37,"Date":49,"Numeric":50,"Float":62,"Integer":63,"%start":70,"%EOF":72,"%Definitions":74,"%Definition":76,"%MatchMode":82,"%Pair":83,"%AnyWord":84,"%String":86,"%BareWord":87,"%Attribute":89,"%Operator":91,"%AnyValue":92,"%DoubleQuotedString":93,"%SingleQuotedString":94,"%Date":96,"%Numeric":97,"%Float":99,"%Integer":100}};


function Parser(/*String | CompiledGrammar*/ aGrammar)
{
    if (typeof aGrammar.valueOf() === "string")
        this.compiledGrammar = new (require("./compiledgrammar"))(aGrammar);
    else
        this.compiledGrammar = aGrammar;

    return this;
}

module.exports = Parser;

Parser.prototype.parse = function(input)
{
    return parse(this.compiledGrammar, input);
}

var NAME                = 0,
    DOT                 = 1,
    CHARACTER_CLASS     = 2,
    ORDERED_CHOICE      = 3,
    SEQUENCE            = 4,
    STRING_LITERAL      = 5,
    ZERO_OR_MORE        = 6,
    ONE_OR_MORE         = 7,
    OPTIONAL            = 8,
    NEGATIVE_LOOK_AHEAD = 9,
    POSITIVE_LOOK_AHEAD = 10,
    ERROR_NAME          = 11,
    ERROR_CHOICE        = 12;

function parse(aCompiledGrammar, input, name)
{
    var node = new SyntaxNode("#document", input, 0, 0),
        table = aCompiledGrammar.table,
        nameToUID = aCompiledGrammar.nameToUID;

    name = name || "start";

    // This is a stupid check.
    if (aCompiledGrammar.nameToUID["EOF"] !== undefined)
        table[0] = [SEQUENCE, nameToUID[name], nameToUID["EOF"]];

    if (!evaluate(new context(input, table), node, table, 0))
    {
        // This is a stupid check.
        if (aCompiledGrammar.nameToUID["EOF"] !== undefined)
            table[0] = [SEQUENCE, nameToUID["%" + name], nameToUID["EOF"]];

        node.children.length = 0;

        evaluate(new context(input, table), node, table, 0);

        node.traverse(
        {
            traverseTextNodes:false,
            enteredNode:function(node)
            {
                if (node.error)
                    console.log(node.message() + "\n");
            }
        });
    }

    return node;
}

exports.parse = parse;

function context(input, table)
{
    this.position = 0;
    this.input = input;
    this.memos = [];
    for (var i=0;i<table.length;++i)
        this.memos[i] = [];
}

function evaluate(context, parent, rules, rule_id)
{
    var rule = rules[rule_id],
        type = rule[0],
        input_length = context.input.length,
        memos = context.memos[rule_id];

    var uid = context.position,
        entry = memos[uid];

    if (entry === false)
        return false;
    else if (entry === true)
        return true;
    else if (entry)
    {
        if (parent)
            parent.children.push(entry.node);
        context.position = entry.position;
        return true;
    }

    switch (type)
    {
        case NAME:
        case ERROR_NAME:
            var node = new SyntaxNode(rule[1], context.input, context.position, 0, rule[3]);
            if (!evaluate(context, node, rules, rule[2]))
            {
                memos[uid] = false;
                return false;
            }
            node.range.length = context.position - node.range.location;
            memos[uid] = { node:node, position:context.position };

            if (parent)
                parent.children.push(node);
            return true;

        case CHARACTER_CLASS:
            var character = context.input.charAt(context.position);

            if (typeof rule[1].valueOf() === "string")
                rule[1] = new RegExp(rule[1], "g");

            if (character.match(rule[1]))
            {
                if (parent)
                    parent.children.push(character);
                ++context.position;
                return true;
            }
            memos[uid] = false;
            return false;

        case SEQUENCE:
            var index = 1,
                count = rule.length;

            for (; index < count; ++index)
                if (!evaluate(context, parent, rules, rule[index]))
                {
                    memos[uid] = false;
                    return false;
                }

            return true;

        case ORDERED_CHOICE:
        case ERROR_CHOICE:
            var index = 1,
                count = rule.length,
                position = context.position;

            for (; index < count; ++index)
            {
                // cache opportunity here.
                var child_count = parent && parent.children.length;

                if (evaluate(context, parent, rules, rule[index]))
                    return true;

                if (parent)
                    parent.children.length = child_count;
                context.position = position;
            }
            memos[uid] = false;
            return false;

        case STRING_LITERAL:
            var string = rule[1],
                string_length = string.length;

            if (string_length + context.position > input_length)
            {
                memos[uid] = false;
                return false;
            }

            var index = 0;

            for (; index < string_length; ++context.position, ++index)
                if (context.input.charCodeAt(context.position) !== string.charCodeAt(index))
                {
                    context.position -= index;
                    memos[uid] = false;
                    return false;
                }

//            memos[uid] = string;
            if (parent)
                parent.children.push(string);

            return true;
        case DOT:
            if (context.position < input_length)
            {
                if (parent)
                    parent.children.push(context.input.charAt(context.position));
                ++context.position;
                return true;
            }
            memos[uid] = false;
            return false;
        case POSITIVE_LOOK_AHEAD:
        case NEGATIVE_LOOK_AHEAD:
            var position = context.position,
                result = evaluate(context, null, rules, rule[1]) === (type === POSITIVE_LOOK_AHEAD);
            context.position = position;
            memos[uid] = result;

            return result;

        case ZERO_OR_MORE:
            var child,
                position = context.position,
                childCount = parent && parent.children.length;

            while (evaluate(context, parent, rules, rule[1]))
            {
                position = context.position,
                childCount = parent && parent.children.length;
            }

            context.position = position;
            if (parent)
                parent.children.length = childCount;

            return true;

        case ONE_OR_MORE:
            var position = context.position,
                childCount = parent && parent.children.length;
            if (!evaluate(context, parent, rules, rule[1]))
            {
                memos[uid] = false;
                context.position = position;
                if (parent)
                    parent.children.length = childCount;
                return false;
            }
            position = context.position,
            childCount = parent && parent.children.length;
            while (evaluate(context, parent, rules, rule[1]))
            {
                position = context.position;
                childCount = parent && parent.children.length;
            }
            context.position = position;
            if (parent)
                parent.children.length = childCount;
            return true;

        case OPTIONAL:
            var position = context.position,
                childCount = parent && parent.children.length;

            if (!evaluate(context, parent, rules, rule[1]))
            {
                context.position = position;

                if (parent)
                    parent.children.length = childCount;
            }

            return true;
    }
}

function SyntaxNode(/*String*/ aName, /*String*/ aSource, /*Number*/ aLocation, /*Number*/ aLength, /*String*/anErrorMessage)
{
    this.name = aName;
    this.source = aSource;
    this.range = { location:aLocation, length:aLength };
    this.children = [];

    if (anErrorMessage)
        this.error = anErrorMessage;
}

SyntaxNode.prototype.message = function()
{
    var source = this.source,
        lineNumber = 1,
        index = 0,
        start = 0,
        length = source.length,
        range = this.range;

    for (; index < range.location; ++index)
        if (source.charAt(index) === '\n')
        {
            ++lineNumber;
            start = index + 1;
        }

    for (; index < length; ++index)
        if (source.charAt(index) === '\n')
            break;

    var line = source.substring(start, index);
        message = line + "\n";

    message += (new Array(this.range.location - start + 1)).join(" ");
    message += (new Array(Math.min(range.length, line.length) + 1)).join("^") + "\n";
    message += "ERROR line " + lineNumber + ": " + this.error;

    return message;
}

SyntaxNode.prototype.toString = function(/*String*/ spaces)
{
    if (!spaces)
        spaces = "";

    var string = spaces + this.name +  " <" + this.innerText() + "> ",
        children = this.children,
        index = 0,
        count = children.length;

    for (; index < count; ++index)
    {
        var child = children[index];

        if (typeof child === "string")
            string += "\n" + spaces + "\t" + child;

        else
            string += "\n" + children[index].toString(spaces + '\t');
    }

    return string;
}

SyntaxNode.prototype.innerText = function()
{
    var range = this.range;

    return this.source.substr(range.location, range.length);
}

SyntaxNode.prototype.traverse = function(walker)
{
    if (!walker.enteredNode || walker.enteredNode(this) !== false)
    {
        var children = this.children,
            index = 0,
            count = children && children.length;

        for (; index < count; ++index)
        {
            var child = children[index];

            if (typeof child !== "string")
                child.traverse(walker);

            else if (walker.traversesTextNodes)
            {
                walker.enteredNode(child);

                if (walker.exitedNode)
                    walker.exitedNode(child);
            }
        }
    }

    if (walker.exitedNode)
        walker.exitedNode(this);
}


module.exports = new Parser(compiledGrammar);

; return module.exports;})();

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
; return module.exports;})();