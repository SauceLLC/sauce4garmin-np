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
    private var lastTime as Number or Null;
    private var rolling as Array<Number> = new Array<Number>[30];
    private var value as String;

    function initialize() {
        SimpleDataField.initialize();
        label = "NP";
        count = 0;
        total = 0l;
        rollSum = 0;
        index = 0;
        value = "--";
        lastTime = null;
        for (var i = 0; i < rolling.size(); i++) {
            rolling[i] = 0;
        }
    }

    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
        if (info.currentPower == null || info.timerTime == null) {
            return value;
        }
        var gap = lastTime != null ? info.timerTime as Number - lastTime : null;
        Sys.println(Lang.format("gap: $1$", [gap]));
        if (gap == 0) {
            // Receiving data but timer is stopped (i.e. not recording)..
            return value;
        }
        lastTime = info.timerTime;

        Sys.println("");
        Sys.println(Lang.format("time: $1$ timer $2$ currentPower $3$", [info.elapsedTime, info.timerTime, info.currentPower]));
        Sys.println(Lang.format("index: $1$ count $2$ total $3$", [index, count, total]));
        // Handle big data gap by draining roll accumulating the remaining values in it...
        if (gap != null) {
            for (var i = 1000; i < gap - 1000 && i < 31000; i += 1000) {
                var slot = index % 30;
                index++;
                Sys.println(Lang.format("DRAIN i: $1$ index $2$ slot $3$", [i, index, slot]));
                if (index >= 30) {
                    count++;
                    rollSum -= rolling[slot];
                    var avg = rollSum / 30.0;
                    var qavg = avg * avg * avg * avg;  // unrolled for perf
                    total += qavg.toLong();
                }
                rolling[slot] = 0;
            }
        }

        rollSum += info.currentPower as Number;
        var slot = index % 30;
        index++;
        if (index >= 30) {
            count++;
            rollSum -= rolling[slot];
            var avg = rollSum / 30.0;
            var qavg = avg * avg * avg * avg;  // unrolled for perf
            total += qavg.toLong();
            value = Lang.format("$1$w", [Math.pow(total / count, 0.25).toNumber()]);
        }
        rolling[slot] = info.currentPower as Number;
        Sys.println(Lang.format("rolling: $1$ $2$ $3$ $4$ $5$...$26$ $27$ $28$ $29$ $30$", rolling as Array));
        Sys.println(Lang.format("rollsum $1$", [rollSum]));
        Sys.println(Lang.format("returning... $1$", [value]));
        return value;
    }
}
