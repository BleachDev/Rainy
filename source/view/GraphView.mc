import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class GraphView extends WatchUi.View {

    public static var page as Number = 0;

    function initialize() {
        View.initialize();

        System.println("Init Graph");
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        var W = dc.getWidth();
        var H = dc.getHeight();
        var XTINY_HEIGHT = H / 13; // XTINY font line height

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(W / 2, H / 26, Graphics.FONT_MEDIUM, page == 0 ? "Today" : page < 3 ? "Tomorrow" : "In " + (page + 1) / 2 + " Days", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);

        var offset = page * 12;
        var mw = W * 0.14; // Margin Width
        var mh = H * 0.25; // Margin Height
        var lw = (W - mw * 2) / 12.0; // Line Width
        var lh = (H - mh * 2) / 9.0; // Line Height
        var cols = 0;
        var startHour = Time.Gregorian.info(data.time, Time.FORMAT_SHORT).hour;
        // Graph Background
        for (var i = 0; i < 13; i++) {
            if (data.hourlySymbol.size() <= offset + i) {
                break;
            }

            cols = i;
            dc.setColor((startHour + offset + i) % 24 == 0 ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(mw + lw * i, mh, mw + lw * i, H - mh);

            // Bottom time text
            if (i % 3 == 0) {
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.drawText(mw + lw * i, H - mh, Graphics.FONT_XTINY, ((startHour + offset + i) % 24).format("%02d"), Graphics.TEXT_JUSTIFY_CENTER);
            }
        }

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < 10; i++) {
            dc.drawLine(mw, mh + lh * i, W - mw - lw * (12 - cols), mh + lh * i);
        }

        var minTemp = data.temperature;
        var maxTemp = data.temperature;
        for (var i = 0; i < data.hourlyTemperature.size(); i++) {
            if (data.hourlyTemperature[i] - 2 < minTemp) {
                minTemp = data.hourlyTemperature[i] - 2;
            }
            if (data.hourlyTemperature[i] + 2 > maxTemp) {
                maxTemp = data.hourlyTemperature[i] + 2;
            }
        }
        var diffTemp = maxTemp - minTemp;
        var rainPercent = data.hourlyRainfall.size() > 0 && data.hourlyRainfall[0] < 0;

        for (var i = 0; i < 12; i++) {
            if (data.hourlySymbol.size() <= offset + i + 1) {
                break;
            }

            // Rain (fillRectancle uses wh instead of xy :troll:)
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            var rain = rainPercent ? -data.hourlyRainfall[offset + i] / 11 : data.hourlyRainfall[offset + i];
            dc.fillRectangle(mw + lw * i, H - mh - lh * rain, lw, lh * rain);

            // Temperature
            var t1 = H - mh - ((data.hourlyTemperature[offset + i].toFloat() - minTemp) / diffTemp) * (H - mh * 2);
            var t2 = H - mh - ((data.hourlyTemperature[offset + i + 1].toFloat() - minTemp) / diffTemp) * (H - mh * 2);
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(mw + lw * i, t1, mw + lw * (i + 1), t2);
        }

        // Left side temperature text
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(mw - 3, mh, Graphics.FONT_XTINY, degrees(maxTemp, data.fahrenheit) + "°", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(mw - 3, mh + (H - mh * 2) * 0.28, Graphics.FONT_XTINY, degrees(maxTemp - diffTemp * 0.33, data.fahrenheit) + "°", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(mw - 3, mh + (H - mh * 2) * 0.58, Graphics.FONT_XTINY, degrees(maxTemp - diffTemp * 0.66, data.fahrenheit) + "°", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(mw - 3, H - mh - XTINY_HEIGHT, Graphics.FONT_XTINY, degrees(minTemp, data.fahrenheit) + "°", Graphics.TEXT_JUSTIFY_RIGHT);

        // Right side rainfall text
        dc.drawText(W - mw + 3, mh, Graphics.FONT_XTINY, rainPercent ? "100%" : "9", Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(W - mw + 3, mh + (H - mh * 2) * 0.28, Graphics.FONT_XTINY, rainPercent ? "60%" : "6", Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(W - mw + 3, mh + (H - mh * 2) * 0.58, Graphics.FONT_XTINY, rainPercent ? "30%" : "3", Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(W - mw + 3, H - mh - XTINY_HEIGHT, Graphics.FONT_XTINY, rainPercent ? "0%" : "0", Graphics.TEXT_JUSTIFY_LEFT);

        // Local Page Indicator
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(W / 2, H - mh + XTINY_HEIGHT, Graphics.FONT_TINY, (page + 1) + "/" + ((data.hourlySymbol.size() - 1) / 12 + 1), Graphics.TEXT_JUSTIFY_CENTER);

        // Page Indicator
        res.indicator.draw(dc, 2);
    }
}
