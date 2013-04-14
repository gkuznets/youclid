class Render
    constructor: (@plot_, @canvas_) ->
        @plot_.changed.add => @run()
        @ctx_ = @canvas_.getContext "2d"

        #$(@canvas_).attr height: 700, width: @canvas_.parentNode.clientWidth
        @view = new View(@canvas_.width, @canvas_.height)

        # colors
        @axisColor_ = "rgb(200, 200, 200)"
        @selectionColor_ = "rgb(200, 200, 200)"

    run: ->
        @ctx_.clearRect 0, 0, @canvas_.width, @canvas_.height

        @drawAxes_()

        @drawCurve_ curve for curve in @plot_.curves()
        @drawPoint_ point for point in @plot_.points()
        l = new Labeler
        l.drawLabels @plot_.points(), @ctx_, this

    updateCanvasSize: ->
        w = @canvas_.parentNode.clientWidth
        h = @canvas_.parentNode.clientHeight
        $(@canvas_).attr height: h, width: w
        @view.resize w, h
        @run()

    drawAxes_: ->
        ctx = @ctx_
        origin = @fromReal 0, 0
        ctx.strokeStyle = @axisColor_
        ctx.beginPath()
        ctx.moveTo 0, origin.y
        ctx.lineTo @canvas_.width, origin.y
        ctx.stroke()
        ctx.beginPath()
        ctx.moveTo origin.x, 0
        ctx.lineTo origin.x, @canvas_.height
        ctx.stroke()
        # drawing marks
        x1 = @fromReal 1.0, 0
        ctx.beginPath()
        ctx.moveTo x1.x, x1.y - 3
        ctx.lineTo x1.x, x1.y + 3
        ctx.stroke()
        y1 = @fromReal 0, 1.0
        ctx.beginPath()
        ctx.moveTo y1.x - 3, y1.y
        ctx.lineTo y1.x + 3, y1.y
        ctx.stroke()


    doDrawLine_: (from, to, th, cl) ->
        @ctx_.strokeStyle = cl
        @ctx_.lineWidth = th
        @ctx_.beginPath()
        @ctx_.moveTo from.x, from.y
        @ctx_.lineTo to.x, to.y
        @ctx_.stroke()

    doDrawCircle_: (ctr, r, th, cl) ->
        @ctx_.strokeStyle = cl
        @ctx_.lineWidth = th
        @ctx_.beginPath()
        @ctx_.arc ctr.x, ctr.y, r, 0, Math.PI*2, true
        @ctx_.stroke()
        @ctx_.closePath()

    drawCurve_: (curve) ->
        if curve instanceof Line
            line = curve
            if line.k()?  # non-vertical line
                leftX = @view.plotLeft()
                rightX = @view.plotRight()
                leftY = line.y leftX
                rightY = line.y rightX
                from = @fromReal leftX, leftY
                to = @fromReal rightX, rightY
            else
                topY = @view.plotTop()
                bottomY = @view.plotBottom
                x = line.x topY
                from = @fromReal x, topY
                to = @fromReal x, bottomY
            if curve.selected()
                @doDrawLine_ from, to, curve.style.thickness() + 2, @selectionColor_
            @doDrawLine_ from, to, curve.style.thickness(), curve.style.color()
        else if curve instanceof Circle
            ctr = curve.center()
            ctr = @fromReal ctr.x(), ctr.y()
            r = @fromRealDist curve.radius()
            if curve.selected()
                @doDrawCircle_ ctr, r, curve.style.thickness() + 2, @selectionColor_
            @doDrawCircle_ ctr, r, curve.style.thickness(), curve.style.color()

    doDrawPoint_: (x, y, sz, cl) ->
        @ctx_.fillStyle = cl
        @ctx_.beginPath()
        @ctx_.arc x, y, sz, 0, Math.PI*2, true
        @ctx_.fill()

    drawPoint_: (point) ->
        #if not @isVisible p
            p_ = @fromReal point.x(), point.y()
            if point.selected()
                @doDrawPoint_ p_.x, p_.y, point.style.size() + 2, @selectionColor_
            @doDrawPoint_ p_.x, p_.y, point.style.size(), point.style.color()

    isVisible: (obj) ->
        if obj instanceof Point
            @view.isVisible obj.x(), obj.y()

    # maps canvas coordinates into real coordinates
    # arguments are smth from:
    # * x and y
    # * {x: x, y: y}
    # * [x, y]
    toReal: ->
        [x, y] = toCoords arguments
        @view.cvToPl x, y

    # maps real coordinates into canvas coordinates
    fromReal: ->
        [x, y] = toCoords arguments
        @view.plToCv x, y

    fromRealDist: (d) ->
        d / @view.scale()

    toRealDist: (px) ->
        px * @view.scale()

    #! dist in real units
    findPoint: (x, y, dist) ->
        if not dist?
            dist = @toRealDist 4
        dist = dist * dist
        if arguments.length == 1
            [x, y] = toCoords arguments

        c_ = @toReal x, y
        for point in @plot_.points()
            dx = c_.x - point.x()
            dy = c_.y - point.y()
            if dx*dx + dy*dy < dist
                return point
        null

    findCurve: (x, y, dist) ->
        if not dist?
            dist = @toRealDist 2
        dist = dist * dist
        if arguments.length == 1
            [x, y] = toCoords arguments

        c_ = @toReal x, y
        for curve in @plot_.curves()
            if curve.sqDist c_.x, c_.y < dist
                return curve
        null

    # agrs ...
    findObject: ->
        [x, y] = toCoords arguments
        realPx = @toRealDist 1
        pt = @findPoint x, y, 4 * realPx
        if pt then pt else @findCurve x, y, 2 * realPx

    zoomIn: ->
        [x, y] = toCoords arguments
        @view.zoomIn x, y
        @run()

