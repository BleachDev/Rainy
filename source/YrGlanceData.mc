import Toybox.Communications;
import Toybox.Position;
import Toybox.Lang;
import Toybox.Application;
import Toybox.Time;

(:glance)
class YrGlanceData {

    public var fahrenheit           as Boolean = false;

    public var position             as Array<Double>?;
    public var location             as String = "..";
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
        var nowUrl = "https://api.bleach.dev/weather/forecast?limit=20&lat=" + coords[0] + "&lon=" + coords[1];
        var geoUrl = "https://nominatim.openstreetmap.org/reverse?format=json&lat=" + coords[0] + "&lon=" + coords[1];
        position = coords;

        var options = {                                             // set the options
            :method => Communications.HTTP_REQUEST_METHOD_GET,      // set HTTP method
            :headers => { "User-Agent" => "GarminYr/1.1 me@bleach.dev" },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON // set response type
        };

        Communications.makeWebRequest(geoUrl, null, options, method(:fetchGeoData));
        Communications.makeWebRequest(nowUrl, null, options, method(:fetchNowData));
    }

    function save() {
        Storage.setValue("fahrenheit", fahrenheit);

        Storage.setValue("geo", position);
        Storage.setValue("location", location);

        Storage.setValue("nowRainfall", nowRainfall);
        Storage.setValue("hourlyTemperature", hourlyTemperature);
        Storage.setValue("hourlyWindSpeed", hourlyWindSpeed);
        Storage.setValue("hourlyWindDirection", hourlyWindDirection);
        Storage.setValue("hourlyRainfall", hourlyRainfall);
    }

    function load() {
        if (Storage.getValue("fahrenheit") != null) { fahrenheit = Storage.getValue("fahrenheit"); }
                                               else { fahrenheit = System.getDeviceSettings().temperatureUnits == System.UNIT_STATUTE; }

        if (Storage.getValue("geo") != null) { position = Storage.getValue("geo"); }
        if (Storage.getValue("location") != null) { location = Storage.getValue("location"); }

        if (Storage.getValue("nowRainfall") != null) { nowRainfall = Storage.getValue("nowRainfall"); }
        if (Storage.getValue("hourlyTemperature") != null) { hourlyTemperature = Storage.getValue("hourlyTemperature"); }
        if (Storage.getValue("hourlyWindSpeed") != null) { hourlyWindSpeed = Storage.getValue("hourlyWindSpeed"); }
        if (Storage.getValue("hourlyWindDirection") != null) { hourlyWindDirection = Storage.getValue("hourlyWindDirection"); }
        if (Storage.getValue("hourlyRainfall") != null) { hourlyRainfall = Storage.getValue("hourlyRainfall"); }
        WatchUi.requestUpdate();
    }

    // Fetching Methods

    function fetchNowData(responseCode as Number, data as Dictionary?) as Void {
        System.println("FC " + responseCode);
        if (responseCode != 200 || data == null || data["forecast"] == null) {
            return;
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

        WatchUi.requestUpdate();
        save();
    }

    function fetchGeoData(responseCode as Number, data as Dictionary?) as Void {
        System.println("GEO " + responseCode);
        if (responseCode != 200 || data == null || data["address"] == null) {
            System.println("GEO EXIT " + data);
            return;
        }

        var addressData = data["address"] as Dictionary;

        if (addressData["neighbourhood"] != null) {
            location = addressData["neighbourhood"];
        } else if (addressData["farm"] != null) {
            location = addressData["farm"];
        } else if (addressData["quarter"] != null) {
            location = addressData["quarter"];
        } else if (addressData["village"] != null) {
            location = addressData["village"];
        } else if (addressData["suburb"] != null) {
            location = addressData["suburb"];
        } else if (addressData["city_district"] != null) {
            location = addressData["city_district"];
        } else if (addressData["city"] != null) {
            location = addressData["city"];
        } else if (addressData["county"] != null) {
            location = addressData["county"];
        } else if (addressData["country"] != null) {
            location = addressData["country"];
        } else {
            location = "Unknown";
        }

        WatchUi.requestUpdate();
        save();
    }
}