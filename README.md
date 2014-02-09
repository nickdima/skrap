# skrap

**Skrap** is a command line utility and node.js module for easily scraping web pages by providing [json recipes](#create-a-recipe).

## Getting Started
Install the module with: `npm install skrap`

### Use it from the command line

    skrap recipe.json param1=value param2=value ... [options]

### Use it in node.js

```javascript
var skrap = require('skrap');
var recipePath = "./recipe.json";

skrap(recipePath, {param: 'value'}, function(data) {
  	console.log(data);
})
```

## Documentation

### Create a recipe
A recipe is just a JSON file that contains rules for scraping a web page. Here's a simple example:

```json
{
    "url" : "http://www.imdb.com/find?q=${movie}&s=tt&ttype=ft&ref_=fn_ft",
    "collections" : [{
        "name" : "movies",
        "query": "$('table.findList tr')",
        "fields": {
            "title" : "find('td.result_text a').text()",
            "year" : "find('td.result_text').text().match(/\\((\\d{4})\\)/)[1]",
            "poster" : "find('td.primary_photo img').attr('src')",
        }
    }]
}
```

The recipe makes use of CSS selectors for targeting the pieces of data that needs to be scraped. **Skrap** depends on the [`cheerio`](https://github.com/MatthewMueller/cheerio) node.js module for querying the DOM, which [selector's implementation](https://github.com/MatthewMueller/cheerio#selectors) is nearly identical to jQuery's, so the API is very similar.

#### Brakedown of a simple recipe file

* `url` - the url of the page that needs to pe scraped, can contain multiple placeholders in the form of `${param_name}` for paramters that can be passed from the command line or programtically in node.js
* `collections` - an array of objects that describe one or more collections (lists of data) to be parsed from the page
    - `name` - the collection's name for grouping the results in the output
    - `query` - the selector function that should return an array of objects from which to build the collection
    - `fields` - pairs of data field names and function calls to be applied on the queried objects for retriving the pieces of data needed

Running `skrap` with the above example and passing the parameter `movie=spider-man` will generate [this JSON file](https://gist.github.com/nickdima/8898038)

#### Page crawling and advanced options

Here's a more complex example:

```json
{
    "url" : "http://www.imdb.com/find?q=${movie}&s=tt&ttype=ft&ref_=fn_ft",
    "headers": {
        "Accept-Language": "en-US,en;q=0.8,it;q=0.6,ro;q=0.4"
    },
    "collections" : [{
        "name" : "movies",
        "query": "$('table.findList tr')",
        "fields": {
            "title" : "find('td.result_text a').text()",
            "year" : "find('td.result_text').text().match(/\\((\\d{4})\\)/)[1]",
            "poster" : "find('td.primary_photo img').attr('src')",
            "details": {
                "url" : "find('td.result_text a').attr('href').replace('/','http://www.imdb.com/')",
                "group": false,
                "fields": {
                    "rating": "$('#overview-top .star-box-giga-star').text().trim()",
                    "duration": "$('#overview-top time').text().trim()"             
                }
            }
        }
    }]
}
```

**Optional fields:**

* `headers` - key, value pairs of http headers to be passed when making the requests for the pages to be scraped

**Page crawling**

**Skrap** has basic support for one level deep page crawling. The way it works is by provinding an object with crawling instructions instead of just a selector for a field name.
* `url` - the url of the page that needs to be crawled, a function call simmilar to the ones for retriving the pieces of data
* `group` - a boolean value for specifing if the crawled data should be grouped under an object (using the parent field name) or attached to the main object. Defaults to `true`
* `fields` - pairs of data field names and selector functions for retriving the pieces of data needed

In cases when you need to crawl a page for just a single piece of data, there's also a simplified syntax:

```json
"rating": {
    "url" : "find('td.result_text a').attr('href').replace('/','http://www.imdb.com/')",
    "query": "$('#overview-top .star-box-giga-star').text().trim()"
}
```

## Examples
See the [/examples](https://github.com/nickdima/skrap/tree/master/examples) folder

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style.

## License
Copyright (c) 2014 Nick Dima  
Licensed under the MIT license.
