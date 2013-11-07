class ViewPort
    constructor: (@width_, @height_) ->
        if (arguments.length < 2)
            throw "ViewPort size not specified"

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

module.exports.ViewPort = ViewPort
