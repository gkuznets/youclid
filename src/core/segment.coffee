Curve = (require "./curve").Curve
PlotObjectImpl = (require "./plot_object").PlotObjectImpl

class Segment extends Curve
    constructor: (impl, name) ->
        super impl, name

    start: -> impl_.start()
    end: -> impl_.end()
    ends: -> impl_.ends()

    sqDist: ->
        [x, y] = toCoords arguments
        @impl_.sqDist x, y


Segment.Plain = class extends PlotObjectImpl
    @fullName = @register "Segment.Plain"

    constructor: (@p0_, @p1_) ->

    start: -> @p0_
    end: -> @p1_
    ends: -> [@p0_, @p1_]

    sqDist: ->
        #TODO: fixme

    encoded: ->
        """ "parents":[#{@p0_.id()},#{@p1_.id()}]"""

Segment.by2Points = (p0, p1)
    s = new Segment new Segment.Plain p0, p1
    p0.addChild s
    p1.addChild s
    s

module.exports.Segment = Segment
