/// <reference path="../../typings/underscore/underscore.d.ts" />
import circle = require("../core/circle");
import line = require("../core/line");
import MouseEventsHandler = require("./MouseEventsHandler");
import Plot = require("../core/Plot");
import PlotObject = require("../core/PlotObject");
import point = require("../core/point");
import segment = require("../core/segment");
import signals = require("../core/signals");
import ViewPort = require("./ViewPort");

var DEFAULT_POINT_SIZE = 2;

function hypot(dx, dy) {
    return Math.sqrt(dx * dx + dy * dy);
}

interface Movable {
    moveTo?: (x: number, y: number) => void;
}

class Element implements Movable {
    private changed_: signals.Signal;
    private onHoverIn_: () => any;
    private onHoverOut_: () => any;

    constructor(
            private view_: ViewPort,
            private size_: number = 1,
            private color_: string = 'black') {
        // decide on responsibility of this signal
        this.changed_ = new signals.Signal();
    }

    get size() { return this.size_; }
    set size(newSize) {
        if (newSize != this.size_) {
            this.size_ = newSize;
            this.changed_.emit();
        }
    }

    get color() { return this.color_; }
    set color(newColor) {
        if (newColor != this.color_) {
            this.color_ = newColor;
            this.changed_.emit();
        }
    }

    get view() { return this.view_; }
    get changed() { return this.changed_; }

    // distance form element to pixel (x, y)
    distance(x, y) : number {
        return Infinity;
    }

    hover(onHoverIn, onHoverOut) {
        this.onHoverIn_ = onHoverIn;
        this.onHoverOut_ = onHoverOut;
    }

    hoverIn() {
        this.size_ = 2;
        this.changed_.emit();
        if (this.onHoverIn_) {
            this.onHoverIn_();
        }
    }

    hoverOut() {
        this.size_ = 1;
        this.changed_.emit();
        if (this.onHoverOut_) {
            this.onHoverOut_();
        }
    }

    get draggable() { return false; }

    stroke(ctx: CanvasRenderingContext2D) {
        throw "Not implemented";
    }

    update() {
        throw "Not implemented";
    }
}

class CircleElement extends Element {
    private x: number;
    private y: number;
    private radius: number;

    constructor(private circle: circle.Circle, view) {
        super(view);
        this.update();
    }

    update() {
        this.x = this.view.mapX(this.circle.center.x);
        this.y = this.view.mapY(this.circle.center.y);
        this.radius = this.view.mapDist(this.circle.radius);
    }

    distance(x, y) {
        var dx = this.x - x;
        var dy = this.y - y;
        return Math.abs(this.radius - hypot(dx, dy));
    }

    stroke(ctx) {
        ctx.lineWidth = this.size;
        ctx.strokeStyle = this.color;
        ctx.beginPath();
        ctx.arc(this.x, this.y, this.radius, 0, Math.PI * 2, true);
        ctx.closePath();
        ctx.stroke();
    }
}

class PointElement extends Element {
    private x: number;
    private y: number;

    constructor(private point: point.Point, view) {
        super(view);
        this.update();
    }

    update() {
        this.x = this.view.mapX(this.point.x);
        this.y = this.view.mapY(this.point.y);
    }

    distance(x, y) {
        var dx = this.x - x;
        var dy = this.y - y;
        return hypot(dx, dy);
    }

    stroke(ctx) {
        ctx.lineWidth = this.size;
        ctx.strokeStyle = this.color;
        ctx.beginPath();
        ctx.arc(this.x, this.y, DEFAULT_POINT_SIZE, 0, Math.PI * 2, true);
        ctx.closePath();
        ctx.stroke();
    }

    get draggable() { return true; }

    moveTo(x, y) {
        this.point.moveTo(this.view.revMapX(x), this.view.revMapY(y));
    }
}

class LineElement  extends Element {
    private x0: number;
    private y0: number;
    private x1: number;
    private y1: number;

    constructor(private line: line.Line, view) {
        super(view);
        this.update();
    }

    update() {
        var absSlope = Math.abs(this.line.slope);
        if (absSlope < 1) {
            this.x0 = this.view.mapX(
                    this.line.x(this.view.revMapY(0)));
            this.y0 = 0;
            this.x1 = this.view.mapX(
                    this.line.x(this.view.revMapY(this.view.height)));
            this.y1 = this.view.height;
        } else {
            this.x0 = 0;
            this.y0 = this.view.mapY(
                    this.line.y(this.view.revMapX(0)));
            this.x1 = this.view.width;
            this.y1 = this.view.mapY(
                    this.line.y(this.view.revMapX(this.view.width)));
        }
    }

    distance(x, y) {
        var v1x = this.x1 - this.x0;
        var v1y = this.y1 - this.y0;
        var v2x = x - this.x0;
        var v2y = y - this.y0;
        var v1 = hypot(v1x, v1y);
        var v2 = hypot(v2x, v2y);
        var v1_x_v2 = v1x * v2x + v1y * v2y;
        return Math.sqrt(v1 * v1 * v2 * v2 - v1_x_v2 * v1_x_v2) / v1;
    }

    stroke(ctx) {
        ctx.lineWidth = this.size;
        ctx.strokeStyle = this.color;
        ctx.beginPath();
        ctx.moveTo(this.x0, this.y0);
        ctx.lineTo(this.x1, this.y1);
        ctx.closePath();
        ctx.stroke();
    }
}

class SegmentElement extends Element {
    private x0_: number;
    private y0_: number;
    private x1_: number;
    private y1_: number;

    constructor(private segment_: segment.Segment, view) {
        super(view);
        this.update();
    }

    update() {
        this.x0_ = this.view.mapX(this.segment_.start.x);
        this.y0_ = this.view.mapY(this.segment_.start.y);
        this.x1_ = this.view.mapX(this.segment_.end.x);
        this.y1_ = this.view.mapY(this.segment_.end.y);
    }

    stroke(ctx) {
        ctx.lineWidth = this.size;
        ctx.strokeStyle = this.color;
        ctx.beginPath();
        ctx.moveTo(this.x0_, this.y0_);
        ctx.lineTo(this.x1_, this.y1_);
        ctx.closePath();
        ctx.stroke();
    }
}


class View extends ViewPort {
    private canvas_: HTMLCanvasElement;
    private plot_: Plot;
    private selection_: any[];
    private elements_: Element[];
    private mouseHandler_: MouseEventsHandler;
    private hoveredElements_: Element[];
    private draggedElem_; Element;
    private listener_: signals.Listener;

    constructor(plot: Plot, canvas: HTMLCanvasElement) {
        super(canvas.clientWidth, canvas.clientHeight);
        this.plot_ = plot;
        this.canvas_ = canvas;
        this.canvas_.width = this.width;
        this.canvas_.height = this.height;
        this.selection_ = [];
        this.elements_ = [];
        this.hoveredElements_ = [];
        this.listener_ = new signals.Listener("view listener");
        this.setupMouseHandler();
        this.update(this.plot_.objects);
        signals.connect(
                this.plot_.changed, this.listener_,
                (objects) => { this.update(objects); });
    }

    private setupMouseHandler() {
        this.mouseHandler_ = new MouseEventsHandler(this.canvas_);
        signals.connect(this.mouseHandler_.mouseMove, this.listener_,
                (x, y) => { this.onMouseMove(x, y); });
        signals.connect(this.mouseHandler_.startDrag, this.listener_,
                (x, y) => { this.onStartDrag(x, y); });
        signals.connect(this.mouseHandler_.drag, this.listener_,
                (x, y) => { this.onDrag(x, y); });
    }

    update(objects: PlotObject[]) {
        objects.forEach((object) => {
            if (object.id in this.elements_) {
                this.elements_[object.id].update();
            } else {
                this.elements_[object.id] = this.createElement(object);
            }
        });
        this.strokeAll();
    }

    private strokeAll() {
        var ctx = this.canvas_.getContext('2d');
        ctx.clearRect(0, 0, this.width, this.height);
        // first curves
        this.elements_.forEach((element) => {
            if (!(element instanceof PointElement)) {
                element.stroke(ctx);
            }
        });

        // then points
        this.elements_.forEach((element) => {
            if (element instanceof PointElement) {
                element.stroke(ctx);
            }
        });
    }

    private createElement(obj) {
        var elem: Element;
        if (obj instanceof point.Point) {
            elem = new PointElement(obj, this)
            elem.color = 'red';
        } else if (obj instanceof circle.Circle) {
            elem = new CircleElement(obj, this);
            elem.color = 'blue';
        } else if (obj instanceof line.Line) {
            elem = new LineElement(obj, this);
            elem.color = 'green';
        } else if (obj instanceof segment.Segment) {
            elem = new SegmentElement(obj, this);
            elem.color = 'green';
        } else {
            console.log("unknown object type");
        }
        signals.connect(elem.changed, this.listener_,
                () => { this.strokeAll(); });
        return elem;
    }

    private onMouseMove(x, y) {
        var elements = this.nearElements(x, y);

        this.hoveredElements_.forEach((elem) => {
            if (elements.indexOf(elem) != -1) {
                elem.hoverOut();
            }
        });
        elements.forEach((elem) => {
            if (this.hoveredElements_.indexOf(elem) != -1) {
                elem.hoverIn();
            }
        });
        this.hoveredElements_ = elements;
    }

    private onStartDrag(x, y) {
        this.draggedElem_ = _.find(
                this.nearElements(x, y),
                (e: Element) => { return e.draggable; });
    }

    private onDrag(x, y) {
        if (this.draggedElem_) {
            this.draggedElem_.moveTo(x, y)
        }
    }

    private onDragDrop(x, y) {}

    private nearElements(x, y, maxDistance = 2.0) {
        return _.filter(
                this.elements_,
                (element: Element) => {
                    return element.distance(x, y) < maxDistance;
                });
    }

    closestElem(x, y, pred = (x) => { return true; }) {
        var bestElem = null;
        var bestDist = Infinity;
        _.filter(this.elements_, pred).forEach((element) => {
            var d = element.distance(x, y);
            if (d < bestDist) {
                bestDist = d;
                bestElem = element;
            }
        });
        return [bestElem, bestDist]
    }
}

export = View;
