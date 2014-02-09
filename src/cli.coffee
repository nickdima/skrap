skrap    = require './skrap'
fs       = require "fs"
optimist = require "optimist"

argv = optimist
  .usage('Usage: $0 json_recipe_file param1=value param2=value ... [options]')
  .alias('d', 'destination').describe('d', 'destination json file').default('d', 'skrap.json')
  .alias('t', 'timeout').describe('t', 'number of miliseconds to wait between pages scraped').default('t', '1000')
  .argv

recipePath = argv._[0]

if not recipePath
  optimist.showHelp()
  process.exit(1)

data      = {}
functions = []
done      = 0
params    = {}

for pairs in argv._[1..]
  pairs = pairs.split "="
  params[pairs[0]] = pairs[1]

skrap recipePath, params, (_data, _functions) ->
  data = _data
  if _functions.length > 0
    functions = _functions
    execFunction(func, i) for func, i in functions
  else
    writeData()

writeData = ->
  data = JSON.stringify data, null, 4
  fs.writeFile argv.d, data, (err) ->
    if err
      console.log err
    else
      console.log "scraped data saved to #{argv.d}"

execFunction = (func, i) ->
  setTimeout ->
    func ->
      done++
      console.log "#{done} extra pages of #{functions.length} scraped"
      writeData() if done is functions.length
  , i*1000