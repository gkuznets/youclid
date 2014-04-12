import Coords = require("../Coords");
import curve = require("./curve");
import point = require("./point");
import Vec = require("../Vec");

export class Line extends curve.Curve {
    // Arbitrary point on the line
    get source(): Coords {
        throw "Not implemented";
    }
    get dir(): Vec {
        throw "Not implemented";
    }
    get slope(): number {
        throw "Not implemented";
    }
    get a(): number {
        throw "Not implemented";
    }
    get b(): number {
        throw "Not implemented";
    }
    get c(): number {
        throw "Not implemented";
    }
    x(y: number): number {
        throw "Not implemented";
    }
    y(x: number): number {
        throw "Not implemented";
    }
}

class LineBy2Points extends Line {
    constructor(
            private p0_: point.Point,
            private p1_: point.Point) {
        super();
        this.p0_.addChild(this);
        this.p1_.addChild(this);
    }

    get source() { return this.p0_; }

    get dir() {
        return new Vec(this.p1_.x - this.p0_.x, this.p1_.y - this.p0_.y);
    }

    get a() {
        if (this.p0_.y == this.p1_.y) {
            return 0.0;
        } else {
            return 1.0;
        }
    }

    get b() {
        var dy = this.p0_.y - this.p1_.y;
        return dy == 0 ? 1.0 : (this.p1_.x - this.p0_.x) / dy;
    }

    get c() {
        return -(this.a * this.p0_.x + this.b * this.p0_.y);
    }

    get slope() {
        // -b/a
        // Automatically handles +/-Infinity cases
        var dy = this.p0_.y - this.p1_.y;
        return -(this.p1_.x - this.p0_.x) / dy;
    }

    x(y) {
        var dy = this.p1_.y - this.p0_.y;
        if (dy != 0) {
            return this.p0_.x +
                (y - this.p0_.y) * (this.p1_.x - this.p0_.x) / dy;
        } else {
            return undefined;
        }
    }

    y(x) {
        var dx = this.p1_.x - this.p0_.x;
        if (dx != 0) {
            return this.p0_.y +
                (x - this.p0_.x) * (this.p1_.y - this.p0_.y) / dx;
        } else {
            return undefined;
        }
    }

    sqDist(x, y) {
        var dx = this.p1_.x - this.p0_.x;
        var dy = this.p1_.y - this.p0_.y;
        var dx0 = x - this.p0_.x;
        var dy0 = y - this.p0_.y;
        var d = dx * dx0 + dy * dy0;
        return (d * d) / (dx * dx + dy * dy);
    }
}

export function by2Points(p0, p1): Line {
    return new LineBy2Points(p0, p1);
}

class Perpendicular extends Line {
    constructor(
            private pt_: point.Point,
            private line_: Line) {
        super();
        this.pt_.addChild(this);
        this.line_.addChild(this);
    }

    get source() { return this.pt_; }
    get dir() { return this.line_.dir.perp; }
    get a() {
        return this.slope == Infinity || this.slope == -Infinity ? 0.0 : 1.0;
    }
    get b() {
        var s = this.slope;
        return s == 0 ? 0.0 : -s;
    }
    get c() {
        return this.a == 0 ?
            -this.b * this.pt_.y :
            -(this.pt_.x + this.b * this.pt_.y);
    }
    get slope() {
        return -1.0 / this.line_.slope;
    }

    x(y) {
        var s = this.slope;
        return s == Infinity || s == -Infinity ? undefined : s * y - this.c;
    }

    y(x) {
        var s = this.slope;
        return s == 0 ? undefined : (this.a * x + this.c) / s;
    }

    sqDist(x, y) {
        var dir = this.dir;
        var dx = dir.x;
        var dy = dir.y;
        var dx0 = x - this.pt_.x;
        var dy0 = y - this.pt_.y;
        var d = dx * dx0 + dy * dy0;
        return (d * d) / (dx * dx + dy * dy);
    }
}


export function perpendicular(pt, line): Line {
    return new Perpendicular(pt, line);
}


class Parallel extends Line {
    constructor(
            private pt_: point.Point,
            private line_: Line) {
        super();
        this.pt_.addChild(this);
        this.line_.addChild(this);
    }

    get source() { return this.pt_; }
    get dir() { return this.line_.dir; }
    get a() { return this.line_.a; }
    get b() { return this.line_.b; }
    get c() { return - this.a * this.pt_.x - this.b * this.pt_.y; }
    get slope() { return this.line_.slope; }

    x(y) {
        return this.a != 0 ?  - (this.c + this.b * y) / this.a : undefined;
    }

    y(x) {
        return this.b != 0 ?  - (this.c + this.a * x) / this.b : undefined;
    }

    sqDist(x, y) {
        // copy-pasted from perpendicular
        var dir = this.dir;
        var dx = dir.x;
        var dy = dir.y;
        var dx0 = x - this.pt_.x;
        var dy0 = y - this.pt_.y;
        var d = dx * dx0 + dy * dy0;
        return (d * d) / (dx * dx + dy * dy);
    }
}

export function parallel (pt, line): Line {
    return new Parallel(pt, line);
}

