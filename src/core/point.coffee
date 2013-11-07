PlotObject = (require "./plot_object").PlotObject
PlotObjectImpl = (require "./plot_object").PlotObjectImpl

#Global arrays
Letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']
LastUnusedLetter = 0
#End

class Point extends PlotObject
    constructor: (impl, name = undefined) ->
        super impl, name

    # x-coordinate of the point
    x: -> @impl_.x()

    # y-coordinate of the point
    y: -> @impl_.y()

    setX: (x) ->
        @impl_.setX x
        @changed.dispatch [@].concat @children true
        @

    setY: (y) ->
        @impl_.setY y
        @changed.dispatch [@].concat @children true
        @

    # @return [Boolean] whether point is independent from other figures or not
    independent: -> @impl_.independent()

    toString: ->
        "Point #{@name} (#{@x().toFixed(2)}, #{@y().toFixed(2)})"

    generateName: ->
        if (LastUnusedLetter - (LastUnusedLetter % Letters.length)) / Letters.length == 0
            result = Letters[LastUnusedLetter % Letters.length]
        else
            result = Letters[LastUnusedLetter % Letters.length] + '_' + ((LastUnusedLetter - (LastUnusedLetter % Letters.length)) / Letters.length)
        LastUnusedLetter += 1
        result

Point.names = []
Point.lastUnused = "A"


# Implementation of an independent point
class PointIndependent extends PlotObjectImpl
    @fullName = @register "PointIndependent"

    # @param [Number] x x-coordinate
    # @param [Number] y y-coordinate
    constructor: (x, y) ->
        @coords_ = x: x, y: y

    x: -> @coords_.x

    y: -> @coords_.y

    setX: (x) ->
        @coords_.x = x

    setY: (y) ->
        @coords_.y = y

    independent: -> true

    encoded: ->
        """ "x":#{@coords_.x}, "y":#{@coords_.y}"""

    @create = (x, y) ->
        new Point(new @ x, y)

    @fromJSON = (json) ->
        @.create json.x, json.y

Point.independent = (x, y) ->
    PointIndependent.create x, y


# Implementation of a point as a middle of a segment
class PointMidpoint extends PlotObjectImpl
    @fullName = @register "PointMidpoint"

    # @param [Point] pt0_ one end of a segment
    # @param [Point] pt1_ another end of a segment
    constructor: (@pt0_, @pt1_) ->

    x: ->
        @pt0_.x() / 2 + @pt1_.x() / 2.0

    y: -> (@pt0_.y() + @pt1_.y()) / 2.0

    independent: -> false

    encoded: ->
        """ "parents":[#{@pt0_.id()}, #{@pt1_.id()}]"""

    @create = (pt0, pt1) ->
        new Point(new @ pt0, pt1)

    @fromJSON = (json) ->
        p0 = PlotObject.find json.parents[0]
        p1 = PlotObject.find json.parents[1]
        @.create p0, p1

Point.midpoint = (pt0, pt1) ->
    PointMidpoint.create pt0, pt1

# -----------------------------------------------------------------
# Point as an intersection of two lines
# -----------------------------------------------------------------

Point.intersection = (curve0, curve1) ->
    if curve0 instanceof Line and curve1 instanceof Line
        PointLineLineIntersection.create(curve0, curve1)
    else if curve0 instanceof Circle and curve1 instanceof Circle
        PointCircleCircleIntersection.create(curve0, curve1)
    else
        console.log "Can not intersect two given curves"

# Intersection of two lines
class PointLineLineIntersection extends PlotObjectImpl
    @fullName = @register "PointLineLineIntersection"

    constructor: (@line0_, @line1_) ->
        @line0_.addChild @
        @line1_.addChild @

    x: ->
        (@line0_.b()*@line1_.c() - @line1_.b()*@line0_.c()) / @det_()

    y: ->
        (@line0_.c()*@line1_.a() - @line1_.c()*@line0_.a()) / @det_()

    det_: ->
        (@line0_.a()*@line1_.b() - @line1_.a()*@line0_.b())

    independent: -> false

    encoded: ->
        """ "parents":[#{@line0_.id()}, #{@line1_.id()}]"""

    @create = (l0, l1) ->
        new Point(new @ l0, l1)

    @fromJSON = (json) ->
        l0 = PlotObject.find json.parents[0]
        l1 = PlotObject.find json.parents[1]
        @.create l0, l1


# Точки пересечения двух окружностей
class PointCircleCircleIntersection extends PlotObjectImpl
    @fullName = @register "PointCircleCircleIntersection"

    @Core = class
        constructor: (@circ1_, @circ0_) ->

        x: (sign) ->
            x0 = @circ0_.center().x()
            x1 = @circ1_.center().x()
            y0 = @circ0_.center().y()
            y1 = @circ1_.center().y()
            R0 = @circ0_.radius()
            R1 = @circ1_.radius()
            dx = x0 - x1
            dy = y0 - y1
            d2 = dx * dx + dy * dy
            E = 4*dx*Math.sqrt(-(-(R0 + R1)*(R0 + R1) + d2)*(-(R0 - R1)*(R0 - R1) + d2))/(8*d2)
            F = (y0 + y1)/2.0 - ((R0*R0 - R1*R1)*dy)/(2*d2)

            (-R0*R0 + R1*R1 + x0*x0 - x1*x1 + y0*y0 - y1*y1 + -2*dy*(sign*E + F))/(2*dx)

        y: (sign) ->
            x0 = @circ0_.center().x()
            x1 = @circ1_.center().x()
            y0 = @circ0_.center().y()
            y1 = @circ1_.center().y()
            R0 = @circ0_.radius()
            R1 = @circ1_.radius()
            dx = x0 - x1
            dy = y0 - y1
            d2 = dx * dx + dy * dy
            E = 4*dx*Math.sqrt(-(-(R0 + R1)*(R0 + R1) + d2)*(-(R0 - R1)*(R0 - R1) + d2))/(8*d2)
            F = (y0 + y1)/2.0 - ((R0*R0 - R1*R1)*dy)/(2*d2)

            sign*E + F

    constructor: (circ0, circ1, sibling = null) ->
        if not sibling?
            @sign_ = 1
            @core_ = new PointCircleCircleIntersection.Core circ0, circ1
        else
            @sign_ = -1
            @core_ = sibling.impl_.core_
            @sibling_ = sibling

    x: -> @core_.x @sign_

    y: -> @core_.y @sign_

    independent: -> false

    encoded: ->
        res = """ "parents":[#{circ0_.id()}, #{circ1_.id()}]"""
        if @sibling_?
            res += ", \"sibling\": #{@sibling_.id()}"
        res

    @create = (circ0, circ1) ->
        pt0 = new Point(new @ circ0, circ1)
        pt1 = new Point(new @ circ0, circ1, pt0)
        [pt0, pt1]


    @fromJSON = (json) ->
        circ0 = PlotObject.find json.parents[0]
        circ1 = PlotObject.find json.parents[1]
        if not json.sibling?
            return new Point(new @ circ0, circ1)
        else
            sibling = PlotObject.find json.sibling
            return new Point(new @ circ0, circ1, sibling)


module.exports.Point = Point
