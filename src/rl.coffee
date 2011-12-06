
class RgSearchQueryParser extends Parser
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
    results.q = params.q.join(' ') if params.q.length
    results.f = filters if filters.length

  @attributesToFilters: (attributes) ->
    result = []
    for key, tuples of attributes
      for operator, value of tuples
        result.push "#{key}:#{FILTER_OPTS[operator]}#{value}"
    result
