skrap = require("../lib/skrap.js");

recipePath = __dirname + "/imdb.json";

skrap(recipePath, {movie: 'spider-man'}, function(data) {
  data.movies[0].getDetails(function(details) {
  	console.log(data);
  });
})
