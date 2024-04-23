import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

(:glance)
class AppGlanceView extends WatchUi.GlanceView {

    private var data as BaseData;

    function initialize(data as BaseData) {
        GlanceView.initialize();

        System.println("Init Glance");
        self.data = data;
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        GlanceView.onUpdate(dc);

        var W = dc.getWidth();
        var H = dc.getHeight();
        var loaded = data.temperatures.size() > 0;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(0, H * 0.15, Graphics.FONT_GLANCE, data.location, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(0, H * 0.4, Graphics.FONT_GLANCE_NUMBER, (loaded ? degrees(data.temperatures[0], data.tempUnits) : "--") + "°", Graphics.TEXT_JUSTIFY_LEFT);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(generateArrow([ W * 0.22, H * 0.52 ], loaded ? data.windDirections[0] + 180 : 0, W / 8));
        dc.drawText(W * 0.37, H * 0.4, Graphics.FONT_GLANCE_NUMBER, loaded ? wind(data.windSpeeds[0], data.windUnits) : "--", Graphics.TEXT_JUSTIFY_LEFT);

        var mw = W * 0.55; // Rain chart width margin (left)
        var mh = H / 5.5; // Rain chart height margin (bottom)
        var lh = (H - mh * 3) / 3; // Rain chart line height
        var chartWidth = W - mw;

        var rainPrimary = data.nowRainfall != null && data.nowRainfall.size() > 0;
        var rainBackup = data.rainfall.size() >= 6;

        if (rainPrimary || rainBackup) {
            var rainCount = rainPrimary ? data.nowRainfall.size() : rainBackup ? 6 : 0;
            var rainPolygon = new [rainCount + 2];
            rainPolygon[0] = [ mw + chartWidth, H - mh ];
            rainPolygon[1] = [ mw, H - mh ];
            for (var i = 0; i < rainCount; i++) {
                var r = rainPrimary ? data.nowRainfall[i] : data.rainfall[i];
                rainPolygon[i + 2] = [ mw + (chartWidth / (rainCount - 1)) * i, H - mh - (r <= 0 ? 0 : r > 5 ? lh * 3 : ((r + 0.3) * lh * 0.6)) ];
            }

            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            dc.fillPolygon(rainPolygon);

            if (!rainPrimary && data.nowRainfall != null) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(W, H * 0.2, Graphics.FONT_GLANCE, "6hr", Graphics.TEXT_JUSTIFY_RIGHT);
            }
        } else {
            dc.drawText(W * 0.8, H * 0.3, Graphics.FONT_GLANCE, "Rain\nUnavailable", Graphics.TEXT_JUSTIFY_CENTER);
        }
    }
}
