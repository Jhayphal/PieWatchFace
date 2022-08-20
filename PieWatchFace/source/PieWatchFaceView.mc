import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class PaintContext {
    var screen as Dc;
    var xCenter as Number;
    var yCenter as Number;
    var width as Number;
    var height as Number;

    function initialize(screen as Dc) {
        self.screen = screen;
        self.width = self.screen.getWidth();
        self.height = self.screen.getHeight();
        self.xCenter = self.width >> 1;
        self.yCenter = self.height >> 1;
    }
}

class Painter {
    function drawTextCentered(context as PaintContext, text as String, font as Number) {
        context.screen.drawText(context.xCenter, context.yCenter, font, text, Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawNumberCentered(context as PaintContext, num as Number, font as Number) {
        context.screen.drawText(context.xCenter, context.yCenter, font, num.toString(), Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawArc(context as PaintContext, radius as Number, fromUnits as Number, toUnits as Number, unitsMax as Number) as Void {
        var fromDegrees = toDegrees(fromUnits, unitsMax);
        var toDegrees = toDegrees(toUnits, unitsMax);

        var from = mapDegrees(fromDegrees);
        var to = mapDegrees(toDegrees);

        context.screen.drawArc(context.xCenter, context.yCenter, radius, Graphics.ARC_CLOCKWISE, from, to);
    }

    function toDegrees(units as Number, unitsMax as Number) as Number {
        return units * 360 / unitsMax;
    }

    function mapDegrees(x as Number) as Number {
        return scaleDegrees(swapDegrees(x));
    }

    function scaleDegrees(x as Number) as Number {
        return x + 90;
    }

    function swapDegrees(x as Number) as Number {
        return 360 - x;
    }
}

class TimePainter {
    var colorsArrays as Array<Number> = [Graphics.COLOR_YELLOW, Graphics.COLOR_ORANGE, Graphics.COLOR_BLUE];

    var painter as TimePainter;
    var lastDrawMinute as Number;
    var hoursMax as Number;
    var width as Number;
    var backgroundColor as Number;

    function initialize(hoursMax as Number, width as Number, backgroundColor as Number) {
        self.hoursMax = hoursMax;
        self.width = width;
        self.backgroundColor = backgroundColor;
        self.lastDrawMinute = -1;
        self.painter = new Painter();
    }

    function isNeedDraw() as Boolean {
        return self.lastDrawMinute != self.toMinutes(System.getClockTime());
    }

    function draw(context as PaintContext) as Void {
        var time = System.getClockTime();
        var hours = time.hour % self.hoursMax;
        var minutes = time.min;

        var foregroundColor = self.colorsArrays[2];
        context.screen.setColor(foregroundColor, self.backgroundColor);
        context.screen.setPenWidth(self.width);

        self.drawMinutes(context, hours, minutes);

        context.screen.setPenWidth(self.width);

        while (hours > 0) {
            foregroundColor = self.colorsArrays[(hours + 1) & 1];
            context.screen.setColor(foregroundColor, self.backgroundColor);
            
            self.drawHour(context, hours);

            --hours;
        }

        foregroundColor = self.colorsArrays[0];
        context.screen.setColor(foregroundColor, self.backgroundColor);
        self.painter.drawNumberCentered(context, minutes, Graphics.FONT_NUMBER_MEDIUM);

        self.lastDrawMinute = self.toMinutes(time);
    }

    function toMinutes(time as System.ClockTime) as Number {
        return time.hour * 60 + time.min;
    }

    function drawHour(context as PaintContext, hour as Number) as Void {
        if (hour == 0) {
            return;
        }

        var radius = context.xCenter - self.width;
        self.painter.drawArc(context, radius, hour - 1, hour, self.hoursMax);
    }

    function drawMinutes(context as PaintContext, hour as Number, minutes as Number) as Void {
        if (minutes == 0) {
            return;
        }

        var radius = context.xCenter - self.width;
        self.painter.drawArc(context, radius, hour * 60, hour * 60 + minutes, self.hoursMax * 60);
    }
}

class PieWatchFaceView extends WatchUi.WatchFace {

    var painter as TimePainter;

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
        if (self.painter == null) {
            self.painter = new TimePainter(12, 10, Graphics.COLOR_BLACK);
        }

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        self.painter.draw(new PaintContext(dc));
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
