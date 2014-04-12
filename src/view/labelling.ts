import Coords = require("../Coords");
import font_metrics = require("./typography/font_metrics");
import Rect = require("../Rect");
import Vec = require("../Vec");

export interface Feature {
    effect: (label: Label) => Vec;
}

export class Label implements Feature {
    private static font_ = "18pt Times";
    private metrics_: font_metrics.Metrics;

    constructor(
            private text_: string,
            private labeller_: Labeller,
            public pos: Coords = {x: 0, y :0},
            public dirty: boolean = true) {
        this.metrics_ = font_metrics.glyphMetrics(text_[0], Label.font_);
    }

    destroy() {
        // TODO: remove this from this.labeller_
    }

    get rect() {
        return new Rect(
                {x: this.pos.x, y: this.pos.y - this.metrics_.height},
                {x: this.pos.x + this.metrics_.width, y: this.pos.y});
    }

    update() {
    }

    stroke(ctx: CanvasRenderingContext2D) {
        if (!this.dirty) {
            ctx.lineWidth = 1.0;
            ctx.font = Label.font_;
            ctx.fillStyle = "black";
            ctx.strokeStyle = "black";
            ctx.fillText(this.text_, this.pos.x, this.pos.y);
            //ctx.strokeStyle = "magenta";
            //var rect = this.rect;
            //ctx.strokeRect(
            //        rect.topLeft.x, rect.topLeft.y, rect.width, rect.height);
        }
    }

    effect(other: Label) {
        if (other === this) {
            return Vec.zero;
        }
        var optimalPadding = 5;
        var thisRect = this.rect;
        var otherRect = other.rect;
        var distance = Math.max(0.5, thisRect.distanceToRect(otherRect));
        if (distance < optimalPadding) {
            var dir = new Vec(
                    otherRect.center.x - thisRect.center.x,
                    otherRect.center.y - thisRect.center.y);
            return dir.resized(optimalPadding - distance);
        }
        return Vec.zero;
    }
}

export class Labeller {
    private labels_: Label[];

    constructor(private elements_: Feature[]) {
        this.labels_ = [];
    }

    makeLabel(text: string) {
        var lbl = new Label(text, this);
        this.labels_.push(lbl);
        return lbl;
    }

    updateLabels() {
        var iterations = 0;
        var hasDirtyLabels = true;
        while (hasDirtyLabels) {
            hasDirtyLabels = false;
            this.labels_.forEach((label: Label) => {
                if (!label.dirty) {
                    return;
                }
                var effect = this.effect(label);
                label.pos = {x: label.pos.x + effect.x, y: label.pos.y + effect.y};
                if (effect.length < 0.5) {
                    label.dirty = false;
                } else {
                    hasDirtyLabels = true;
                }
            });
            iterations++;
            if (iterations > 10) {
                break;
            }
        }
    }

    private effect(label: Label) {
        var result = Vec.zero;
        this.elements_.forEach((feature) => {
            result = result.plus(feature.effect(label));
        });
        this.labels_.forEach((otherLabel) => {
            result = result.plus(otherLabel.effect(label));
        });
        return result;
    }
}
