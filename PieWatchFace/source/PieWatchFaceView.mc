import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class PieWatchFaceView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        var degrees = getTimeInDegrees(false);

        var width = dc.getWidth();
        var height = dc.getHeight();
        dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_BLACK);
        dc.setPenWidth(width / 2);
        dc.drawArc(width / 2, height / 2, width / 2, Graphics.ARC_CLOCKWISE, scaleDegrees(0), scaleDegrees(swapDegrees(degrees)));
    }

    function getTimeInDegrees(h24Format as Boolean) as Number {
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        var scaleFactor = 0.25;

        if (!h24Format) {
            hours = hours % 12;
            scaleFactor = 0.5;
        }

        return (hours * 60 + clockTime.min) * scaleFactor;
    }

    function scaleDegrees(x as Number) {
        return x + 90;
    }

    function swapDegrees(x as Number) {
        return 360 - x;
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}
