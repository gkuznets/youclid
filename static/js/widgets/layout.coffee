core = require "./core"
widget = require "./widget"
Point = core.Point
Rect = core.Rect

class Layout extends widget.BaseObject
    constructor: (@parent_) ->
        super()
        if @parent_
            @parent_.setLayout this

    setParent: (parent) ->
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

    addWidget: (widget, stretch = 0) ->
        # TODO: check if widget is already here
        @items_.push new BoxLayout.WidgetItem widget, stretch
        @updateItemGeometries_()

    addStretch: (stretch) ->
        @items_.push new BoxLayout.StretchItem stretch
        @updateItemGeometries_()

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
                @items_[i].setGeometry itemRects[i]

    updateItemsParent_: ->
        (item.setParent @parent_) for item in @items_

    @BoxLayoutItem: class
        stretch: ->
            _ABSTRACT()


    @StretchItem: class extends @BoxLayoutItem
        constructor: (@stretch_) ->
        stretch: -> @stretch_
        setGeometry: ->
        setParent: ->


    @SpacingItem: class extends @BoxLayoutItem


    @WidgetItem: class extends @BoxLayoutItem
        constructor: (@widget_, @stretch_) ->
        stretch: -> @stretch_

        setGeometry: (rect) ->
            @widget_.setGeometry rect

        setParent: (parent) ->
            @widget_.setParent parent


class VBoxLayout extends BoxLayout
    calculateItemRects_: ->
        result = []
        totalStretch = _.reduce @items_,
                                (sum, item) -> sum + item.stretch(),
                                0

        portions =
            if totalStretch > 0
                (item.stretch() / totalStretch for item in @items_)
            else
                (1.0 / @items_.length for i in @items_)

        left = @rect_.left()
        right = @rect_.right()
        y = @rect_.top()
        for portion in portions
            itemHeight = @rect_.height() * portion
            result.push new Rect new Point(left, y),
                                 new Point(right, y + itemHeight)
            y += itemHeight

        result

class HBoxLayout extends BoxLayout
    calculateItemRects_: ->

exports.VBoxLayout = VBoxLayout
exports.HBoxLayout = HBoxLayout
