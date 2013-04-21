core = require "./core"
widget = require "./widget"
Point = core.Point
Rect = core.Rect
SizePolicy = core.SizePolicy

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
        console.log "#{widget.sizeHint()}"
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

        sizePolicy: ->
            _ABSTRACT()


    @StretchItem: class extends @BoxLayoutItem
        @sizePolicy_: new SizePolicy SizePolicy.EXPANDING, SizePolicy.EXPANDING
        constructor: (@stretch_) ->
        stretch: -> @stretch_
        sizePolicy: -> clone BoxLayout.StretchItem.sizePolicy_
        sizeHint: ->
        setGeometry: ->
        setParent: ->


    @SpacingItem: class extends @BoxLayoutItem
        @sizePolicy_: new SizePolicy SizePolicy.FIXED, SizePolicy.FIXED
        constructor: (@value_) ->
        stretch: -> 0
        sizePolicy: -> clone BoxLayout.SpacingItem.sizePolicy_
        sizeHint: -> new Size @value_, @value_
        setGeometry: ->
        setParent: ->


    @WidgetItem: class extends @BoxLayoutItem
        constructor: (@widget_, @stretch_) ->
        stretch: -> @stretch_
        sizePolicy: -> @widget_.sizePolicy()
        sizeHint: -> @widget_.sizeHint()

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

        leftHeight = @rect_.height()
        # checking min sizes
        needMoreIterations = true
        while needMoreIterations
            console.log "#{portions}"
            [totalStretch, leftHeight, needMoreIterations] =
                @checkMinHeights_ portions, totalStretch, leftHeight
            if needMoreIterations and totalStretch > 0
                for i in [0..@items_.length - 1]
                    if portions[i]
                        portions[i] = @items_[i].stretch() / totalStretch

        left = @rect_.left()
        right = @rect_.right()
        y = @rect_.top()
        for i in [0..@items_.length - 1]
            portion = portions[i]
            itemHeight = \
                if portion
                    leftHeight * portion
                else
                    @items_[i].sizeHint().height()
            result.push new Rect new Point(left, y),
                                 new Point(right, y + itemHeight)
            y += itemHeight

        result

    checkMinHeights_: (portions, totalStretch, leftHeight) ->
        heightToExtract = 0
        needMoreIterations = false
        for i in [0..@items_.length - 1]
            if portions[i] is undefined
                continue

            item = @items_[i]
            if item.sizePolicy().verticalPolicy() in [SizePolicy.FIXED,
                                                      SizePolicy.MINIMUM,
                                                      SizePolicy.MINIMUM_EXPANDING]
                if portions[i] * leftHeight < item.sizeHint().height()
                    heightToExtract += item.sizeHint().height()
                    totalStretch -= item.stretch()
                    portions[i] = undefined
                    needMoreIterations = true
        [totalStretch, Math.max(0, leftHeight - heightToExtract), needMoreIterations]


class HBoxLayout extends BoxLayout
    calculateItemRects_: ->

exports.VBoxLayout = VBoxLayout
exports.HBoxLayout = HBoxLayout
