class Label
    constructor: ->
        @pos_

class Labeler
    constructor: ->
        labels_ = {}

    drawLabels: (points, ctx, render) ->
        for point in points
            p_ = render.fromReal point.x(), point.y()
            ctx.strokeText point.name, p_.x, p_.y
