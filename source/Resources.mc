import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class Resources {
    
    // The micro-optimizations are real
    private var resources as Dictionary<Number, BitmapResource> = {};
    private var resourceNames as Dictionary<Number, Symbol> = {
        -1331507130 => :clearsky_day,
        -1535495851 => :clearsky_night,
        -1219673323 => :clearsky_polartwilight,
        2118327279 => :cloudy,
        2018941991 => :fair_day,
        1971704425 => :fair_night,
        223183045 => :fair_polartwilight,
        104671553 => :fog,
        44038243 => :heavyrain,
        340693381 => :heavyrainandthunder,
        -838448405 => :heavyrainshowers_day,
        530501279 => :heavyrainshowers_night,
        -679099218 => :heavyrainshowers_polartwilight,
        275421535 => :heavyrainshowersandthunder_day,
        608654722 => :heavyrainshowersandthunder_night,
        411129877 => :heavyrainshowersandthunder_polartwilight,
        -2083185603 => :heavysleet,
        737898598 => :heavysleetandthunder,
        843467800 => :heavysleetshowers_day,
        -1951529380 => :heavysleetshowers_night,
        693091304 => :heavysleetshowers_polartwilight,
        1781829784 => :heavysleetshowersandthunder_day,
        527239930 => :heavysleetshowersandthunder_night,
        319532770 => :heavysleetshowersandthunder_polartwilight,
        1079366920 => :heavysnow,
        317439734 => :heavysnowandthunder,
        -1876409313 => :heavysnowshowers_day,
        1264317029 => :heavysnowshowers_night,
        -2055361185 => :heavysnowshowers_polartwilight,
        -966622704 => :heavysnowshowersandthunder_day,
        -235523705 => :heavysnowshowersandthunder_night,
        1868186092 => :heavysnowshowersandthunder_polartwilight,
        116707690 => :lightrain,
        726025730 => :lightrainandthunder,
        -2001193696 => :lightrainshowers_day,
        -503752469 => :lightrainshowers_night,
        2020764452 => :lightrainshowers_polartwilight,
        -1185464364 => :lightrainshowersandthunder_day,
        -250495803 => :lightrainshowersandthunder_night,
        -2108073736 => :lightrainshowersandthunder_polartwilight,
        -1438230832 => :lightsleet,
        -290628965 => :lightsleetandthunder,
        2032889179 => :lightsleetshowers_day,
        -2041929173 => :lightsleetshowers_night,
        452199269 => :lightsleetshowers_polartwilight,
        1017818640 => :lightsnow,
        702772083 => :lightsnowandthunder,
        1255812693 => :lightsnowshowers_day,
        95845553 => :lightsnowshowers_night,
        644502485 => :lightsnowshowers_polartwilight,
        -150750682 => :lightssleetshowersandthunder_day,
        119919348 => :lightssleetshowersandthunder_night,
        -763981242 => :lightssleetshowersandthunder_polartwilight,
        962854891 => :lightssnowshowersandthunder_day,
        -1262287275 => :lightssnowshowersandthunder_night,
        10936797 => :lightssnowshowersandthunder_polartwilight,
        822101396 => :partlycloudy_day,
        1887971799 => :partlycloudy_night,
        413412525 => :partlycloudy_polartwilight,
        1448337921 => :rain,
        1451666232 => :rainandthunder,
        -494771989 => :rainshowers_day,
        -496560659 => :rainshowers_night,
        1779947666 => :rainshowers_polartwilight,
        -1426281150 => :rainshowersandthunder_day,
        866900721 => :rainshowersandthunder_night,
        1206449457 => :rainshowersandthunder_polartwilight,
        -1618873504 => :sleet,
        1081575014 => :sleetandthunder,
        -1853359748 => :sleetshowers_day,
        564902271 => :sleetshowers_night,
        -331927723 => :sleetshowers_polartwilight,
        622593029 => :sleetshowersandthunder_day,
        1105769884 => :sleetshowersandthunder_night,
        429035076 => :sleetshowersandthunder_polartwilight,
        -1811300697 => :snow,
        1428412585 => :snowandthunder,
        -1532732897 => :snowshowers_day,
        103037363 => :snowshowers_night,
        403685698 => :snowshowers_polartwilight,
        1492424179 => :snowshowersandthunder_day,
        22722294 => :snowshowersandthunder_night,
        -1631461623 => :snowshowersandthunder_polartwilight,
        0 => :LauncherIcon
    };

    function getSymbol(code as Number) {
        if (resources[code] != null) {
            return resources[code];
        }

        if (resourceNames[code] == null) {
            System.println("! " + code);
            if (resources[/*"clearsky_day"*/ -1331507130] != null) {
                return resources[/*"clearsky_day"*/ -1331507130];
            }
            code = -1331507130;
        }

        System.println("Loading Res: " + code);
        resources[code] = WatchUi.loadResource(Rez.Drawables[resourceNames[code]]) as BitmapResource;
        resourceNames.remove(code);
        return resources[code];
    }
}