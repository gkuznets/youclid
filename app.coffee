express = require "express"
app = express()

app.set "views", __dirname + "/templates"
app.use express.static __dirname + "/static"

app.get "/", (req, res) ->
    res.render "index.jade"

app.listen 3030
console.log "Listening on port 3030"
