import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Math;

class HourlyView extends BaseView {

    public static var page as Number = 0;

    function initialize() {
        BaseView.initialize();
    }

    // Update the view
    function onDraw(dc as Dc, W as Number, H as Number, FONT_HEIGHT as Number) as Void {
        drawHeader(dc, W, H, page ? "In " + (page * 4) + " Hours" : "Hourly");

        var hour = Time.Gregorian.info(data.time, Time.FORMAT_SHORT).hour;
        for (var i = 0; i < 4; i++) {
            var entry = page * 4 + i;
            if (data.hourlyEntries() <= entry) {
                break;
            }

            drawTableEntry(dc, W, H, (hour + entry) % 24, entry, i);
        }

        // Local Page Indicator
        dc.drawText(W / 2, H * 0.75 + FONT_HEIGHT, Graphics.FONT_TINY, (page + 1) + "/3", Graphics.TEXT_JUSTIFY_CENTER);

        // Page Indicator
        drawIndicator(dc, 2);
    }

    static function drawTableEntry(dc as Dc, W as Number, H as Number, hour as Number or String, dataIndex as Number?, entry as Number) {
        var mh = H * 0.2;
        var lh = H / 6.75;
        var offset = entry * lh;
        var insLine = INSTINCT_MODE && entry == 0;

        // Time
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(W / 15, mh + lh / 3 + offset, Graphics.FONT_XTINY, hour instanceof String ? hour : hour.format("%02d"), Graphics.TEXT_JUSTIFY_LEFT);
        if (dataIndex == null) {
            return;
        }

        // Temperature
        dc.drawBitmap(W / 7, mh + offset, res.getSymbol(data.symbols[dataIndex]));
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(W / 7 + 47, mh + lh / 10 + offset, Graphics.FONT_MEDIUM, degrees(data.temperatures[dataIndex]) + "°", Graphics.TEXT_JUSTIFY_LEFT);

        // Rainfall
        var rain = data.rainfall[dataIndex];
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(insLine ? W * 0.82 : W / 1.55,
                    insLine ? H * 0.05 : mh + lh / 10 + offset, Graphics.FONT_MEDIUM,
                    rain.format(Math.round(rain) == rain ? "%d" : "%.1f"), Graphics.TEXT_JUSTIFY_CENTER);

        // Wind
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(insLine ? W * 0.81 : W - lh * 0.9,
                    insLine ? H * 0.16 : mh + lh / 10 + offset,
                    Graphics.FONT_MEDIUM, wind(data.windSpeeds[dataIndex], data.windUnits), Graphics.TEXT_JUSTIFY_RIGHT);
        dc.fillPolygon(generateArrow([ insLine ? W * 0.87 : W - lh / 2, insLine ? H * 0.25 : mh + lh / 1.75 + offset ],
                       data.windDirections[dataIndex] + 180, (lh / 1.9).toNumber()));
    }
}
