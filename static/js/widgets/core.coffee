class Point
    constructor: (@x_, @y_) ->

    x: -> @x_
    setX: (x) ->
        @x_ = x
        this

    y: -> @y_
    setY: (y) ->
        @y_ = y
        this

    move: (dx, dy) ->
        @x_ += dx
        @y_ += dy
        this

    moved: (dx, dy) ->
        new Point @x_ + dx, @y_ + dy

    toString: -> "(#{@x_},#{@y_})"

class Rect
    # Rect constructor
    #
    # Constructor accepts two Point parameters (topLeft, bottomRight)
    # or four number parameters (top, left, width, height)
    constructor: ->
        if arguments.length == 2
            @topLeft_ = arguments[0]
            @bottomRight_ = arguments[1]
        else if arguments.length == 4
            [top, left, dx, dy] = arguments
            @topLeft_ = new Point left, top
            @bottomRight_ = new Point left + dx, top + dy
        else
            throw "Rect constructor expects 2 or 4 parameters,
                #{arguments.length} were given"

    topLeft: -> @topLeft_
    setTopLeft: (newTopLeft) ->
        @topLeft_ = newTopLeft
        this

    bottomRight: -> @bottomRight_
    setBottomRight: (newBottomRight) ->
        @bottomRight_ = newBottomRight
        this

    left: -> @topLeft_.x()
    right: -> @bottomRight_.x()
    top: -> @topLeft_.y()
    bottom: -> @bottomRight_.y()

    width: -> @bottomRight_.x() - @topLeft_.x()
    setWidth: (newWidth) ->
        dx = @width() - newWidth
        @bottomRight_.setX @bottomRight_.x() + dx
        this

    height: -> @bottomRight_.y() - @topLeft_.y()
    setHeight: (newHeight) ->
        dy = @height() - newHeight
        @bottomRight_.setY @bottomRight_.y() + dy
        this

    move: (dx, dy) ->
        @topLeft_.move dx, dy
        @bottomRight_.move dx, dy
        this

    moved: (dx, dy) ->
        clone(this).move dx, dy

    moveTo: (x, y) ->
        @bottomRight_.move x - @topLeft_.x(), y - @topLeft_.y()
        @topLeft_.setX(x).setY(y)
        this

    movedTo: (x, y) ->
        clone(this).moveTo x, y

    toString: -> "{#{@topLeft_}-#{@bottomRight_}}"

exports.Point = Point
exports.Rect = Rect

