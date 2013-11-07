Circle = (require "../core/circle").Circle
Line = (require "../core/line").Line
MouseEventsHandler = (require './mouse_events_handler').MouseEventsHandler
Point = (require "../core/point").Point
Segment = (require '../core/segment').Segment
ViewPort = (require './view_port').ViewPort

# styles
DEFAULT_POINT_SIZE = 2

hypot = (dx, dy) ->
    Math.sqrt dx * dx + dy * dy

class Element
    constructor: (@object_, @view_, @size_ = 1, @color_ = 'black') ->
        @changed_ = new signals.Signal()

    object: -> @object_

    size: -> @size_
    setSize: (newSize) ->
        if newSize != @size_
            @size_ = newSize
            @changed_.dispatch()

    color: -> @color_
    setColor: (newColor) ->
        if newColor != @color_
            @color_ = newColor
            @changed_.dispatch()

    changed: -> @changed_

    # distance form element to pixel (x, y)
    distance: (x, y) ->

    hover: (@onHoverIn_, @onHoverOut_) ->
    hoverIn_: ->
        @size_ = 2
        @changed_.dispatch()
        @onHoverIn_?()

    hoverOut_: ->
        @size_ = 1
        @changed_.dispatch()
        @onHoverOut_?()

    draggable: -> @object_.independent()
    moveTo: (x, y) ->
        @object_.setX(@view_.revMapX x).setY @view_.revMapY y
        @changed_.dispatch()

class CircleElement extends Element
    constructor: (circle, view) ->
        super circle, view
        @update()

    update: ->
        @x_ = @view_.mapX @object_.center().x()
        @y_ = @view_.mapY @object_.center().y()
        @radius_ = @view_.mapDist @object_.radius()

    distance: (x, y) ->
        dx = @x_ - x
        dy = @y_ - y
        Math.abs(@radius_ - hypot dx, dy)

    stroke: (ctx) ->
        ctx.lineWidth = @size_
        ctx.strokeStyle = @color_
        ctx.beginPath()
        ctx.arc @x_, @y_, @radius_, 0, Math.PI*2, true
        ctx.closePath()
        ctx.stroke()

class PointElement extends Element
    constructor: (point, view) ->
        super point, view
        @update()

    update: ->
        @x_ = @view_.mapX @object_.x()
        @y_ = @view_.mapY @object_.y()

    distance: (x, y) ->
        dx = @x_ - x
        dy = @y_ - y
        hypot dx, dy

    stroke: (ctx) ->
        ctx.lineWidth = @size_
        ctx.strokeStyle = @color_
        ctx.beginPath()
        ctx.arc @x_, @y_, DEFAULT_POINT_SIZE, 0, Math.PI*2, true
        ctx.closePath()
        ctx.stroke()

class LineElement  extends Element
    constructor: (line, view) ->
        super line, view
        @update()

    update: ->
        ln = @object_
        k = Math.abs ln.k()
        [@x0_, @y0_, @x1_, @y1_] =
            if k < 1
                [@view_.mapX(ln.x(@view_.revMapY 0)),               0,
                 @view_.mapX(ln.x(@view_.revMapY @view_.height())), @view_.height()]
            else
                [0,              @view_.mapY(ln.y(@view_.revMapX 0)),
                 @view_.width(), @view_.mapY(ln.y(@view_.revMapX @view_.width()))]

    distance: (x, y) ->
        v1x = @x1_ - @x0_
        v1y = @y1_ - @y0_
        v2x = x - @x0_
        v2y = y - @y0_
        v1 = hypot v1x, v1y
        v2 = hypot v2x, v2y
        v1_x_v2 = v1x * v2x + v1y * v2y
        Math.sqrt(v1 * v1 * v2 * v2 - v1_x_v2 * v1_x_v2) / v1

    stroke: (ctx) ->
        ctx.lineWidth = @size_
        ctx.strokeStyle = @color_
        ctx.beginPath()
        ctx.moveTo @x0_, @y0_
        ctx.lineTo @x1_, @y1_
        ctx.closePath()
        ctx.stroke()


class SegmentElement extends Element
    constructor: (segment, view) ->
        super segment, view
        @update()

    update: ->
        @x0_ = @view_.mapX @object_.start().x()
        @y0_ = @view_.mapY @object_.start().y()
        @x1_ = @view_.mapX @object_.end().x()
        @y1_ = @view_.mapY @object_.end().y()

    stroke: (ctx) ->
        ctx.lineWidth = @size_
        ctx.strokeStyle = @color_
        ctx.beginPath()
        ctx.moveTo @x0_, @y0_
        ctx.lineTo @x1_, @y1_
        ctx.closePath()
        ctx.stroke()


class View extends ViewPort
    constructor: (@plot_, @canvas_) ->
        super @canvas_.clientWidth, @canvas_.clientHeight
        @canvas_.width = @width()
        @canvas_.height = @height()
        @setupMouseHandler_()
        @selection_ = []
        @elements_ = {}
        @hoveredElements_ = []
        @plot_.changed.add (objs) => @update objs

    setupMouseHandler_: ->
        @mouseHandler_ = new MouseEventsHandler @canvas_
        @mouseHandler_.mouseMove().add((x, y) => @onMouseMove_ x, y)
        @mouseHandler_.startDrag().add((x, y) => @onStartDrag_ x, y)
        @mouseHandler_.drag().add((x, y) => @onDrag_ x, y)

    update: (objs) ->
        for obj in objs
            elem = @elements_[obj.id()]
            if elem
                elem.update()
            else
                @elements_[obj.id()] = @createElement_ obj

        @strokeAll_()

    strokeAll_: ->
        ctx = @canvas_.getContext '2d'
        ctx.clearRect 0, 0, @width(), @height()
        # first curves, ...
        for i of @elements_
            elem = @elements_[i]
            if elem not instanceof PointElement
                elem.stroke ctx

        # then points
        for i of @elements_
            elem = @elements_[i]
            if elem instanceof PointElement
                elem.stroke ctx

    createElement_: (obj) ->
        elem =
            if obj instanceof Point
                @createPointItem_ obj
            else if obj instanceof Circle
                @createCircleItem_ obj
            else if obj instanceof Line
                @createLineItem_ obj
            else if obj instanceof Segment
                @createSegmentItem_ obj
            else
                console.log "unknown object type"
        elem.changed().add => @strokeAll_()
        elem

    createCircleItem_: (c) ->
        elem = new CircleElement c, @
        elem.setColor 'blue'
        elem

    createLineItem_: (l) ->
        elem = new LineElement l, @
        elem.setColor 'green'
        elem

    createPointItem_: (p) ->
        elem = new PointElement p, @
        elem.setColor 'red'
        elem

    createSegmentItem_: (s) ->
        elem = new SegmentElement s, @
        elem.setColor 'green'
        elem

    onMouseMove_: (x, y) ->
        elements = @nearElements_ x, y

        for elem in @hoveredElements_
            if elem not in elements
                elem.hoverOut_()
        for elem in elements
            if elem not in @hoveredElements_
                elem.hoverIn_()
        @hoveredElements_ = elements

    onStartDrag_: (x, y) ->
        @draggedElem_ = _.find @nearElements_(x, y), (x) -> x.draggable()

    onDrag_: (x, y) ->
        @draggedElem_?.moveTo x, y

    onDragDrop_: (x, y) ->

    nearElements_: (x, y, maxDistance = 2.0) ->
        result = []
        for i of @elements_
            elem = @elements_[i]
            if elem.distance(x, y) < maxDistance
                result.push elem
        result

    closestElem_: (x, y, pred = (x) -> true) ->
        bestElem = null
        bestDist = Infinity
        for i of @elements_
            elem = @elements_[i]
            if not pred elem
                continue
            d = elem.distance x, y
            if d < bestDist
                bestDist = d
                bestElem = elem
        [bestElem, bestDist]


module.exports.View = View
