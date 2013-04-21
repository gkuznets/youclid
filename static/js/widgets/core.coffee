class Point
    constructor: (@x_, @y_) ->

    x: -> @x_
    setX: (@x_) -> this

    y: -> @y_
    setY: (@y_) -> this

    move: (dx, dy) ->
        @x_ += dx
        @y_ += dy
        this

    moved: (dx, dy) ->
        new Point @x_ + dx, @y_ + dy

    toString: -> "(#{@x_},#{@y_})"


class Size
    # Constructor without parameters creates Size object with invalid
    # width and height, so isValid() returns true
    constructor: (@width_, @height_) ->
        if arguments.length == 0
            @width_ = @height_ = -1

    width: -> @width_
    setWidth: (@width_) -> this

    height: -> @height_
    setHeight: (@height_) -> this

    isValid: -> @height_ >= 0 and @width_ >= 0

    toString: -> "#{@width_}x#{@height_}"


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
    setTopLeft: (@topLeft_) -> this

    bottomRight: -> @bottomRight_
    setBottomRight: (@bottomRight_) -> this

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

    size: -> new Size @width(), @height()

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


class SizePolicy
    ## Policy flags
    @GROW_FLAG:   1
    @EXPAND_FLAG: 2
    @SHRINK_FLAG: 4
    @IGNORE_FLAG: 8
    ## Policies
    # The sizeHint() is the only acceptable alternative, so the widget can
    # never grow or shrink (e.g. the vertical direction of a push button)
    @FIXED:             0
    # The sizeHint() is minimal, and sufficient. The widget can be expanded,
    # but there is no advantage to it being larger. It cannot be smaller
    # than the size provided by sizeHint().
    @MINIMUM:           @GROW_FLAG
    # The sizeHint() is a maximum. The widget can be shrunk any amount without
    # detriment if other widgets need the space. It cannot be larger than
    # the size provided by sizeHint().
    @MAXIMUM:           @SHRINK_FLAG
    # The sizeHint() is best, but the widget can be shrunk and still be useful.
    # The widget can be expanded, but there is no advantage to it being larger
    # than sizeHint() (the default Widget policy).
    @PREFERRED:         @GROW_FLAG | @SHRINK_FLAG
    # The sizeHint() is a sensible size, but the widget can be shrunk and still
    # be useful. The widget can make use of extra space, so it should get as
    # much space as possible.
    @EXPANDING:         @GROW_FLAG | @SHRINK_FLAG | @EXPAND_FLAG
    # The sizeHint() is minimal, and sufficient. The widget can make use of extra
    # space, so it should get as much space as possible
    @MINIMUM_EXPANDING: @GROW_FLAG | @EXPAND_FLAG
    # The sizeHint() is ignored. The widget will get as much space as possible.
    @IGNORED:           @SHRINK_FLAG | @GROW_FLAG | @IGNORE_FLAG

    # Constructor without arguments creates QSizePolicy object with FIXED as its
    # horizontal and vertical policies.
    constructor: (@verticalPolicy_, @horizontalPolicy_) ->
        if arguments.length == 0
            @verticalPolicy_ = SizePolicy.FIXED
            @horizontalPolicy_ = SizePolicy.FIXED

    horizontalPolicy: -> @horizontalPolicy_
    setHorizontalPolicy: (@horizontalPolicy_) -> this

    verticalPolicy: -> @verticalPolicy_
    setVerticalPolicy: (@verticalPolicy_) -> this

    @addMinimum_: []
    @addMinimum_[@FIXED] =              @FIXED
    @addMinimum_[@MINIMUM] =            @MINIMUM
    @addMinimum_[@MAXIMUM] =            @MINIMUM
    @addMinimum_[@PREFERRED] =          @MINIMUM
    @addMinimum_[@EXPANDING] =          @MINIMUM_EXPANDING
    @addMinimum_[@MINIMUM_EXPANDING] =  @MINIMUM_EXPANDING
    @addMinimum_[@IGNORED] =            @MINIMUM_EXPANDING
    @addMinimum: (policy) -> SizePolicy.addMinimum_[policy]

exports.Point = Point
exports.Rect = Rect
exports.Size = Size
exports.SizePolicy = SizePolicy
