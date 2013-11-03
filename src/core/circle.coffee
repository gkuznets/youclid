Curve = (require "./curve").Curve
PlotObjectImpl = (require "./plot_object").PlotObjectImpl

class Circle extends Curve
    constructor: (impl, name = undefined) ->
        super impl, name

    center: ->
        @impl_.center()

    radius: ->
        @impl_.radius()

    sqDist: (x, y) ->
        dx = @center().x() - x
        dy = @center().y() - y
        distToCenter = Math.sqrt(dx*dx + dy*dy)
        dist = distToCenter - @radius()
        return dist * dist

Circle.ByCenterAndPoint = class extends PlotObjectImpl
    @fullName = @register "Circle.ByCenterAndPoint"

    constructor: (@center_, @point_) ->

    center: -> @center_

    radius: ->
        dx = @center_.x() - @point_.x()
        dy = @center_.y() - @point_.y()
        Math.sqrt(dx*dx + dy*dy)

    encoded: ->
        """ "parents":[#{@center_.id()}, #{@point_.id()}]"""

    @fromJSON = (json) ->
        c = PlotObject.find json.parents[0]
        p = PlotObject.find json.parents[1]
        Circle.byCenterAndPoint c, p

Circle.byCenterAndPoint = (center, point) ->
    new Circle new Circle.ByCenterAndPoint center, point

# TODO: fix me
Circle.By3Points = class extends PlotObjectImpl
    @fullName = @register "Circle.By3Points"
#    constructor: (@p0_, @p1_, @p2_) ->
#    
#    center: ->
#        x0 = @p0_.x(); y0 = @p0_.y()
#        x1 = @p1_.x(); y1 = @p1_.y()
#        x2 = @p2_.x(); y2 = @p2_.y()
#        d0 = x0*x0 + y0*y0
#        d1 = x1*x1 + y1*y1
#        d2 = x2*x2 + y2*y2
#        x10 = x1 - x0; x21 = x2 - x1; x02 = x0 - x2
#        y10 = y1 - y0; y21 = y2 - y1; y02 = y0 - y2
#        [(d0*y21 + d1*y02 + d2*y10) / (x0*y21 + x1*y02 + x2*y10),
#         (d0*x21 + d1*x02 + d2*x10) / (y0*x21 + y1*x02 + y2*x10)]
#
#    radius: ->
#        c = @center()
#        dx = c[0] - @p0_.x(); dy = c[1] - @p0_.y()
#        Math.sqrt(dx*dx + dy*dy)
#
    constructor: (@p1_, @p2_, @p3_) ->

    radius: ->
        a = distance(@p1_, @p2_)
        b = distance(@p2_, @p3_)
        c = distance(@p3_, @p1_)
        (a * b * c) / Math.sqrt((a + b + c) * (-a + b + c) * (a - b + c) * (a + b - c))

    center: ->
        if @p2_.y() != @p1_.y() and @p2_.y() != @p3_.y()
            k1 = (@p1_.x() - @p2_.x()) / (@p2_.y() - @p1_.y())
            b1 = (@p1_.y() + @p2_.y()) / 2 - k1 * (@p1_.x() + @p2_.x()) / 2

            k2 = (@p3_.x() - @p2_.x()) / (@p2_.y() - @p3_.y())
            b2 = (@p2_.y() + @p3_.y()) / 2 - k2 * (@p2_.x() + @p3_.x()) / 2

            x = (b2 - b1) / (k1 - k2)
            y = k1 * x + b1

        if @p2_.y() == @p1_.y() and @p2_.y() != @p3_.y()
            k = (@p3_.x() - @p2_.x()) / (@p2_.y() - @p3_.y())
            b = (@p2_.y() + @P3_.y()) / 2 - k * (@p2_.x() + @p3_.x()) / 2

            x = (@p2.x() + @p1.x()) / 2
            y = k * x + b

        if @p2_.y() != @p1_.y() and @p2_.y() == @p3_.y()
            k = (@p1_.x() - @p2_.x()) / (@p2_.y() - @p1_.y())
            b = (@p1_.y() + @p2_.y()) / 2 - k * (@p1_.x() + @p2_.x()) / 2

            x = (@p2_.x() + @p3_.x()) / 2
            y = k * x + b

        if @p2_.y() == @p1_.y() and @p2_.y() == @p3_.y()
            x = NaN
            y = NaN

        new Point(x, y)

    encoded: ->
        """ "parents":[#{@p1_.id()}, #{@p2_.id()}, #{@p3_.id()}]"""

    @fromJSON = (json) ->
        p0 = PlotObject.find json.parents[0]
        p1 = PlotObject.find json.parents[1]
        p2 = PlotObject.find json.parents[2]
        Circle.by3Points p0, p1, p2

Circle.by3Points = (p0, p1, p2) ->
    new Circle new Circle.By3Points p0, p1, p2


module.exports.Circle = Circle
