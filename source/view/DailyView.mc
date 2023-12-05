import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class DailyView extends BaseView {

    public static var page as Number = 0;

    function initialize() {
        BaseView.initialize();
    }

    // Update the view
    function onDraw(dc as Dc, W as Number, H as Number, FONT_HEIGHT as Number) as Void {
        if (data.hints & 2 == 0 && NOGLANCE_MODE <= 1) {
            data.hints |= 2;
            WatchUi.pushView(new HintView((NOGLANCE_MODE == 0 ? "Press Select" : "Swipe Left")
                    + " to scroll\nin the Table and\nGraph Forecasts", [ 0 ]), new HintDelegate([ 0 ]), WatchUi.SLIDE_BLINK);
            return;
        }

        var indices = dailyIndices();
        var hour = Time.Gregorian.info(data.time, Time.FORMAT_SHORT).hour;
        var date = Time.Gregorian.info(new Time.Moment(data.time.value() + 86400 * (page + (hour > 18 ? 1 : 0))), Time.FORMAT_MEDIUM);
        drawHeader(dc, W, H, page ? date.day_of_week + " " + date.day + "." : "Daily");

        hour = hour % 6 == 0 ? hour : hour + (6 - (hour % 6));
        var filler = (hour % 24) / 6;
        for (var i = page == 0 ? filler : 0; i < 4; i++) {
            var entry = page * 4 + i - filler;
            if (indices.size() <= entry) {
                break;
            }

            HourlyView.drawTableEntry(dc, W, H, (hour + entry * 6) % 24, indices[entry], i);
        }

        // Local Page Indicator
        dc.drawText(W / 2, H * 0.75 + FONT_HEIGHT, Graphics.FONT_TINY, (page + 1) + "/4", Graphics.TEXT_JUSTIFY_CENTER);

        // Page Indicator
        drawIndicator(dc, 1);
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
