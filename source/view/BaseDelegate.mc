import Toybox.Lang;
import Toybox.WatchUi;

class BaseDelegate extends WatchUi.BehaviorDelegate {

    private static var page = 0;

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
        var menu = new WatchUi.Menu2({:title=>"Yr Settings"});
        menu.addItem(
            new MenuItem(
                "Temperature Units",
                data.fahrenheit ? "Fahrenheit" : "Celcius",
                0,
                {}
            )
        );
        WatchUi.pushView(menu, new SettingsDelegate(), WatchUi.SLIDE_BLINK);
        return true;
    }

    //! Handle going to the next view
    //! @return true if handled, false otherwise
    public function onNextPage() as Boolean {
        if (data.hourlyTemperature.size() < 1) {
            return false;
        }

        page = page == 4 ? 0 : page + 1;

        var view = getView(page);
        WatchUi.switchToView(view[0], view[1], WatchUi.SLIDE_UP);
        return true;
    }

    //! Handle going to the previous view
    //! @return true if handled, false otherwise
    public function onPreviousPage() as Boolean {
        if (data.hourlyTemperature.size() < 1) {
            return false;
        }
        
        page = page == 0 ? 4 : page - 1;

        var view = getView(page);
        WatchUi.switchToView(view[0], view[1], WatchUi.SLIDE_DOWN);
        return true;
    }

    function getView(page as Number) as Array<View or BehaviorDelegate> {
        switch (page) {
            case 0: return [ new SummaryView(), new SummaryDelegate() ];
            case 1: return [ new HourlyView(), new HourlyDelegate() ];
            case 2: return [ new GraphView(), new GraphDelegate() ];
            case 3: return [ new AuroraView(), new BaseDelegate() ];
            default: return [ new WaterView(), new BaseDelegate() ];
        }
    }
}