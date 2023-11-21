import Toybox.Lang;
import Toybox.WatchUi;

class BaseDelegate extends BehaviorDelegate {

    private static var page as Number = 0;
    private var startX as Number = 0;

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
        var menu = new WatchUi.Menu2({:title=> "Yr " + VERSION });
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

    function onNextPage() as Boolean {
        if (data.hourlyTemperature.size() < 1) {
            return false;
        }

        page = page == 4 ? 0 : page + 1;

        var view = getView(page);
        WatchUi.switchToView(view[0], view[1], WatchUi.SLIDE_UP);
        return true;
    }

    function onPreviousPage() as Boolean {
        if (data.hourlyTemperature.size() < 1) {
            return false;
        }
        
        page = page == 0 ? 4 : page - 1;

        var view = getView(page);
        WatchUi.switchToView(view[0], view[1], WatchUi.SLIDE_DOWN);
        return true;
    }

    // Vivoactive swipe controls
    function onDrag(event as DragEvent) as Boolean {
        if (VA4_MODE) {
            if (event.getType() == 0 /* START */) {
                startX = event.getCoordinates()[0];
            } else if (event.getType() == 2 /* STOP */) {
                if (startX - event.getCoordinates()[0] > (System.getDeviceSettings().screenWidth / 4)) {
                    onSelectOrSwipe();
                }
            }
            return true;
        }

        return BehaviorDelegate.onDrag(event);
    }

    function onSelect() as Boolean {
        return VA4_MODE ? onNextPage() : onSelectOrSwipe();
    }

    // Pinnacle coding
    function onSelectOrSwipe() as Boolean {
        return false;
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