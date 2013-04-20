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
    constructor: (@topLeft_, @bottomRight_) ->

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

class BaseObject
    @nextId_ = 0
    constructor: ->
        @id_ = BaseObject.nextId_++

    id: -> @id_

    destroy: ->

    connect: (signal, slot, receiver) ->

    emit: (signal) ->


class Widget extends BaseObject
    constructor: (@parent_) ->
        super()
        @children_ = []
        @color_ = "rgb(#{rand(256)},#{rand(256)},#{rand(256)})"
        @geometry_ = new Rect(new Point(100, 100), new Point(200, 300))
        @layout_ = null
        @visible_ = false

        @initDiv_()

    initDiv_: ->
        @div_ = $("<div>test</div>")
            .css("position", "absolute")
            .css("background-color", @color_)
            .css("left", @x())
            .css("top", @y())
            .width(@width())
            .height(@height())
            .appendTo(@parentElement_())
            #.css("display", "none")

    addChild_: (widget) ->
        assert @children_.indexOf(widget) == -1,
            "Child already added"
        @children_.push widget

    removeChild_: (widget) ->
        assert children_.indexOf(widget) != -1,
            "Trying to remove nonexistent child"
        children_.splice indexOf(widget), 1

    setParent_: (parent) ->
        if @parent_ != parent
            @parent_?.removeChild_ this
            @parent_ = parent
            @parent_?.addChild_ this
            @div_.appendTo @parentElement_()

    parentElement_: ->
        if @parent_
            @parent_.div_
        else
            $ "body"

    render: ->

    show: ->
        @visible_ = true
        @div_.css "display", "block"
        @render()

    setLayout: (layout) ->
        if @layout_ != layout
            @layout_ = layout
            @layout_?.setParent_ this
            @layout_?.setGeometry @rect()

    pos: -> clone @geometry_.topLeft()

    rect: -> @geometry().movedTo 0, 0
    geometry: -> clone @geometry_
    setGeometry: (@geometry_) ->
        @div_.css "left", @x()
        @div_.css "top", @y()
        @div_.height @height()
        @div_.width @width()
        @layout_?.setGeometry @rect()
        @render()

    x: -> @pos().x()
    y: -> @pos().y()

    width: -> @geometry_.width()
    setWidth: (newWidth) ->
        @geometry_.setWidth newWidth
        @div_.width @width()
        @layout_?.setGeometry @rect()
        render()

    height: -> @geometry_.height()
    setHeight: (newHeight) ->
        @geometry_.setHeight newHeight
        @div_.height @height()
        @layout_?.setGeometry @rect()
        render()

    move: (dx, dy) ->
        @moveTo @pos().moved dx, dy

    moveTo: (pos) ->
        @geometry_ = @geometry_.withTopLeft pos
        @div_.css "left", @x()
        @div_.css "top", @y()
        @render()


class Layout extends BaseObject
    constructor: (@parent_) ->
        super()
        if @parent_
            @parent_.setLayout this

    setParent_: (parent) ->
        if @parent_ != parent
            @parent_ = parent
            @parent_?.setLayout this
            @updateItemsParent_()

    updateItemsParent_: ->
        _ABSTRACT()

    setGeometry: (@rect_) ->

class BoxLayout extends Layout
    constructor: (parent) ->
        super parent
        @items_ = []

    destroy: ->
        super()

    updateItemsParent_: ->
        (item[0].setParent_ @parent_) for item in @items_

    addWidget: (widget, stretch = 0) ->
        # TODO: check if widget is already here
        @items_.push [widget, stretch]
        @updateItemGeometries_()

class VBoxLayout extends BoxLayout
    constructor: (parent)->
        super parent

    setGeometry: (rect) ->
        super rect
        @updateItemGeometries_()

    updateItemGeometries_: ->
        if not @parent_
            return

        if @items_.length > 0
            itemRects = @calculateItemRects_()
            assert(@items_.length == itemRects.length)
            for i in [0..@items_.length - 1]
                console.log "#{i}:#{itemRects[i]}"
                @items_[i][0].setGeometry itemRects[i]

    calculateItemRects_: ->
        result = []
        totalStretch = _.reduce @items_,
                                (item, sum) -> sum + item[1],
                                0
        if totalStretch > 0
            # TODO: implement
        else
            itemHeight = @rect_.height() / @items_.length
            left = @rect_.left()
            right = @rect_.right()
            y = @rect_.top()
            for i in [0..@items_.length - 1]
                result.push new Rect new Point(left, y),
                                     new Point(right, y + itemHeight)
                y += itemHeight
        result
