import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class DailyView extends BaseView {

    function initialize() {
        BaseView.initialize(4);
    }

    // Update the view
    function onDraw(dc as Dc, W as Number, H as Number, FONT_HEIGHT as Number) as Void {
        if (data.hints & 2 == 0 && NOGLANCE_MODE <= 1) {
            data.hints |= 2;
            Storage.setValue("hints", data.hints);
            WatchUi.pushView(new HintView((NOGLANCE_MODE == 0 ? "Press Select" : "Swipe Left")
                    + " to scroll\non pages with\nmultiple slides.", [ 0 ]), new HintDelegate([ 0 ]), WatchUi.SLIDE_BLINK);
            return;
        }

        var indices = dailyIndices();
        var realHour = Time.Gregorian.info(data.time, Time.FORMAT_SHORT).hour;
        var hour = realHour % 6 == 0 ? realHour : realHour + (6 - (realHour % 6));
        var date = Time.Gregorian.info(new Time.Moment(data.time.value() + 86400 * (page + (realHour > 18 ? 1 : 0))), Time.FORMAT_MEDIUM);
        drawHeader(dc, W, H, page ? date.day_of_week + " " + date.day + "." : "Daily");

        var filler = (hour % 24) / 6;
        for (var i = 0; i < 4; i++) {
            var entry = page * 4 + i - filler;
            if (indices.size() <= entry) {
                break;
            }

            if (entry == -1 && realHour % 6 != 0) {
                HourlyView.drawTableEntry(dc, W, H, realHour, indices[0], i);
            } else if (entry <= -1) {
                HourlyView.drawTableEntry(dc, W, H, "--", null, i);
            } else {
                HourlyView.drawTableEntry(dc, W, H, (hour + entry * 6) % 24, indices[entry], i);
            }
        }

        // Local Page Indicator
        dc.drawText(W / 2, H * 0.75 + FONT_HEIGHT, Graphics.FONT_TINY, (page + 1) + "/" + pages, Graphics.TEXT_JUSTIFY_CENTER);

        // Page Indicator
        drawIndicator(dc, data.pageOrder ? 3 : 1);
    }

    function dailyIndices() as Array<Number> {
        var hour = Time.Gregorian.info(data.time, Time.FORMAT_SHORT).hour;
        var entries = [];
        for (var i = 0; i < data.symbols.size(); i++) {
            if ((hour + i) % 6 == 0 || i >= data.hours) {
                entries.add(i);
            }
        }

        return entries;
    }
}
