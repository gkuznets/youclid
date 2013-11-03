class Vec
    constructor: (@x_, @y_) ->

    x: -> @x_
    y: -> @y_

    perp: ->
        new Vec -@y_, @x_

module.exports.Vec = Vec
