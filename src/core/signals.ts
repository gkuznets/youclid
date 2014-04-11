/// <reference path="../../typings/underscore/underscore.d.ts" />

export interface Callback {
    (...args: any[]): any;
}

interface ListenerEntry {
    signal: Signal;
    callbacks : Callback[];
}

export class Listener {
    private signals_: ListenerEntry[];

    constructor(private name_: string = "") {
        this.signals_ = [];
    }

    destroy() {
        this.signals_.forEach((entry) => {
            entry.signal.forget(this);
        });
        this.signals_ = [];
    }

    listen(signal: Signal, callback: Callback) {
        var entry = this.findOrCreateEntry(signal);
        entry.callbacks.push(callback);
    }

    private findEntry(signal: Signal) {
        return _.find(this.signals_,
                (e: ListenerEntry) => { return e.signal === signal; });
    }
    private findOrCreateEntry(signal: Signal) {
        var entry = this.findEntry(signal);
        if (!entry) {
            entry = {signal: signal, callbacks: []};
            this.signals_.push(entry);
        }
        return entry;
    }

    receive(signal: Signal, args: any[]) {
        var entry = this.findEntry(signal);
        if (entry) {
            entry.callbacks.forEach((callback) => {
                callback.apply(this, args);
            });
        } else {
            console.log(this + " : Received unknown signal (" + signal + ")");
        }
    }

    toString() {
        return this.name_.length > 0 ? "Listener[" + this.name_ + "]" : "Listener";
    }
}

export class Signal {
    private listeners_: Listener[];

    constructor(private name_: string = "") {
        this.listeners_ = []
    }

    destroy() {
    }

    register(listener: Listener) {
        if (this.listeners_.indexOf(listener) == -1) {
            this.listeners_.push(listener);
        }
    }

    forget(listener: Listener) {
        var pos = this.listeners_.indexOf(listener);
        if (pos != -1) {
            this.listeners_.splice(pos, 1);
        } else {
            console.log(this +
                    ": Trying to remove unknown listener (" + listener + ")");
        }
    }

    emit(...args: any[]) {
        this.listeners_.forEach((listener) => {
            listener.receive(this, args);
        });
    }

    toString() {
        return this.name_.length > 0 ? "Signal[" + this.name_ + "]" : "Signal";
    }
}

export function connect(
        signal: Signal,
        listener: Listener,
        callback: Callback) {
    signal.register(listener);
    listener.listen(signal, callback);
}
