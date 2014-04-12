import assert = require("./assert");
import PlotObject = require("./PlotObject");

export class Point extends PlotObject {
    constructor(name: string = undefined) {
        super(name || Point.generateName());
    }

    get x(): number { throw "Not implemented"; }
    get y(): number { throw "Not implemented"; }
    moveTo(x: number, y: number): void {
        throw "Dependent point can't be moved";
    }
    get independent() {return false; }

    private static letters_ = "ABCDEFGHIJKLMNOPQRSTUVVWXYZ";
    private static lastUnusedLtr_ = 0;
    private static generateName() {
        if (Point.lastUnusedLtr_ < Point.letters_.length) {
            return Point.letters_[Point.lastUnusedLtr_++];
        } else {
            var idx = ++Point.lastUnusedLtr_ - Point.letters_.length;
            return "P" + idx.toString();
        }
    }
}

class IndependentPoint extends Point {
    private coords_: {x: number; y: number};

    constructor(x: number, y: number) {
        super();
        this.coords_ = {x: x, y: y};
    }

    get x() { return this.coords_.x; }
    set x(x: number) {
        this.coords_.x = x;
        this.changed.emit();
    }
    get y() { return this.coords_.y; }
    set y(y: number) {
        this.coords_.y = y;
        this.changed.emit();
    }
    moveTo(x, y) {
        this.coords_.x = x;
        this.coords_.y = y;
        this.changed.emit(this);
    }

    get independent() { return true; }
}

export function independent(x, y): Point {
    return new IndependentPoint(x, y);
}

// Middle of a segment
class Midpoint extends Point {
    // @param [Point] pt0_ one end of a segment
    // @param [Point] pt1_ another end of a segment
    constructor(
            private pt0_: Point,
            private pt1_: Point) {
        super();
        this.pt0_.addChild(this);
        this.pt1_.addChild(this);
    }

    get x() { return (this.pt0_.x + this.pt1_.x) / 2.0; }
    get y() { return (this.pt0_.y + this.pt1_.y) / 2.0; }
    get independent() { return false; }
}

export function midpoint(pt0, pt1): Point {
    return new Midpoint(pt0, pt1);
}
