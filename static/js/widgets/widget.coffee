class Widget
    constructor: ->
        @layout_ = null
        @color_ =0 

    render: ->

class Layout

class BoxLayout extends Layout
    constructor: ->
        @contents_ = []

class VBoxLayout extends BoxLayout
    constructor: ->

    addWidget: ->
