import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class WaterView extends WatchUi.View {

    function initialize() {
        View.initialize();

        System.println("Init Water");
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        var W = dc.getWidth();
        var H = dc.getHeight();
        var mw = W * 0.085; // Margin Width
        var mh = H * 0.22; // Margin Height

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(W / 2, H / 17, Graphics.FONT_MEDIUM, "Water Temps", Graphics.TEXT_JUSTIFY_CENTER);
        if (data.waterNames.size() == 0) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(W / 2, H / 3, Graphics.FONT_TINY, "No Nearby Water\n Temperatures Found.\n(Norway Only)", Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            for (var i = 0; i < data.waterNames.size() && i < 3; i++) {
                var offset = mh + i * (H / 4.5);
                var small = data.waterNames[i].length() > 13;
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(mw, offset, small ? Graphics.FONT_XTINY : Graphics.FONT_TINY, data.waterNames[i], Graphics.TEXT_JUSTIFY_LEFT);

                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.drawText(W - mw - H / 4.25, offset + H / (small ? 11 : 10), Graphics.FONT_XTINY,
                    (data.waterDistances[i] / 1000.0).format(data.waterDistances[i] > 10000 ? "%d" : "%.1f") + "km", Graphics.TEXT_JUSTIFY_RIGHT);

                var time = Time.Gregorian.info(data.waterTimestamps[i], Time.FORMAT_MEDIUM);
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.drawText(mw, offset + H / (small ? 11 : 10), Graphics.FONT_XTINY,
                    time.month + " " + time.day.format("%02d") + " " + time.hour.format("%02d") + ":" + time.min.format("%02d"), Graphics.TEXT_JUSTIFY_LEFT);


                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
                dc.drawText(W - mw * 0.8, offset + H / 40, Graphics.FONT_SMALL, 
                    (data.fahrenheit ? degrees(data.waterTemperatures[i], true) : data.waterTemperatures[i].format("%.1f")) + "°", Graphics.TEXT_JUSTIFY_RIGHT);
            }
        }

        // Page Indicator
        res.indicator.draw(dc, 4);
    }
}
