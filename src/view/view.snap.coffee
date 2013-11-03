Circle = (require "../core/circle").Circle
Line = (require "../core/line").Line
Point = (require "../core/point").Point
Segment = (require '../core/segment').Segment

class ViewPort
    constructor: (@width_, @height_) ->
        # real center coordinates
        @rcx_ = 0
        @rcy_ = 0

        @scale_ = 2

    width: -> @width_
    height: -> @height_

    # zoom around pixel coordinates (px, py)
    zoom: (px, py, factor) ->
        newCenter = @revMap px, py
        @rcx_ = newCenter[0]
        @rcy_ = newCenter[1]
        @scale_ *= Math.pow 2, factor

    # move by pixel coordinates
    move: (pdx, pdy) ->
        @rcx_ -= @revMapDist pdx
        @rcy_ -= @revMapDist pdy

    mapX: (rx) ->
        @scale_ * (rx - @rcx_) + @width_ / 2

    mapY: (ry) ->
        @scale_ * (@rcy_ - ry) + @height_ / 2

    # map real coordinates to pixel coordinates
    map: (rx, ry) ->
        [ @mapX(rx), @mapY(ry) ]

    revMapX: (px) ->
        (px - @width_ / 2) / @scale_ + @rcx_

    revMapY: (py) ->
        @rcy_ + (@height_ / 2 - py) / @scale_

    # map pixel coordinates to real ones
    revMap: (px, py) ->
        [ @revMapX(px), @revMapY(py) ]

    # map real distance to pixel distance
    mapDist: (rd) ->
        rd * @scale_

    revMapDist: (pd) ->
        pd / @scale_

# styles
DEFAULT_POINT_SIZE = 2
class View extends ViewPort
    constructor: (@plot_, canvas) ->
        super 600, 600
        @paper_ = Snap 600, 600
        @selection_ = []
        @items_ = {}

    update: ->
        for pt in @plot_.points()
            elem = @items_[pt.id()]
            if not elem?
                @items_[pt.id()] = @createItem_ pt
        for c in @plot_.curves()
            elem = @items_[c.id()]
            if not elem?
                @items_[c.id()] = @createItem_ c

    createItem_: (obj) ->
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


    createCircleItem_: (crc) ->
        c = @map crc.center.x(), crc.center.y()
        item = @paper_.circle c[0], c[1], @mapDist crc.radius()
        item.attr {stroke: 'blue', strokeWidth: 1}
        item

    createLineItem_: (ln) ->
        k = Math.abs ln.k()
        if k < 1
            console.log "here"
            p0 = [@mapX(ln.x(@revMapY 0)), 0]
            p1 = [@mapX(ln.x(@revMapY @height())), @height()]
        else
            console.log "foo"
            p0 = [0, @mapY(ln.y(@revMapX 0))]
            p1 = [@width(), @mapY(ln.y(@revMapX @width()))]

        item = @paper_.line p0[0], p0[1], p1[0], p1[1]
        item.attr {stroke: 'green', strokeWidth: 1}
        item

    createPointItem_: (pt) ->
        p = @map pt.x(), pt.y()
        item = @paper_.circle p[0], p[1], DEFAULT_POINT_SIZE
        item.attr {fill:'black', stroke: 'red', strokeWidth: 1}
        item

    createSegmentItem_: (sg) ->
        p0 = @map sg.start().x(), sg.start().y()
        p1 = @map sg.end().x(), sg.end().y()
        item = @paper_.line p0[0], p0[1], p1[0], p1[1]
        item.attr {stroke: 'green', strokeWidth: 1}
        item

module.exports.View = View
