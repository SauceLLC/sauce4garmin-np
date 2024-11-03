import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

using Toybox.System as Sys;
using Toybox.Lang as Lang;


class SauceDataField extends WatchUi.SimpleDataField {

    private var count as Number;
    private var total as Long;
    private var index as Number;
    private var rollSum as Number;
    private var lastTime as Number;
    private var rolling as Array<Number> = new Array<Number>[30];
    private var value as Number;

    function initialize() {
        SimpleDataField.initialize();
        label = "NP";
        count = 0;
        total = 0l;
        rollSum = 0;
        index = 0;
        value = 0;
        lastTime = 0;
        for (var i = 0; i < 30; i++) {
            rolling[i] = 0;
        }
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
        //var power = info.currentPower != null ? info.currentPower as Number : 0;
        var power = info.currentPower as Number;
        var time = info.timerTime != null ? info.timerTime as Number : 0;
        Sys.println("");
        Sys.println(Lang.format("time: $1$ timer $2$ power $3$", [info.elapsedTime, time, power]));
        Sys.println(Lang.format("index: $1$ count $2$ total $3$", [index, count, total]));
        var gap = time - lastTime;
        Sys.println(Lang.format("gap: $1$", [gap]));
        if (gap == 0) {
            return value;
        }
        lastTime = time;
        for (var i = 1000; i < (gap - 900); i += 1000) {
            var slot = index % 30;
            index++;
            rollSum = rollSum - rolling[slot];
            Sys.println(Lang.format("DRAIN i: $1$ index $2$ slot $3$", [i, index, slot]));
            if (index >= 30) {
                count++;
            }
        }
        rollSum = rollSum + power;
        var slot = index % 30;
        index++;
        if (index >= 30) {
            rollSum -= rolling[slot];
        }
        rolling[slot] = power;
        Sys.println(Lang.format("rolling: $1$ $30$", [rolling[0], rolling[29]]));
        Sys.println(Lang.format("rollsum $1$", [rollSum]));
        if (index >= 30) {
            count++;
            var avg = rollSum / 30.0;
            var qavg = avg * avg * avg * avg;  // unrolled for perf
            total += qavg.toLong();
            Sys.println(Lang.format(" returning... $1$", [Math.pow(total / count, 0.25)]));
            value = Math.pow(total / count, 0.25).toNumber();
        }
        return value;
    }
}
