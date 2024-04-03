import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

public var data as FullData?;
public var res as Resources?;
(:glance) public var fahrenheit = System.getDeviceSettings().temperatureUnits == System.UNIT_STATUTE;
(:glance) public var VERSION = "1.6.2";
(:glance) public var IS_GLANCE as Boolean = false;
public var INSTINCT_MODE as Boolean = false; // Whether Instinct circle is present
public var NOGLANCE_MODE as Number = 0; // 0 = Can use arrows, 1 = Can't use arrows, 2 = Can't use arrows or touch
public var LOWTEXT_MODE as Boolean = false; // Whether FONT_HEIGHT should be lower when drawing
public var SQUARE_MODE as Boolean = false; // Whether the watch is rectangle/semiround

(:glance)
class App extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
        
        if (data != null) {
            data.save();
        }
    }

    // Return the initial view of your application here
    function getInitialView() as [ WatchUi.Views ] or [ WatchUi.Views, WatchUi.InputDelegates ] {
        INSTINCT_MODE = "1".equals(WatchUi.loadResource(Rez.Strings.INSTINCT_MODE));
        var ngm = WatchUi.loadResource(Rez.Strings.NOGLANCE_MODE);
        NOGLANCE_MODE = "2".equals(ngm) ? 2 : "1".equals(ngm) ? 1 : 0; // No parseInt!!! :angry:
        LOWTEXT_MODE = "1".equals(WatchUi.loadResource(Rez.Strings.LOWTEXT_MODE));
        SQUARE_MODE = "1".equals(WatchUi.loadResource(Rez.Strings.SQUARE_MODE));

        res = new Resources();
        data = new FullData();
        data.load();

        return [ new SummaryView(), new BaseDelegate() ];
    }

    function getGlanceView() as [ WatchUi.GlanceView ] or [ WatchUi.GlanceView, WatchUi.GlanceViewDelegate ] or Null {
        IS_GLANCE = true;

        var data = new BaseData();
        data.load();

        return [ new AppGlanceView(data) ];
    }
}

// This definetely shouldn't be here but thats a later problem
(:glance)
function generateArrow(centerPoint as [Float, Float], angle as Float, length as Number) as Array<Toybox.Graphics.Point2D> {
    // Map out the coordinates of the arrow
    var coords = [[0, length / 2] as Array<Number>,
                  [(length * 0.07).toNumber(), (-length / 2 * 0.5).toNumber()] as Array<Number>,
                  [(length * 0.3).toNumber(), (-length / 2 * 0.3).toNumber()] as Array<Number>,
                  [0, -length / 2] as Array<Number>,
                  [-(length * 0.3).toNumber(), (-length / 2 * 0.3).toNumber()] as Array<Number>,
                  [-(length * 0.07).toNumber(), (-length / 2 * 0.5).toNumber()] as Array<Number>] as Array<Array<Number>>;
    var result = new Array<Toybox.Graphics.Point2D>[coords.size()];
    var rad = Toybox.Math.toRadians(angle);
    var cos = Toybox.Math.cos(rad);
    var sin = Toybox.Math.sin(rad);

    // Transform the coordinates
    for (var i = 0; i < coords.size(); i++) {
        var x = (coords[i][0] * cos) - (coords[i][1] * sin);
        var y = (coords[i][0] * sin) + (coords[i][1] * cos);

        result[i] = [centerPoint[0] + x + length / 2, centerPoint[1] + y + length / 2];
    }

    return result;
}

(:glance)
function degrees(c as Float) {
    return (fahrenheit ? c * (9.0/5.0) + 32 : c).toNumber();
}

(:glance)
function wind(ms as Float, unit as Number) {
    return (unit == 0 ? ms : unit == 1 ? ms * 3.6 : unit == 2 ? ms * 2.237 : Toybox.Math.round(Toybox.Math.pow(ms / 0.836, 2.0 / 3))).toNumber();
}