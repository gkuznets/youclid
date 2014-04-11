/// <reference path="../../typings/jquery/jquery.d.ts" />
import signals = require("../core/signals");

var MIN_DRAG_DISTANCE = 4;
var MAX_CLICK_DISTANCE = 2;

function distance(a, b) {
    var dx = a.x - b.x;
    var dy = a.y - b.y;
    return Math.sqrt(dx * dx + dy * dy);
}

class MouseEventsHandler {
    private click_: signals.Signal;
    private drag_: signals.Signal;
    private dragDrop_: signals.Signal;
    private hoverOut_: signals.Signal;
    private mouseMove_: signals.Signal;
    private startDrag_: signals.Signal;

    private dragStarted_: boolean;
    private mouseDownPos_: {x: number; y: number};

    constructor(private element_: HTMLElement) {
        $(this.element_).mousemove(
                (event) => { this.onMouseMove(event); });
        $(this.element_).mousedown(
                (event) => { this.onMouseDown(event); });
        $(this.element_).mouseup(
                (event) => { this.onMouseUp(event); });

        this.click_ = new signals.Signal();
        this.mouseMove_ = new signals.Signal();
        this.hoverOut_ = new signals.Signal();

        this.startDrag_ = new signals.Signal();
        this.drag_ = new signals.Signal();
        this.dragDrop_ = new signals.Signal();

        this.dragStarted_ = false;
    }

    get click() { return this.click_; }
    get drag() { return this.drag_; }
    get dragDrop() { return this.dragDrop_; }
    get hoverOut() { return this.hoverOut_; }
    get mouseMove() { return this.mouseMove_; }
    get startDrag() { return this.startDrag_; }

    private coords(event: {clientX: number; clientY: number}) {
        return {x: event.clientX - this.element_.offsetLeft,
                y: event.clientY - this.element_.offsetTop};
    }

    private onMouseMove(event) {
        var coords = this.coords(event);
        if (this.mouseDownPos_) {
            if (distance(coords, this.mouseDownPos_) > MIN_DRAG_DISTANCE &&
                    !this.dragStarted_) {
                this.startDrag_.emit(
                        this.mouseDownPos_.x, this.mouseDownPos_.y);
                this.dragStarted_ = true;
            }
            if (this.dragStarted_) {
                this.drag_.emit(coords.x, coords.y);
            }
        } else {
            this.mouseMove_.emit(coords.x, coords.y);
        }
    }

    private onMouseDown(event) {
        this.mouseDownPos_ = this.coords(event);
    }

    private onMouseUp(event) {
        var coords = this.coords(event);
        if (this.dragStarted_) {
            this.dragDrop_.emit(coords.x, coords.y);
            this.dragStarted_ = false;
        } else if (distance(this.mouseDownPos_, coords) < MAX_CLICK_DISTANCE) {
            this.click_.emit(
                    this.mouseDownPos_.x, this.mouseDownPos_.y);
        }

        this.mouseDownPos_ = null;
    }
}

export = MouseEventsHandler;
