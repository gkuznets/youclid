core = require "./core"
Rect = core.Rect
Size = core.Size
SizePolicy = core.SizePolicy

class BaseObject
    @nextId_ = 0
    constructor: ->
        @id_ = BaseObject.nextId_++

    id: -> @id_

    destroy: ->

    connect: (signal, slot, receiver) ->

    emit: (signal) ->


class Widget extends BaseObject
    @MAXIMUM_SIZE = 10000

    constructor: (@parent_) ->
        super()
        @children_ = []
        @color_ = "rgb(#{rand(256)},#{rand(256)},#{rand(256)})"
        @layout_ = null
        @sizeHint_ = new Size 400, 400
        @sizePolicy_ = new SizePolicy \
                            SizePolicy.PREFERRED,
                            SizePolicy.PREFERRED
        @visible_ = false

        @initDiv_()
        @setGeometry new Rect 0, 0, @sizeHint().width(), @sizeHint().height()

    initDiv_: ->
        @div_ = $("<div>test #{@id()}</div>")
            .css("position", "absolute")
            .css("background-color", @color_)
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

    setParent: (parent) ->
        if @parent_ != parent
            @parent_?.removeChild_ this
            @parent_ = parent
            @parent_?.addChild_ this
            @div_.appendTo @parentElement_()
        this

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
            @layout_?.setParent this
            @layout_?.setGeometry @rect()
        this

    sizeHint: -> clone @sizeHint_
    size: -> @geometry_.size()
    setMinimumSize: (@sizeHint_) ->
        if arguments.length == 2
            @sizeHint_ = new Size arguments[0], arguments[1]
        # TODO: check if min size is invalid
        minWidth = @sizeHint_.width()
        @sizePolicy_.setHorizontalPolicy \
            if minWidth == 0
                @sizePolicy_.horizontalPolicy() & ~SizePolicy.GROW_FLAG
            else
                SizePolicy.addMinimum @sizePolicy_.horizontalPolicy()
        if minWidth > @width()
            @setWidth minWidth

        minHeight = @sizeHint_.height()
        @sizePolicy_.setVerticalPolicy \
            if minWidth == 0
                @sizePolicy_.verticalPolicy() & ~SizePolicy.GROW_FLAG
            else
                SizePolicy.addMinimum @sizePolicy_.verticalPolicy()
        if minHeight > @height()
            @setHeight minHeight
        console.log "sms #{@sizeHint_}"
        this

    setMaximumSize: -> (@maxSize_) ->
    sizePolicy: -> clone @sizePolicy_

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
        this

    x: -> @pos().x()
    y: -> @pos().y()

    width: -> @geometry_.width()
    setWidth: (newWidth) ->
        @geometry_.setWidth newWidth
        @div_.width @width()
        @layout_?.setGeometry @rect()
        @render()
        this

    height: -> @geometry_.height()
    setHeight: (newHeight) ->
        @geometry_.setHeight newHeight
        @div_.height @height()
        @layout_?.setGeometry @rect()
        @render()
        this

    move: (dx, dy) ->
        @moveTo @pos().moved dx, dy

    moveTo: (pos) ->
        @geometry_ = @geometry_.withTopLeft pos
        @div_.css "left", @x()
        @div_.css "top", @y()
        @render()
        this

exports.BaseObject = BaseObject
exports.Widget = Widget
