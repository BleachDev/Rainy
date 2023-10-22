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
    // Nowcast
    public var temperature          as Float = 88.0;
    public var windSpeed            as Float = 88.0;
    public var windDirection        as Float = 88.0;
    public var rainfall             as Array<Float>? = null; // Null or list of next 90 mins of rain

    function update(coords as Array<Double>) as Void {
        System.println("Refreshing, " + coords);
        var nowUrl = "https://api.met.no/weatherapi/nowcast/2.0/complete?lat=" + coords[0] + "&lon=" + coords[1];
        var geoUrl = "https://nominatim.openstreetmap.org/reverse?format=json&lat=" + coords[0] + "&lon=" + coords[1];
        position = coords;

        var options = {                                             // set the options
            :method => Communications.HTTP_REQUEST_METHOD_GET,      // set HTTP method
            :headers => { "User-Agent" => "GarminYr/Dev me@bleach.dev" },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON // set response type
        };

        Communications.makeWebRequest(geoUrl, null, options, method(:fetchGeoData));
        Communications.makeWebRequest(nowUrl, null, options, method(:fetchNowData));
    }

    function save() {
        Storage.setValue("fahrenheit", fahrenheit);

        Storage.setValue("geo", position);
        Storage.setValue("location", location);

        Storage.setValue("temperature", temperature);
        Storage.setValue("windSpeed", windSpeed);
        Storage.setValue("windDirection", windDirection);
        Storage.setValue("rainfall", rainfall);
    }

    function load() {
        if (Storage.getValue("fahrenheit") != null) { fahrenheit = Storage.getValue("fahrenheit"); }
                                               else { fahrenheit = System.getDeviceSettings().temperatureUnits == System.UNIT_STATUTE; }

        if (Storage.getValue("geo") != null) { position = Storage.getValue("geo"); }
        if (Storage.getValue("location") != null) { location = Storage.getValue("location"); }

        if (Storage.getValue("temperature") != null) { temperature = Storage.getValue("temperature"); }
        if (Storage.getValue("windSpeed") != null) { windSpeed = Storage.getValue("windSpeed"); }
        if (Storage.getValue("windDirection") != null) { windDirection = Storage.getValue("windDirection"); }
        if (Storage.getValue("rainfall") != null) { rainfall = Storage.getValue("rainfall"); }
        WatchUi.requestUpdate();
    }

    // Fetching Methods

    function fetchNowData(responseCode as Number, data as Dictionary?) as Void {
        System.println("NOW " + responseCode);
        if (responseCode != 200 || data == null || data["properties"] == null) {
            System.println("NOW EXIT " + data);

            // Use internal weather as a backup
            var conditions = Weather.getCurrentConditions();
            if (conditions != null) {
                if (conditions.temperature != null) { temperature = conditions.temperature.toFloat(); }
                if (conditions.windSpeed != null) { windSpeed = conditions.windSpeed; }
                if (conditions.windBearing != null) { windDirection = conditions.windBearing.toFloat(); }
            }

            WatchUi.requestUpdate();
            return;
        }

        var seriesData = data["properties"]["timeseries"] as Dictionary;

        temperature = seriesData[0]["data"]["instant"]["details"]["air_temperature"];
        windSpeed = seriesData[0]["data"]["instant"]["details"]["wind_speed"];
        windDirection = seriesData[0]["data"]["instant"]["details"]["wind_speed_of_gust"];
        rainfall = new [seriesData.size() < 19 ? seriesData.size() : 19];
        for (var i = 0; i < seriesData.size() && i < 19; i++) {
            rainfall[i] = seriesData[i]["data"]["instant"]["details"]["precipitation_rate"];
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