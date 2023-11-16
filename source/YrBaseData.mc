import Toybox.Communications;
import Toybox.Position;
import Toybox.Lang;
import Toybox.Application;
import Toybox.Time;

(:glance)
class YrBaseData {

    public var fahrenheit           as Boolean = false;

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
        request("https://nominatim.openstreetmap.org/reverse?format=json&lat=" + position[0] + "&lon=" + position[1], method(:fetchGeoData));
    }

    // Request order
    // -> Forecast -> (F)Aurora
    //            \-> (F)Water
    // -> Geo
    function request(url, callback) {
        Communications.makeWebRequest(url, null, {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :headers => { "User-Agent" => "GarminYr/1.1 me@bleach.dev" },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        }, callback);
    }

    function save() {
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
        if (Storage.getValue("fahrenheit") != null) { fahrenheit = Storage.getValue("fahrenheit"); }
                                               else { fahrenheit = System.getDeviceSettings().temperatureUnits == System.UNIT_STATUTE; }

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
    }

    function syncData() {
        var prevTime = time.value();
        self.data = data;
        var nowTime = Time.now().value();
        for (var i = 0; prevTime + 3600 < nowTime && i < 20; i++) {
            nowRainfall = null; // No more 90 minute rain
            if (hourlyTemperature.size() > 0) { hourlyTemperature.remove(hourlyTemperature[0]); }
            if (hourlyWindSpeed.size() > 0) { hourlyWindSpeed.remove(hourlyWindSpeed[0]); }
            if (hourlyWindDirection.size() > 0) { hourlyWindDirection.remove(hourlyWindDirection[0]); }
            if (hourlyRainfall.size() > 0) { hourlyRainfall.remove(hourlyRainfall[0]); }
            if (hourlyHumidity.size() > 0) { hourlyHumidity.remove(hourlyHumidity[0]); }
            if (hourlySymbol.size() > 0) { hourlySymbol.remove(hourlySymbol[0]); }
            prevTime += 3600;
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

        if (IS_GLANCE) {
            WatchUi.requestUpdate();
            save();
        }
    }
}