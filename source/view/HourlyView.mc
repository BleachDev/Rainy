import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class HourlyView extends BaseView {

    public static var page as Number = 0;

    function initialize() {
        BaseView.initialize();

        System.println("Init Hourly");
    }

    // Update the view
    function onDraw(dc as Dc, W as Number, H as Number, FONT_HEIGHT as Number) as Void {
        if (data.hints & 2 == 0) {
            data.hints |= 2;
            WatchUi.pushView(new HintView("Press Select to scroll\nin the Hourly and\nGraph Forecasts", [ 0 ]), new HintDelegate([ 0 ]), WatchUi.SLIDE_BLINK);
            return;
        }

        drawHeader(dc, W, H, page ? "In " + (page * 3) + " Hours" : "Now");

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
            dc.drawText(lh / 4 + 50 + (W - 50 - lh) / 2, mh + lh / 6 + offset, Graphics.FONT_MEDIUM,
                rain == rain.toNumber() ? rain.toNumber() : rain.format("%.1f"), Graphics.TEXT_JUSTIFY_CENTER);

            // Wind
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(W - lh * 0.9, mh + lh / 6 + offset, Graphics.FONT_MEDIUM, data.hourlyWindSpeed[entry].format("%d"), Graphics.TEXT_JUSTIFY_RIGHT);
            dc.fillPolygon(generateArrow([ W - lh / 2, mh + lh / 2 + offset ], data.hourlyWindDirection[entry] + 180, lh.toNumber() / 2));

            // Header
            dc.drawLine(FONT_HEIGHT, mh + offset, W / 2 - FONT_HEIGHT * 1.25, mh + offset);
            dc.drawLine(W / 2 + FONT_HEIGHT * 1.25, mh + offset, W - FONT_HEIGHT, mh + offset);
            dc.drawText(W / 2, mh - FONT_HEIGHT / 2 + offset, Graphics.FONT_XTINY,
                ((time.hour + entry) % 24).format("%02d") + ":" + time.min.format("%02d"), Graphics.TEXT_JUSTIFY_CENTER);
        }

        dc.drawLine(FONT_HEIGHT, mh + 3 * lh, W - FONT_HEIGHT, mh + 3 * lh);
        // Local Page Indicator
        dc.drawText(W / 2, H * 0.75 + FONT_HEIGHT, Graphics.FONT_TINY, (page + 1) + "/4", Graphics.TEXT_JUSTIFY_CENTER);

        // Page Indicator
        res.indicator.draw(dc, 1);
    }
}
