# View is responsible for calculating of visible area of the plot
class View
    # @param [Integer] width width in pixels
    # @param [Integer] height height in pixels
    # @param bottomLeft bottom left corner of the plot
    # @param topRight top right corner of the plot
    constructor: (@width, @height,
            @plCenter={x:0.0, y:0.0},
            plotWidth=10.0) ->
        @scale_ = plotWidth / @width

    scale: -> @scale_

    plotLeft: ->
        @plCenter.x - @scale_ * @width / 2.0

    plotRight: ->
        @plCenter.x + @scale_ * @width / 2.0

    plotTop: ->
        @plCenter.y + @scale_ * @height / 2.0

    plotBottom: ->
        @plCenter.y - @scale_ * @height / 2.0

    resize: (width, height) ->
        @width = width
        @height = height
    # Convert canvas coords to plot coords
    cvToPl: (cvX, cvY) ->
        x: @scale_ * (cvX - @width / 2.0) + @plCenter.x, \
        y: @scale_ * (- cvY + @height / 2.0) + @plCenter.y


    # Convert plot coords to canvas coords
    plToCv: (plX, plY) ->
        x:  (plX - @plCenter.x) / @scale_ + @width * 0.5, \
        y: -((plY - @plCenter.y) / @scale_) + @height * 0.5

    # Test if point with given coordinates is visible
    isVisible: (plX, plY) ->
        Math.abs(plX - @plCenter.x) < (@scale_ * @width / 2.0) && \
            Math.abs(plY - @plCenter.y) < (@scale_ * @height / 2.0)


    # Zoom in view at given point
    #
    # @param [Integer] dz zoom factor
    zoomIn: (cvX, cvY, dz=1) ->
        scaleFactor = Math.pow 2, dz
        plZoomCenter = @cvToPl cvX, cvY
        @plCenter = x: (@plCenter.x + plZoomCenter.x) / 2.0, \
                    y: (@plCenter.y + plZoomCenter.y) / 2.0
        @scale_ /= scaleFactor

    # Zoom out view at given point
    #
    # @param at fixed point
    # @param [Integer] dz zoom factor
    zoomOut: (at="center", dz=1) ->


