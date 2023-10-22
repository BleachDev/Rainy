import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class SummaryView extends WatchUi.View {

    //private var localIndicator = new LocalPageIndicator(1);

    function initialize() {
        View.initialize();

        System.println("Init Summary");
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        var W = dc.getWidth();
        var H = dc.getHeight();
        var XTINY_HEIGHT = H / 13; // XTINY font line height

        // Location
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(W / 2,
            data.location.length() > 15 ? XTINY_HEIGHT : XTINY_HEIGHT * 0.75,
            data.location.length() > 15 ? Graphics.FONT_TINY :
            data.location.length() > 12 ? Graphics.FONT_SMALL : Graphics.FONT_MEDIUM, data.location, Graphics.TEXT_JUSTIFY_CENTER);

        // Temperature
        dc.drawBitmap(XTINY_HEIGHT, XTINY_HEIGHT * 2.7, res.getSymbol(data.hourlySymbol.size() == 0 ? 2018941991 : data.hourlySymbol[0]));

        dc.drawText(XTINY_HEIGHT + 50, XTINY_HEIGHT * 2.5, Graphics.FONT_NUMBER_MILD, degrees(data.temperature, data.fahrenheit) + "°", Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        var apTemp = calcApparentTemperature(data.temperature, data.humidity, data.windSpeed);
        dc.drawText(XTINY_HEIGHT, XTINY_HEIGHT * 5, Graphics.FONT_XTINY, "Feels Like " + degrees(apTemp, data.fahrenheit) + "°", Graphics.TEXT_JUSTIFY_LEFT);

        // Wind
        dc.drawText(W - XTINY_HEIGHT * 3, XTINY_HEIGHT * 2.5, Graphics.FONT_NUMBER_MILD, data.windSpeed.format("%d"), Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(W - XTINY_HEIGHT, XTINY_HEIGHT * 5, Graphics.FONT_XTINY, "(m/s)", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.fillPolygon(generateArrow([ W - XTINY_HEIGHT * 1.9, XTINY_HEIGHT * 4 ], data.windDirection + 180, (XTINY_HEIGHT * 1.6).toNumber()));
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);

        // Rain chart
        var mw = H / 8.66; // Rain chart width margin
        var mh = H / 7.42; // Rain chart height margin
        var lh = H / 13; // Rain chart line height
        var chartWidth = W - 60;

        if (data.rainfall != null) {
            var rainPoints = new [data.rainfall.size() + 2];
            rainPoints[0] = [ mw, H - mh ];
            rainPoints[data.rainfall.size() + 1] = [ mw + (chartWidth / 18) * (data.rainfall.size() - 1), H - mh ];
            for (var i = 0; i < data.rainfall.size(); i++) {
                rainPoints[i + 1] = [ mw + (chartWidth / 18) * i, H - mh - (data.rainfall[i] <= 0 ? 0 : data.rainfall[i] > 5 ? lh * 3.25 : ((data.rainfall[i] + 0.3) * (lh * 0.6))) ];
            }

            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            dc.fillPolygon(rainPoints);
        }

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(W * 0.27, H - mh + 2, Graphics.FONT_XTINY, "Now", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(W / 2, H - mh + 2, Graphics.FONT_XTINY, "45", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(W * 0.73, H - mh + 2, Graphics.FONT_XTINY, "90", Graphics.TEXT_JUSTIFY_CENTER);

        dc.drawLine(mw, H - mh, W - mw, H - mh);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(mw, H - mh - lh, W - mw, H - mh - lh);
        dc.drawLine(mw, H - mh - lh * 2, W - mw, H - mh - lh * 2);
        dc.drawLine(mw, H - mh - lh * 3, W - mw, H - mh - lh * 3);
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(W / 2, H - mh - lh * 3 - XTINY_HEIGHT, Graphics.FONT_XTINY, data.rainfall == null ? "90 min Rainfall Unavailable\n(Nordics Only)" : "Rainfall next 90 min.", Graphics.TEXT_JUSTIFY_CENTER);

        // Page Indicator
        res.indicator.draw(dc, 0);
        //localIndicator.draw(dc, 0);
    }

    // thanks Mr. Gpt (may or may not actually calculate the right values)
    function calcApparentTemperature(temp as Float, humidity as Float, wind as Float) as Float {
        if (temp > 27.0) {
            // Calculate Heat Index
            var tempFahrenheit = (temp * 9 / 5) + 32;
            var heatIndex = 0.5 * (tempFahrenheit + 61.0 + ((tempFahrenheit - 68.0) * 1.2) + (humidity * 0.094));
            
            // Ensure the result is in Celsius
            return (heatIndex - 32) * 5 / 9;
        } else if (temp < 10.0) {
            var windMph = wind * 2.237; // meters/s to miles/h
            var windChill = 13.12 + 0.6215 * temp - 11.37 * Math.pow(windMph, 0.16) + 0.3965 * temp * Math.pow(windMph, 0.16);
            
            return windChill;
        }

        return temp;
    }
}
