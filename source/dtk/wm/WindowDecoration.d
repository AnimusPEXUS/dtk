module dtk.wm.WindowDecoration;

import std.stdio;
import std.format;
import std.typecons;
import std.exception;

import dtk.interfaces.LaFI;
import dtk.interfaces.WindowI;
import dtk.interfaces.WindowDecorationI;
import dtk.interfaces.DrawingSurfaceI;

import dtk.types.WindowBorderSizes;
import dtk.types.EnumMouseCursor;

import dtk.laf.chicago98.Chicago98Laf;

import dtk.types.LineStyle;
import dtk.types.FillStyle;
import dtk.types.Color;
import dtk.types.Image;
import dtk.types.Widget;
import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.Property;
import dtk.types.EventForm;
import dtk.types.EnumWindowMovementPossibleAction;
import dtk.types.EnumWidgetInternalDraggingEventEndReason;
import dtk.types.EnumWindowDraggingEventEndReason;

import dtk.widgets.Form;
import dtk.widgets.Button;
import dtk.widgets.TextEntry;
// import dtk.widgets.Image;

import dtk.miscs.signal_tools;
import dtk.miscs.isPointInRegion;

const auto WindowDecorationProperties = cast(PropSetting[])[
    PropSetting("gsun", "WindowI", "window", "Window", ""),

    PropSetting("gsun", "Widget", "focusedWidget", "FocusedWidget", ""),
    PropSetting("gsun", "Widget", "defaultWidget", "DefaultWidget", ""),
];

class WindowDecoration : Form, WindowDecorationI
{
    mixin mixin_multiple_properties_define!(WindowDecorationProperties);
    mixin mixin_multiple_properties_forward!(WindowDecorationProperties, true);

    WidgetChild buttonClose;
    WidgetChild buttonMaximize;
    WidgetChild buttonMinimize;

    WidgetChild caption;

    WidgetChild menuButton;

    Chicago98Laf laf;

    private
    {
        SignalConnection sc_windowChange;
    }

    this(WindowI window)
    {
        setWindow(window);

        laf = new Chicago98Laf();

        buttonClose = new WidgetChild(this, new Button());
        buttonMaximize = new WidgetChild(this, new Button());
        buttonMinimize = new WidgetChild(this, new Button());

        caption = new WidgetChild(this, Label("Title (caption)"));

        menuButton = new WidgetChild(this, new Button());

        performLayout = &stdWindowLayout;

        /* buttonClose.setParent(this);
        buttonMaximize.setParent(this);
        buttonMinimize.setParent(this);
        menuButton.setParent(this); */

        sc_windowChange = connectToWindow_onAfterChanged(
            delegate void(
                WindowI o,
                WindowI n
            ) {
            // TODO: simplify this
            collectException({
                debug writeln("WindowDecoration window changed from ", o, " to ", n);

                if (o == n)
                    return;

                // sc_windowOtherEvents.disconnect();
                // sc_windowEvents.disconnect();

                if (o !is null)
                {
                    if (o.getInstalledArtificalWD() == this)
                        o.unsetInstalledArtificalWD();
                }

                if (n !is null)
                {
                    // sc_windowOtherEvents = n.connectToSignal_OtherEvents(&onWindowOtherEvent);
                    // sc_windowEvents = n.connectToSignal_WindowEvents(&onWindowEvent);
                }

                // propagateParentChangeEmission();

            }());
        });
    }

    override DrawingSurfaceI getDrawingSurface()
    {
        DrawingSurfaceI ret;
        if (isSetWindow())
            ret = getWindow().getDrawingSurface();
        return ret;
    }

    void stdWindowLayout(Widget w)
    {
        int formWidth = getWidth();
        int titleItemsTop = 5;
        int buttonWidth = 16;
        int buttonHeight = 14;

        buttonClose.setX(formWidth - 20);
        buttonClose.setY(titleItemsTop);
        buttonClose.setWidth(buttonWidth);
        buttonClose.setHeight(buttonHeight);

        buttonMaximize.setX(buttonClose.getX() - 18);
        buttonMaximize.setY(titleItemsTop);
        buttonMaximize.setWidth(buttonWidth);
        buttonMaximize.setHeight(buttonHeight);

        buttonMinimize.setX(buttonMaximize.getX() - buttonWidth);
        buttonMinimize.setY(titleItemsTop);
        buttonMinimize.setWidth(buttonWidth);
        buttonMinimize.setHeight(buttonHeight);

        caption.setX(24);
        caption.setY(titleItemsTop);
        int captWidth = formWidth - caption.getX() - buttonMinimize.getX() - 5;
        if (captWidth < 0)
            captWidth = 0;
        caption.setWidth(captWidth);
        caption.setHeight(buttonHeight);
    }

    override WidgetChild[] calcWidgetChildren()
    {
        WidgetChild[] ret;
        if (this.buttonClose)
            ret ~= this.buttonClose;
        if (this.buttonMaximize)
            ret ~= this.buttonMaximize;
        if (this.buttonMinimize)
            ret ~= this.buttonMinimize;
        if (this.caption)
            ret ~= this.caption;
        return ret;
    }

    WindowBorderSizes getBorderSizes()
    {
        WindowBorderSizes ret;
        ret.leftTop.width = 2;
        ret.leftTop.height = 20;
        ret.rightBottom.width = 2;
        ret.rightBottom.height = 2;
        return ret;
    }

    override Image renderImage()
    {
        auto w = getWidth();
        auto h = getHeight();

        auto ds = cast(DrawingSurfaceI)(new Image(w, h));

        laf.drawBewel(ds, Position2D(0, 0), Size2D(w, h), false);
        ds.drawRectangle(
            Position2D(2,2),
            Size2D(w-4, 18),
            LineStyle(Color(cast(ubyte[3])[0x00, 0x04, 0x83])),
            nullable(FillStyle(Color(cast(ubyte[3])[0x00, 0x04, 0x83])))
            );

        // TODO: draw caption gradient
        return cast(Image) ds;
    }

    override void intMouseMove(Widget widget, EventForm* event)
    {
        debug writeln("mouse movement detected");
        auto x = event.event.mouseX;
        auto y = event.event.mouseY;
        auto cursorAct = calcMovementAction(Position2D(x, y));
        debug writeln("%s selected mouse action %s (%s:%s)".format(this, cursorAct, x, y));

        EnumMouseCursor resMC = EnumMouseCursor.crDefault;

        with (EnumWindowMovementPossibleAction)
        with (EnumMouseCursor)
        final switch (cursorAct)
        {
            case undefined:
            case move:
                resMC = crDefault;
                break;

            case left:
                resMC = crWResize;
                break;

            case leftTop:
                resMC = crNWResize;
                break;

            case top:
                resMC = crNResize;
                break;

            case rightTop:
                resMC = crNEResize;
                break;

            case right:
                resMC = crEResize;
                break;

            case rightBottom:
                resMC = crSEResize;
                break;

            case bottom:
                resMC = crSResize;
                break;

            case leftBottom:
                resMC = crSWResize;
                break;
        }

        {
            auto w = getWindow();
            if (!w)
                return;

            auto p = w.getPlatform();
            if (!p)
                return;

            p.getMouseCursorManager().setCursorByType(resMC);

        }
    }

    EnumWindowMovementPossibleAction calcMovementAction(Position2D pos)
    {
        auto x = pos.x;
        auto y = pos.y;
        auto w = getWidth();
        auto h = getHeight();

        // TODO: don't use constants
        const auto borderSize = 2;
        const auto titleSize = 18;
        const auto cornerSize = 5;

        auto w_m_bs = w - borderSize;
        auto w_m_cs = w - cornerSize;
        auto h_m_bs = h - borderSize;
        auto h_m_cs = h - cornerSize;

        // NOTE: rightBottom corner is prioritized above title
        if (
            isPointInRegion(Position2D(w_m_cs, h_m_bs), Size2D(cornerSize, borderSize), pos)
            || isPointInRegion(Position2D(w_m_bs, h_m_cs), Size2D(borderSize, cornerSize), pos)
            ) return EnumWindowMovementPossibleAction.rightBottom;

        if (
            isPointInRegion(Position2D(cornerSize, borderSize), Size2D(w_m_cs, titleSize), pos)
            ) return EnumWindowMovementPossibleAction.move;

        if (
            isPointInRegion(Position2D(0, 0), Size2D(cornerSize, borderSize), pos)
            || isPointInRegion(Position2D(0, 0), Size2D(borderSize, cornerSize), pos)
            ) return EnumWindowMovementPossibleAction.leftTop;

        if (
            isPointInRegion(Position2D(w_m_cs, 0), Size2D(cornerSize, borderSize), pos)
            || isPointInRegion(Position2D(w_m_bs, 0), Size2D(borderSize, cornerSize), pos)
            ) return EnumWindowMovementPossibleAction.rightTop;

        if (
            isPointInRegion(Position2D(0, h_m_cs), Size2D(borderSize, cornerSize), pos)
            || isPointInRegion(Position2D(0, h_m_bs), Size2D(cornerSize, borderSize), pos)
            ) return EnumWindowMovementPossibleAction.rightBottom;

        if (isPointInRegion(Position2D(0, cornerSize), Size2D(h_m_cs, borderSize), pos))
            return EnumWindowMovementPossibleAction.left;

        if (isPointInRegion(Position2D(cornerSize, 0), Size2D(w_m_cs, borderSize), pos))
            return EnumWindowMovementPossibleAction.top;

        if (isPointInRegion(Position2D(w_m_bs, cornerSize), Size2D(h_m_cs, borderSize), pos))
            return EnumWindowMovementPossibleAction.left;

        if (isPointInRegion(Position2D(cornerSize, h_m_bs), Size2D(w_m_cs, borderSize), pos))
            return EnumWindowMovementPossibleAction.bottom;

        return EnumWindowMovementPossibleAction.undefined;
    }

    override void intMousePressRelease(Widget widget, EventForm* event)
    {
        auto w = getWindow();
        w.printParams();
    }

    override void intMousePress(Widget widget, EventForm* event)
    {
        debug writeln("Window Title Mouse down");

        debug writeln("mouse movement detected");
        auto x = event.event.mouseX;
        auto y = event.event.mouseY;
        auto cursorAct = calcMovementAction(Position2D(x, y));
        debug writeln("%s selected mouse action %s (%s:%s)".format(this, cursorAct, x, y));

        EnumMouseCursor resMC = EnumMouseCursor.crDefault;

        if (cursorAct == EnumWindowMovementPossibleAction.move)
        {
            {
                auto w = getWindow();
                if (!w)
                    return;

                auto p = w.getPlatform();
                if (!p)
                    return;

                p.windowDraggingEventStart(
                    w,
                    // TODO: move this function to a better place
                    delegate EnumWindowDraggingEventEndReason(Event* e)
                    {
                        if (
                            e.type == EventType.mouse
                            && e.em.type == EventMouseType.button
                            && ((e.em.button & EnumMouseButton.bl) != 0)
                            && e.em.buttonState == EnumMouseButtonState.released
                        )
                        {
                            debug writeln("Window drag success");
                            return EnumWindowDraggingEventEndReason.success;
                        }
                        return EnumWindowDraggingEventEndReason.notEnd;
                    }
                );
            }
        }
    }

    // override void redraw()
    // {
    //     super.redraw();
    // }
}
