request = require 'superagent'
cheerio = require 'cheerio'
fs      = require 'fs'

headers  = {}
$        = null
crawlers = []

module.exports = skrap = (recipePath, params, callback) ->
  recipe = readRecipe(recipePath)
  url = recipe.url
  if recipe.headers?
    headers[header] = value for header, value of recipe.headers

  if params?
    for key, value of params
      pattern = new RegExp "\\$\\{#{key}\\}", 'g'
      url = url.replace pattern, encodeURIComponent(value)

  request.get(url).set(headers).end (error, res) ->
    return callback(error) if error
    $ = cheerio.load(res.text)
    scrap = {}
    for collection in recipe.collections
      scrap[collection.name] = scrapeCollection(collection)
    callback scrap, crawlers


readRecipe = (recipePath) ->
  data = fs.readFileSync recipePath, "utf8"
  data = JSON.parse(data)


scrapeCollection = (collection) ->
  for node in eval(collection.query)
    scrapeFields(collection, node)


scrapeFields = (collection, node) ->
  obj = {}
  for field, query of collection.fields
    try
      switch typeof query
        when 'string'
          obj[field] = eval "$(node).#{query}"
        when 'object'
          setCrawler(node, obj, field, query) if query.url?
  obj


setCrawler = (node, obj, field, query) ->
  getField = (callback) ->
    url = eval "$(node).#{query.url}"
    request.get(url).set(headers).end (error, res) ->
      _$ = cheerio.load(res.text)
      if query.fields?
        _obj = {}
        for _field, _query of query.fields
          _obj[_field] = eval _query.replace('$','_$')
        if query.group? and not query.group
          obj[key] = value for key, value of _obj
        else
          obj[field] = _obj
        callback _obj
      else
        obj[field] = eval query.query.replace('$','_$')
        callback obj[field]
  obj["get" + field.charAt(0).toUpperCase() + field.slice(1)] = getField
  crawlers.push getField