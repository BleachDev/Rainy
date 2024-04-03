import Toybox.Communications;
import Toybox.Position;
import Toybox.Lang;
import Toybox.Application;
import Toybox.Time;

(:glance)
class BaseData {

    public var autoLocation   as Boolean = true;
    public var windUnits      as Number  = 0;

    public var position       as Array<Double>?;
    public var location       as String = "..";
    public var time           as Moment = Time.now();
    // Forecast
    public var nowRainfall    as Array<Float>?; // Null (If unavailable) or empty (If outdated) or list of next 90 mins of rain
    public var temperatures   as Array<Float> = [];
    public var windSpeeds     as Array<Float> = [];
    public var windDirections as Array<Float> = [];
    public var rainfall       as Array<Float> = [];
    public var humidity       as Array<Float> = [];
    public var symbols        as Array<Number> = [];
    public var hours          as Number = 0;

    function update(coords as Array<Double>) as Void {
        System.println("Refreshing, " + coords);
        if (coords == null) {
            return;
        }

        position = coords;

        syncData();

        hours = IS_GLANCE ? 20 : 48;
        var days = IS_GLANCE ? 0 : 22;
        time = Time.now();
        request("https://api.bleach.dev/weather/forecast?hourly=" + hours + "&daily=" + days + "&lat=" + position[0] + "&lon=" + position[1], method(:fetchForecastData));
        request("https://api.bleach.dev/weather/search?limit=1&lat=" + position[0] + "&lon=" + position[1], method(:fetchGeoData));
    }

    // Request order
    // -> Forecast
    // -> Geo ----> (F)Aurora
    //        \---> (F)Water
    function request(url, callback) {
        Communications.makeWebRequest(url, null, {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :headers => { "User-Agent" => "GarminYr/" + VERSION + " me@bleach.dev" },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        }, callback);
    }

    function save() {
        Storage.setValue("autoLocation", autoLocation);
        Storage.setValue("windUnits", windUnits);

        Storage.setValue("geo", position);
        Storage.setValue("location", location);
        Storage.setValue("time", time.value());

        Storage.setValue("nowRainfall", nowRainfall);
        Storage.setValue("temperatures", temperatures);
        Storage.setValue("windSpeeds", windSpeeds);
        Storage.setValue("windDirections", windDirections);
        Storage.setValue("rainfall", rainfall);
        Storage.setValue("humidity", humidity);
        Storage.setValue("symbols", symbols);
    }

    function load() {
        if (Storage.getValue("autoLocation") != null) { autoLocation = Storage.getValue("autoLocation"); }
        if (Storage.getValue("windUnits") != null) { windUnits = Storage.getValue("windUnits"); }

        if (Storage.getValue("geo") != null) { position = Storage.getValue("geo"); }
        if (Storage.getValue("location") != null) { location = Storage.getValue("location"); }
        if (Storage.getValue("time") != null) { time = new Moment(Storage.getValue("time")); }

        if (Storage.getValue("nowRainfall") != null) { nowRainfall = Storage.getValue("nowRainfall"); }
        if (Storage.getValue("temperatures") != null) { temperatures = Storage.getValue("temperatures"); }
        if (Storage.getValue("windSpeeds") != null) { windSpeeds = Storage.getValue("windSpeeds"); }
        if (Storage.getValue("windDirections") != null) { windDirections = Storage.getValue("windDirections"); }
        if (Storage.getValue("rainfall") != null) { rainfall = Storage.getValue("rainfall"); }
        if (Storage.getValue("humidity") != null) { humidity = Storage.getValue("humidity"); }
        if (Storage.getValue("symbols") != null) { symbols = Storage.getValue("symbols"); }
        if (Storage.getValue("hours") != null) { hours = Storage.getValue("hours"); }
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
        for (var i = time.value(); i + 3600 < nowTime; i += 3600) {
            if (nowRainfall != null) {
                nowRainfall = []; // No more 90 minute rain
            }
            if (temperatures.size() > 0) { temperatures.remove(temperatures[0]); }
            if (windSpeeds.size() > 0) { windSpeeds.remove(windSpeeds[0]); }
            if (windDirections.size() > 0) { windDirections.remove(windDirections[0]); }
            if (rainfall.size() > 0) { rainfall.remove(rainfall[0]); }
            if (humidity.size() > 0) { humidity.remove(humidity[0]); }
            if (symbols.size() > 0) { symbols.remove(symbols[0]); }
            hours--;
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
        temperatures = new [hours];
        windSpeeds = new [hours];
        windDirections = new [hours];
        rainfall = new [hours];
        humidity = new [hours];
        symbols = new [hours];
        for (var i = 0; i < hours; i++) {
            var hour = forecastData[i];
            temperatures[i] = hour["air_temperature"];
            windSpeeds[i] = hour["wind_speed"];
            windDirections[i] = hour["wind_from_direction"];
            rainfall[i] = hour["precipitation_amount"];
            humidity[i] = hour["relative_humidity"];
            symbols[i] = hour["symbol_code"].hashCode();
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