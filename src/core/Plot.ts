import curve = require("./curve");
import point = require("./point");
import signals = require("./signals");

class Plot {
    private curves_: curve.Curve[];
    private points_: point.Point[];
    private title_: string;
    private changed_: signals.Signal;
    private listener_: signals.Listener;

    constructor() {
        this.curves_ = [];
        this.points_ = [];
        this.title_ = "new plot";
        this.changed_ = new signals.Signal();
        this.listener_ = new signals.Listener("plot listener");
    }

    destroy() {
        this.listener_.destroy();
        this.changed_.destroy();
    }

    get title() { return this.title_; }
    get objects() { return this.curves_.concat(this.points_); }
    get changed() { return this.changed_; }

    add(pt: point.Point);
    add(crv: curve.Curve);
    add(obj) {
        if (obj instanceof point.Point) {
            this.points_.push(obj);
        } else if (obj instanceof curve.Curve) {
            this.curves_.push(obj);
        }
        signals.connect(obj.changed, this.listener_,
                (obj) => {
                    var affected = obj.children(true).concat([obj]);
                    this.changed_.emit(affected);
                });
        this.changed_.emit([obj]);
    }
}

export = Plot;
