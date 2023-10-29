import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

(:glance)
class YrGlanceView extends WatchUi.GlanceView {

    private var data as YrGlanceData;

    function initialize(data as YrGlanceData) {
        GlanceView.initialize();

        System.println("Init Glance");
        self.data = data;
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        var W = dc.getWidth();
        var H = dc.getHeight();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(0, H * 0.15, Graphics.FONT_GLANCE, data.location.toUpper(), Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(0, H * 0.4, Graphics.FONT_GLANCE_NUMBER, degrees(data.temperature, data.fahrenheit) + "°", Graphics.TEXT_JUSTIFY_LEFT);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(generateArrow([ W * 0.28, H * 0.65 ], data.windDirection + 180, H / 4));
        dc.drawText(W * 0.35, H * 0.4, Graphics.FONT_GLANCE_NUMBER, data.windSpeed.format("%d"), Graphics.TEXT_JUSTIFY_LEFT);

        var mw = W * 0.55; // Rain chart width margin (left)
        var mh = H / 5.5; // Rain chart height margin (bottom)
        var lh = (H - mh * 3) / 3; // Rain chart line height
        var chartWidth = W - mw;
        if (data.rainfall != null) {
            var rainPoints = new [data.rainfall.size() + 2];
            rainPoints[0] = [ mw, H - mh ];
            rainPoints[data.rainfall.size() + 1] = [ mw + chartWidth, H - mh ];
            for (var i = 0; i < data.rainfall.size(); i++) {
                rainPoints[i + 1] = [ mw + (chartWidth / 18) * i,
                                      H - mh - (data.rainfall[i] <= 0 ? 0 : data.rainfall[i] > 5 ? lh * 3 : ((data.rainfall[i] + 0.3) * (lh * 0.6))) ];
            }

            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            dc.fillPolygon(rainPoints);
        } else if (Weather.getHourlyForecast() != null && Weather.getHourlyForecast().size() >= 6) {
            var forecast = Weather.getHourlyForecast();
            var rainPoints = new [8];
            rainPoints[0] = [ mw, H - mh ];
            rainPoints[7] = [ mw + chartWidth, H - mh ];
            for (var i = 0; i < 6; i++) {
                rainPoints[i + 1] = [ mw + (chartWidth / 6) * i,
                                      H - mh - (lh * 3) * (forecast[i].precipitationChance / 100.0) ];
            }

            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            dc.fillPolygon(rainPoints);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(W, H * 0.2, Graphics.FONT_GLANCE, "6hr Rain %", Graphics.TEXT_JUSTIFY_RIGHT);
        } else {
            dc.drawText(W * 0.8, H * 0.3, Graphics.FONT_GLANCE, "Rain\nUnavailable", Graphics.TEXT_JUSTIFY_CENTER);
        }
    }
}
