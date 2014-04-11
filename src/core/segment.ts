import curve = require("./curve");
import point = require("./point");

export class Segment extends curve.Curve {
    get start(): {x: number; y: number} {
        throw "Not implemented";
    }
    get end(): {x: number; y: number} {
        throw "Not implemented";
    }
}

class SegmentBy2Points extends Segment {
    constructor(
            private p0_: point.Point,
            private p1_: point.Point) {
        super();
    }

    get start() { return this.p0_; }
    get end() {return this.p1_; }

    /*
    sqDist() {
        #TODO: fixme
    }
    */
}

export function by2Points(p0, p1): Segment {
    return new SegmentBy2Points(p0, p1);
}
