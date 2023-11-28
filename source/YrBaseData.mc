import Toybox.Communications;
import Toybox.Position;
import Toybox.Lang;
import Toybox.Application;
import Toybox.Time;

(:glance)
class YrBaseData {

    public var autoLocation         as Boolean = true;
    public var fahrenheit           as Boolean = System.getDeviceSettings().temperatureUnits == System.UNIT_STATUTE;

    public var position             as Array<Double>?;
    public var location             as String = "..";
    public var time                 as Moment = Time.now();
    // Forecast
    public var nowRainfall          as Array<Float>? = null; // Null or list of next 90 mins of rain
    public var hourlyTemperature    as Array<Float> = [];
    public var hourlyWindSpeed      as Array<Float> = [];
    public var hourlyWindDirection  as Array<Float> = [];
    public var hourlyRainfall       as Array<Float> = [];
    public var hourlyHumidity       as Array<Float> = [];
    public var hourlySymbol         as Array<Number> = [];

    function update(coords as Array<Double>) as Void {
        System.println("Refreshing, " + coords);
        position = coords;

        syncData();

        var limit = IS_GLANCE ? 20 : System.getSystemStats().totalMemory < 80000 ? 24 : 36;
        request("https://api.bleach.dev/weather/forecast?limit=" + limit + "&lat=" + position[0] + "&lon=" + position[1], method(:fetchForecastData));
        request("https://api.bleach.dev/weather/search?limit=1&lat=" + position[0] + "&lon=" + position[1], method(:fetchGeoData));
    }

    // Request order
    // -> Forecast -> (F)Aurora
    //            \-> (F)Water
    // -> Geo
    function request(url, callback) {
        Communications.makeWebRequest(url, null, {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :headers => { "User-Agent" => "GarminYr/" + VERSION + " me@bleach.dev" },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        }, callback);
    }

    function save() {
        Storage.setValue("autoLocation", autoLocation);
        Storage.setValue("fahrenheit", fahrenheit);

        Storage.setValue("geo", position);
        Storage.setValue("location", location);
        Storage.setValue("time", time.value());

        Storage.setValue("nowRainfall", nowRainfall);
        Storage.setValue("hourlyTemperature", hourlyTemperature);
        Storage.setValue("hourlyWindSpeed", hourlyWindSpeed);
        Storage.setValue("hourlyWindDirection", hourlyWindDirection);
        Storage.setValue("hourlyRainfall", hourlyRainfall);
        Storage.setValue("hourlyHumidity", hourlyHumidity);
        Storage.setValue("hourlySymbol", hourlySymbol);
    }

    function load() {
        if (Storage.getValue("autoLocation") != null) { autoLocation = Storage.getValue("autoLocation"); }
        if (Storage.getValue("fahrenheit") != null) { fahrenheit = Storage.getValue("fahrenheit"); }

        if (Storage.getValue("geo") != null) { position = Storage.getValue("geo"); }
        if (Storage.getValue("location") != null) { location = Storage.getValue("location"); }
        if (Storage.getValue("time") != null) { time = new Moment(Storage.getValue("time")); }

        if (Storage.getValue("nowRainfall") != null) { nowRainfall = Storage.getValue("nowRainfall"); }
        if (Storage.getValue("hourlyTemperature") != null) { hourlyTemperature = Storage.getValue("hourlyTemperature"); }
        if (Storage.getValue("hourlyWindSpeed") != null) { hourlyWindSpeed = Storage.getValue("hourlyWindSpeed"); }
        if (Storage.getValue("hourlyWindDirection") != null) { hourlyWindDirection = Storage.getValue("hourlyWindDirection"); }
        if (Storage.getValue("hourlyRainfall") != null) { hourlyRainfall = Storage.getValue("hourlyRainfall"); }
        if (Storage.getValue("hourlyHumidity") != null) { hourlyHumidity = Storage.getValue("hourlyHumidity"); }
        if (Storage.getValue("hourlySymbol") != null) { hourlySymbol = Storage.getValue("hourlySymbol"); }
        WatchUi.requestUpdate();

        // Update if we have a valid position
        var pos = Position.getInfo().position.toDegrees();
        if (autoLocation && pos[0] > -90 && pos[0] < 90 && pos[1] > -180 && pos[1] < 180) {
            update(pos);
        } else if (autoLocation && Activity.getActivityInfo() != null && Activity.getActivityInfo().currentLocation != null) {
            update(Activity.getActivityInfo().currentLocation.toDegrees());
        } else if (autoLocation && Toybox has :Weather
                    && Weather.getCurrentConditions() != null && Weather.getCurrentConditions().observationLocationPosition != null) {
            update(Weather.getCurrentConditions().observationLocationPosition.toDegrees());
        } else if (position != null) {
            update(position);
        }
    }

    function syncData() {
        var nowTime = Time.now().value();
        for (var i = 0; time.value() + 3600 < nowTime && i < 20; i++) {
            nowRainfall = null; // No more 90 minute rain
            if (hourlyTemperature.size() > 0) { hourlyTemperature.remove(hourlyTemperature[0]); }
            if (hourlyWindSpeed.size() > 0) { hourlyWindSpeed.remove(hourlyWindSpeed[0]); }
            if (hourlyWindDirection.size() > 0) { hourlyWindDirection.remove(hourlyWindDirection[0]); }
            if (hourlyRainfall.size() > 0) { hourlyRainfall.remove(hourlyRainfall[0]); }
            if (hourlyHumidity.size() > 0) { hourlyHumidity.remove(hourlyHumidity[0]); }
            if (hourlySymbol.size() > 0) { hourlySymbol.remove(hourlySymbol[0]); }
            time = new Moment(time.value() + 3600);
        }
    }

    // Fetching Methods

    function fetchForecastData(responseCode as Number, data as Dictionary?) as Boolean {
        System.println("FC " + responseCode);
        if (responseCode != 200 || data == null || data["forecast"] == null) {
            return false;
        }

        var forecastData = data["forecast"] as Dictionary;

        var hours = forecastData.size();
        hourlyTemperature = new [hours];
        hourlyWindSpeed = new [hours];
        hourlyWindDirection = new [hours];
        hourlyRainfall = new [hours];
        hourlyHumidity = new [hours];
        hourlySymbol = new [hours];
        for (var i = 0; i < hours; i++) {
            var hour = forecastData[i];
            hourlyTemperature[i] = hour["air_temperature"];
            hourlyWindSpeed[i] = hour["wind_speed"];
            hourlyWindDirection[i] = hour["wind_from_direction"];
            hourlyRainfall[i] = hour["precipitation_amount"];
            hourlyHumidity[i] = hour["relative_humidity"];
            hourlySymbol[i] = hour["symbol_code"].hashCode();
        }

        if (data["nowcast"] != null) {
            var nowData = data["nowcast"] as Dictionary;
            nowRainfall = new [nowData.size() < 19 ? nowData.size() : 19];
            for (var i = 0; i < nowRainfall.size(); i++) {
                nowRainfall[i] = nowData[i];
            }
        }

        if (IS_GLANCE) {
            WatchUi.requestUpdate();
            save();
        }

        return true;
    }

    function fetchGeoData(responseCode as Number, data as Dictionary?) as Boolean {
        System.println("GEO " + responseCode);
        if (responseCode != 200 || data == null || data.size() == 0) {
            System.println("GEO EXIT " + data);
            return false;
        }

        location = data[0]["name"];

        if (IS_GLANCE) {
            WatchUi.requestUpdate();
            save();
        }
        return true;
    }
}