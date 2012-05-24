Parser = require './basic_parser'

class SearchQueryParser

  @TOKEN_TO_OPERATOR:
    less_than: '<'
    less_than_or_equals: '<='
    greater_than: '>'
    greater_than_or_equals: '>='
    equals: ''

  @OPERATOR_TO_TOKEN: {}

  for token, operator of @TOKEN_TO_OPERATOR
    @OPERATOR_TO_TOKEN[operator] = token

  @NOT_TOKEN:
    greater_than: 'less_than'
    less_than: 'greater_than'
    equals: 'not_equals'
    not_equals: 'equals'
    greater_than_or_equals: 'less_than_or_equals'
    less_than_or_equals: 'greater_than_or_equals'

  @tokenize: (input) ->
    tree = Parser.parse(input)

    results = []
    word = positiveMatch = key = operator = undefined

    if tree.children.length < 1
      throw new Error("Couldn't parse search query!")

    tree.traverse
      traversesTextNodes: false
      enteredNode: (node) =>
        if node.error
          throw new Error(node.message())
        return switch node.name
          when "Definition"
            positiveMatch = true
            key = 'default'
            operator = 'equals'
            true
          when "MatchMode"
            positiveMatch = node.innerText() == '+'
            true
          when "Integer"
            word = parseInt(node.innerText(), 10)
            false
          when "Float"
            word = parseFloat(node.innerText())
            false
          when "Date"
            word = new Date(node.innerText())
            false
          when "String"
            if node.children[0].name == 'BareWord'
              word = node.innerText()
            else
              # Lop off quotes from the quoted strings
              word = node.innerText().slice(1, -1)
              word = word.trim()
            false
          when "Operator"
            operator = @OPERATOR_TO_TOKEN[node.innerText()]
            false
          else
            true

      exitedNode: (node) =>
        switch node.name
          when "Pair"
            key = node.children[0].innerText()
          when "Definition"
            operator = @NOT_TOKEN[operator] if !positiveMatch
            results.push [key, operator, word]

    results

  @parse: (input) ->
    q = []
    attributes = {}
    for [key, opt, value] in @tokenize(input)
      if key is 'default'
        q.push value
      else
        (attributes[key] || = []).push([opt, value])
    {q, attributes}

  @sanitize: (query) ->
    params = @parse(query)
    filters = @attributesToFilters(params.attributes)
    results = {}
    results.q = params.q.join(' ') if params.q.length
    results.f = filters if filters.length
    results

  @attributesToFilters: (attributes) ->
    result = []
    for key, tuples of attributes
      for [operator, value] in tuples
        result.push "#{key}:#{@TOKEN_TO_OPERATOR[operator]}#{value}"
    result

module.exports = SearchQueryParser
