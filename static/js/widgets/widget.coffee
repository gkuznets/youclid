core = require "./core"
Rect = core.Rect

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
        @geometry_ = new Rect 100, 100, 100, 200
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

    setParent: (parent) ->
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
            @layout_?.setParent this
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

exports.BaseObject = BaseObject
exports.Widget = Widget
