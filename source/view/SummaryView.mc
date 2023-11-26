import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class SummaryView extends BaseView {

    function initialize() {
        BaseView.initialize();

        System.println("Init Summary");
    }

    // Update the view
    function onDraw(dc as Dc, W as Number, H as Number, FONT_HEIGHT as Number) as Void {
        if (data.position == null) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(W / 2, H / 8.2, Graphics.FONT_MEDIUM, "Updating GPS\nLocation..", Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(W / 2, H / 2.1, Graphics.FONT_TINY, "Or press MENU\nto manually select\na location.", Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        if (data.hourlySymbol.size() < 1) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(W / 2, H / 6.5, Graphics.FONT_LARGE, "Loading..", Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(W / 2, H / 2.6, Graphics.FONT_TINY, "Phone Bluetooth\nconnection required\nto load Yr.", Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        if (data.hints & 1 == 0) {
            data.hints |= 1;
            WatchUi.pushView(new HintView("Press the Select\nor Menu button\nto open Yr settings.", [ 0, 1 ]), new HintDelegate([ 0, 1 ]), WatchUi.SLIDE_BLINK);
            return;
        }

        // Location
        drawHeader(dc, W, H, data.location);

        // Temperature
        var sumM = H / 13; // Summary margin
        dc.drawBitmap(sumM, sumM * 2.7, res.getSymbol(data.hourlySymbol.size() == 0 ? 2018941991 : data.hourlySymbol[0]));

        dc.drawText(sumM + 50, sumM * 2.5, Graphics.FONT_NUMBER_MILD, degrees(data.hourlyTemperature[0], data.fahrenheit) + "°", Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        var apTemp = calcApparentTemperature(data.hourlyTemperature[0], data.hourlyHumidity[0], data.hourlyWindSpeed[0]);
        dc.drawText(sumM, sumM * 5, Graphics.FONT_XTINY, "Feels Like " + degrees(apTemp, data.fahrenheit) + "°", Graphics.TEXT_JUSTIFY_LEFT);

        // Wind
        dc.drawText(W - sumM * 3, sumM * 2.5, Graphics.FONT_NUMBER_MILD, data.hourlyWindSpeed[0].format("%d"), Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(W - sumM, sumM * 5, Graphics.FONT_XTINY, "(m/s)", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.fillPolygon(generateArrow([ W - sumM * 1.9, sumM * 4 ], data.hourlyWindDirection[0] + 180, (sumM * 1.6).toNumber()));
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);

        // Rain chart
        var mw = W / 8.66; // Rain chart width margin
        var mh = H / 7.42; // Rain chart height margin
        var lh = H / 13; // Rain chart line height
        var chartWidth = W - mw * 2;
        var rainBackup = data.hourlyRainfall.size() >= 6;

        if (data.nowRainfall != null) {
            var rainPoints = new [data.nowRainfall.size() + 2];
            rainPoints[0] = [ mw, H - mh ];
            rainPoints[data.nowRainfall.size() + 1] = [ mw + (chartWidth / 18) * (data.nowRainfall.size() - 1), H - mh ];
            for (var i = 0; i < data.nowRainfall.size(); i++) {
                rainPoints[i + 1] = [ mw + (chartWidth / 18) * i,
                                      H - mh - (data.nowRainfall[i] <= 0 ? 0 : data.nowRainfall[i] > 5 ? lh * 3.25 : ((data.nowRainfall[i] + 0.3) * (lh * 0.6))) ];
            }

            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            dc.fillPolygon(rainPoints);
        } else if (rainBackup) {
            var rainPoints = new [8];
            rainPoints[0] = [ mw, H - mh ];
            rainPoints[7] = [ mw + chartWidth, H - mh ];
            for (var i = 0; i < 6; i++) {
                rainPoints[i + 1] = [ mw + (chartWidth / 6) * i,
                                      H - mh - (data.hourlyRainfall[i] <= 0 ? 0 : data.hourlyRainfall[i] > 5 ? lh * 3.25 : ((data.hourlyRainfall[i] + 0.3) * (lh * 0.6))) ];
            }

            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            dc.fillPolygon(rainPoints);
        }

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(W * 0.27, H - mh + 2, Graphics.FONT_XTINY, "Now", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(W / 2, H - mh + 2, Graphics.FONT_XTINY, data.nowRainfall == null && rainBackup ? "3hr" : "45", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(W * 0.73, H - mh + 2, Graphics.FONT_XTINY, data.nowRainfall == null && rainBackup ? "6hr" : "90", Graphics.TEXT_JUSTIFY_CENTER);

        dc.drawLine(mw, H - mh, W - mw, H - mh);
        dc.setColor(INSTINCT_MODE ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(mw, H - mh - lh, W - mw, H - mh - lh);
        dc.drawLine(mw, H - mh - lh * 2, W - mw, H - mh - lh * 2);
        dc.drawLine(mw, H - mh - lh * 3, W - mw, H - mh - lh * 3);
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(W / 2, H - mh - lh * 3 - FONT_HEIGHT, Graphics.FONT_XTINY,
            data.nowRainfall != null ? "Rainfall next 90 min." : rainBackup ? "Rainfall next 6 hr." : "90 Minute Rainfall Unavailable.", Graphics.TEXT_JUSTIFY_CENTER);

        // Page Indicator
        res.indicator.draw(dc, 0);
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
