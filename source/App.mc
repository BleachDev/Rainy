import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

public var data as YrData?;
public var res as YrResources?;

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
        if (data != null) {
            data.save();
        }
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        System.println("getInitialView");
        res = new YrResources();
        data = new YrData();
        data.load();

        var pos = Position.getInfo().position.toDegrees();
        if (pos[0] > -90 && pos[0] < 90 && pos[1] > -180 && pos[1] < 180) {
            data.update(pos);
        } else if (data.position != null) {
            data.update(data.position);
        } else if (Weather.getCurrentConditions() != null) {
            data.update(Weather.getCurrentConditions().observationLocationPosition.toDegrees());
        }
        
        Position.enableLocationEvents(Position.LOCATION_ONE_SHOT, data.method(:updateCB));

        return [ new SummaryView(), new SummaryDelegate() ] as Array<Views or InputDelegates>;
    }

    function getGlanceView() as Array<GlanceView>? {
        var data = new YrGlanceData();
        data.load();

        var pos = Position.getInfo().position.toDegrees();
        if (pos[0] > -90 && pos[0] < 90 && pos[1] > -180 && pos[1] < 180) {
            data.update(pos);
        } else if (data.position != null) {
            data.update(data.position);
        } else if (Weather.getCurrentConditions() != null) {
            data.update(Weather.getCurrentConditions().observationLocationPosition.toDegrees());
        }

        return [ new YrGlanceView(data) ];
    }
}

// This definetely shouldn't be here but thats a later problem
(:glance)
function generateArrow(centerPoint as Array<Number>, angle as Float, length as Number) as Array<Array<Float>> {
    // Map out the coordinates of the arrow
    var coords = [[0, length / 2] as Array<Number>,
                  [(length * 0.07).toNumber(), (-length / 2 * 0.5).toNumber()] as Array<Number>,
                  [(length * 0.3).toNumber(), (-length / 2 * 0.3).toNumber()] as Array<Number>,
                  [0, -length / 2] as Array<Number>,
                  [-(length * 0.3).toNumber(), (-length / 2 * 0.3).toNumber()] as Array<Number>,
                  [-(length * 0.07).toNumber(), (-length / 2 * 0.5).toNumber()] as Array<Number>] as Array<Array<Number>>;
    var result = new Array<Array<Float>>[coords.size()];
    var rad = Toybox.Math.toRadians(angle);
    var cos = Toybox.Math.cos(rad);
    var sin = Toybox.Math.sin(rad);

    // Transform the coordinates
    for (var i = 0; i < coords.size(); i++) {
        var x = (coords[i][0] * cos) - (coords[i][1] * sin) + 0.5;
        var y = (coords[i][0] * sin) + (coords[i][1] * cos) + 0.5;

        result[i] = [centerPoint[0] + x, centerPoint[1] + y] as Array<Float>;
    }

    return result;
}

(:glance)
function degrees(c as Float, fahrenheit as Boolean) {
    return (fahrenheit ? c * (9.0/5.0) + 32 : c).toNumber();
}