class LineLineIntersection
    constructor: (@line0_, @line1_) ->
        @line0_.addChild this
        @line1_.addChild this

    addToPlot: (plot) ->
        @point_ = new Point(new LineLineIntersection.PointImpl this)
        plot.add @point_


LineLineIntersection.PointImpl = class
    constructor: (@parent_) ->

    x: ->
        a0 = @parent_.line0_.a()
        b0 = @parent_.line0_.b()
        c0 = @parent_.line0_.c()
        a1 = @parent_.line1_.a()
        b1 = @parent_.line1_.b()
        c1 = @parent_.line1_.c()

        d = a0 * b1 - a1 * b0
        if (d != 0)
            - (c0 * b1 - c1 * b0) / d
 
    y: ->
        a0 = @parent_.line0_.a()
        b0 = @parent_.line0_.b()
        c0 = @parent_.line0_.c()
        a1 = @parent_.line1_.a()
        b1 = @parent_.line1_.b()
        c1 = @parent_.line1_.c()

        d = a0 * b1 - a1 * b0
        if (d != 0)
            (c0 * a1 - c1 * a0) / d
 
    setX: ->
        throw "trying to call setX() of dependent point"
    
    xetY: ->
        throw "trying to call setY() of dependent point"

    independent: -> false

class Intersection
    constructor: (curve0, curve1) ->
        if curve0 instanceof Line and curve1 instanceof Line
            @impl_ = new LineLineIntersection curve0, curve1

    addToPlot: (plot) ->
        @impl_.addToPlot plot
