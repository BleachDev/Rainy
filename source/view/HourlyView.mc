import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class HourlyView extends WatchUi.View {

    public static var page as Number = 0;

    function initialize() {
        View.initialize();

        System.println("Init Hourly");
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        if (data.hints & 2 == 0) {
            data.hints |= 2;
            WatchUi.pushView(new HintView("Press Select to scroll\nin the Hourly and\nChart Forecasts", [ 0 ]), new HintDelegate([ 0 ]), WatchUi.SLIDE_BLINK);
        }

        var W = dc.getWidth();
        var H = dc.getHeight();
        var XTINY_HEIGHT = H / 13; // XTINY font line height

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(W / 2, H / 26, Graphics.FONT_MEDIUM, page ? "In " + (page * 3) + " Hours" : "Now", Graphics.TEXT_JUSTIFY_CENTER);

        var mh = H * 0.23;
        var lh = H / 5.2;
        var time = Time.Gregorian.info(data.time, Time.FORMAT_SHORT);
        for (var i = 0; i < 3; i++) {
            var entry = page * 3 + i;
            if (data.hourlySymbol.size() <= entry) {
                break;
            }

            var offset = i * lh;
            // Temperature
            dc.drawBitmap(lh / 4, mh + lh / 20 + offset, res.getSymbol(data.hourlySymbol[entry]));
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(lh / 4 + 50, mh + lh / 6 + offset, Graphics.FONT_MEDIUM, degrees(data.hourlyTemperature[entry], data.fahrenheit) + "°", Graphics.TEXT_JUSTIFY_LEFT);

            // Rainfall
            var rain = data.hourlyRainfall[entry];
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(lh + (W - lh * 2) / 2, mh + lh / 6 + offset, Graphics.FONT_MEDIUM,
                rain == rain.toNumber() ? rain.toNumber() : rain.format("%.1f"), Graphics.TEXT_JUSTIFY_LEFT);

            // Wind
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(W - lh * 0.9, mh + lh / 6 + offset, Graphics.FONT_MEDIUM, data.hourlyWindSpeed[entry].format("%d"), Graphics.TEXT_JUSTIFY_RIGHT);
            dc.fillPolygon(generateArrow([ W - lh / 2, mh + lh / 2 + offset ], data.hourlyWindDirection[entry] + 180, lh.toNumber() / 2));

            // Header
            dc.drawLine(XTINY_HEIGHT, mh + offset, W / 2 - XTINY_HEIGHT * 1.25, mh + offset);
            dc.drawLine(W / 2 + XTINY_HEIGHT * 1.25, mh + offset, W - XTINY_HEIGHT, mh + offset);
            dc.drawText(W / 2, mh - XTINY_HEIGHT / 2 + offset, Graphics.FONT_XTINY,
                ((time.hour + entry) % 24).format("%02d") + ":" + time.min.format("%02d"), Graphics.TEXT_JUSTIFY_CENTER);
        }

        dc.drawLine(XTINY_HEIGHT, mh + 3 * lh, W - XTINY_HEIGHT, mh + 3 * lh);
        // Local Page Indicator
        dc.drawText(W / 2, mh + XTINY_HEIGHT / 20 + 3 * lh, Graphics.FONT_TINY, (page + 1) + "/4", Graphics.TEXT_JUSTIFY_CENTER);

        // Page Indicator
        res.indicator.draw(dc, 1);
    }
}
