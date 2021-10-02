module dtk.themes.chicago98.Chicago98Laf;

import std.stdio;
import std.typecons;
import std.math;

import dtk.types.Color;
import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.LineStyle;
import dtk.types.FillStyle;
import dtk.types.fontinfo;
import dtk.types.TextStyle;
import dtk.types.EventXAction;
import dtk.types.EventWindow;
import dtk.types.EventKeyboard;
import dtk.types.EventMouse;
import dtk.types.EventTextInput;

import dtk.interfaces.LafI;
import dtk.interfaces.WindowI;
import dtk.interfaces.FormI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.WindowEventMgrI;

import dtk.widgets;

const
{
    auto P_45 = PI / 4;
    auto P_M45 = -P_45;
    auto P_135 = PI / 2 + P_45;
    auto P_135M2 = PI * 2 - P_45;
}

class Chicago98Laf : LafI
{

    Color formBackground = Color(0xc0c0c0);
    Color buttonBorderColor = Color(cast(ubyte[3])[0, 0, 0]);
    Color buttonColor = Color(0xc0c0c0);

    Color elementLightedColor = Color(0xffffff);
    Color elementLightedColor2 = Color(0xdfdfdf);

    Color elementDarkedColor = Color(0x000000);
    Color elementDarkedColor2 = Color(0x808080);

    void drawBewel(DrawingSurfaceI ds, Position2D pos, Size2D size, bool inverted)
    {
        auto c1 = elementLightedColor, c2 = elementDarkedColor,
            c3 = elementLightedColor2, c4 = elementDarkedColor2;

        if (inverted)
        {
            c1 = elementDarkedColor2;
            c2 = elementLightedColor2;
            c3 = elementLightedColor2;
            c4 = elementLightedColor;
        }

        ds.drawRectangle(pos, size, LineStyle(c1), LineStyle(c2), Nullable!FillStyle());

        ds.drawRectangle(Position2D(pos.x + 1, pos.y + 1), Size2D(size.width - 2,
                size.height - 2), LineStyle(c3), LineStyle(c4), Nullable!FillStyle());
    }

    void drawForm(Form widget)
    {

        writeln("drawForm called");

        auto ds = widget.getDrawingSurface();

        auto pos = widget.getPosition();
        auto size = widget.getSize();
        ds.drawRectangle(pos, size, LineStyle(formBackground), LineStyle(formBackground),
                LineStyle(formBackground), LineStyle(formBackground),
                nullable(FillStyle(formBackground)));
    }

    void drawButton(Button widget)
    {
        writeln("drawButton called");

        bool is_default = delegate bool() {
            auto f = widget.getForm();
            if (f is null)
                return false;
            auto def = f.getDefaultWidget();
            return widget == def;
        }();
        bool is_focused = delegate bool() {
            auto f = widget.getForm();
            if (f is null)
                return false;
            auto curvid = f.getFocusedWidget();
            return widget == curvid;
        }();
        bool is_down = widget.button_is_down;

        auto ds = widget.getDrawingSurface();

        auto pos = Position2D(0, 0);
        auto size = widget.getSize();

        if (is_default)
        {
            ds.drawRectangle(Position2D(0, 0), size, LineStyle(Color(0)), Nullable!FillStyle());
            pos.x++;
            pos.y++;
            size.width -= 2;
            size.height -= 2;
        }

        drawBewel(ds, pos, size, is_down);

        ds.drawRectangle(Position2D(pos.x + 2, pos.y + 2), Size2D(size.width - 4,
                size.height - 4), LineStyle(buttonColor), nullable(FillStyle(buttonColor)));

        if (is_focused)
        {
            ds.drawRectangle(Position2D(pos.x + 4, pos.y + 4),
                    Size2D(size.width - 8, size.height - 8), LineStyle(Color(0),
                        [true, false]), Nullable!FillStyle());
        }

        ds.present();
    }

    // TODO: Radio and Check Buttons have to be scalable, not fixed;
    void drawButtonRadio(ButtonRadio widget)
    {
        writeln("drawButtonRadio called");

        auto ds = widget.getDrawingSurface();
        auto pos = Position2D(0, 0);
        auto size = widget.getSize();

        // TODO: this have to be more flexible
        auto step = 2 * PI / 32;

        auto p = Position2D(6, 6);

        ds.drawRectangle(pos, /* Position2D(pos.x - 2, pos.y - 2), */
                Size2D(size.width + 1, size.height + 1),
                LineStyle(formBackground), nullable(FillStyle(formBackground)));

        ds.drawArc(p, 6, P_M45, P_135, step, elementLightedColor);
        ds.drawArc(p, 6, P_135, P_135M2, step, elementDarkedColor2);

        ds.drawArc(p, 5, P_M45, P_135, step, elementLightedColor2);
        ds.drawArc(p, 5, P_135, P_135M2, step, elementDarkedColor);

        ds.drawCircle(p, 4, step, Color(0xffffff));

        auto fillColor = Color(0xffffff);
        if (widget.getChecked())
        {
            fillColor = Color(0);
        }

        for (int i = 3; i != 0; i--)
        {
            ds.drawCircle(p, i, step, fillColor);
        }

        ds.drawDot(Position2D(6, 6), fillColor);

        if (widget.getForm().getFocusedWidget() == widget)
        {
            ds.drawRectangle(pos, /* Position2D(pos.x - 2, pos.y - 2), */
                    size, /* Size2D(size.width + 4, size.height + 4), */
                    LineStyle(Color(0), [true, false]), Nullable!FillStyle());
        }

        ds.present();
        /*
        if (widget.getForm().getFocusedWidget() == widget)
        {
            ds.drawCircle(p, 4, step, Color(0));
        } else {
            ds.drawCircle(p, 4, step, Color(0xffffff));
        }

        ds.drawCircle(p, 3, step, Color(0xffffff));

        auto fillColor = Color(0xffffff);

        if (widget.getChecked())
        {
            fillColor= Color(0);
        }

        for (int i = 2 ; i != -1; i--)
        {
            ds.drawCircle(p, i, step, fillColor);
        } */

    }

    /* void drawButtonRadio(ButtonRadio!uint widget);
    void drawButtonRadio(ButtonRadio!int widget);
    void drawButtonRadio(ButtonRadio!string widget); */

    // TODO: Radio and Check Buttons have to be scalable, not fixed;
    void drawButtonCheck(ButtonCheck widget)
    {
        auto ds = widget.getDrawingSurface();
        auto pos = Position2D(0, 0);
        auto size = widget.getSize();

        drawBewel(ds, pos, size, true);

        ds.drawRectangle(Position2D(pos.x + 2, pos.y + 2), Size2D(size.width - 4,
                size.height - 4), LineStyle(Color(0xffffff)),
                nullable(FillStyle(Color(0xffffff))));

        /* ds.drawRectangle(
            Position2D(pos.x + 3, pos.y + 3),
            Size2D(size.width - 6, size.height - 6),
            LineStyle(Color(0xffffff)),
            Nullable!FillStyle()
        ); */

        if (widget.getForm().getFocusedWidget() == widget)
        {
            ds.drawRectangle(pos, /* Position2D(pos.x - 2, pos.y - 2), */
                    size, /* Size2D(size.width + 4, size.height + 4), */
                    LineStyle(Color(0), [true, false]), Nullable!FillStyle());
        }

        auto fillColor = Color(0xffffff);

        if (widget.getChecked())
        {
            fillColor = Color(0);
        }

        ds.drawRectangle(Position2D(pos.x + 3, pos.y + 3), Size2D(size.width - 6,
                size.height - 6), LineStyle(Color(0)), nullable(FillStyle(fillColor)));

        ds.present();
    }

    void drawImage(Image widget)
    {
        writeln("drawImage called");
    }

    void drawLabel(Label widget)
    {
        writeln("drawLabel called");

        if (widget.textImage !is null)
        {
            auto pos = Position2D(0, 0);
            auto ds = widget.getDrawingSurface();
            ds.drawImage(pos, widget.textImage); // , TextStyle()
            ds.present();
        }
    }

    void drawLayout(Layout widget)
    {
        writeln("drawLayout called");
    }

    void drawMenu(Menu widget)
    {
        writeln("drawMenu called");
    }

    void drawMenuItem(MenuItem widget)
    {
        writeln("drawMenuItem called");
    }

    void drawBar(Bar widget)
    {
        writeln("drawBar called");
    }

    void drawScrollBar(ScrollBar widget)
    {
        writeln("drawScrollBar called");
    }

    void drawTextEntry(TextEntry widget)
    {
        writeln("drawTextEntry called");
    }

    void drawTextArea(TextArea widget)
    {
        writeln("drawTextArea called");
    }

    void addEventHandling(WindowEventMgrI mgr)
    {
        {
            EventKeyboardAction ea = {
                any_focusedWidget: true, any_mouseWidget: true, checkMatch: delegate bool(WindowEventMgrI mgr, WindowI window,
                        EventKeyboard* e, WidgetI focusedWidget, WidgetI mouseWidget,) {
                    auto mc = e.keysym.modcode;
                    writeln("caps:", (mc & EnumKeyboardModCode.CapsLock) != 0);
                    writeln("num:", (mc & EnumKeyboardModCode.NumLock) != 0);
                    writeln("scroll:", (mc & EnumKeyboardModCode.ScrollLock) != 0);
                    mc &= EnumKeyboardModCodeNOT.Locks;
                    writeln("caps2:", (mc & EnumKeyboardModCode.CapsLock) != 0);
                    writeln("num2:", (mc & EnumKeyboardModCode.NumLock) != 0);
                    writeln("scroll2:", (mc & EnumKeyboardModCode.ScrollLock) != 0);
                    if (e.keysym.keycode == EnumKeyboardKeyCode.Tabulation
                            && (mc == 0 || mc == EnumKeyboardModCode.LeftShift))
                        return true;
                    return false;
                }, action: delegate bool(WindowEventMgrI mgr, WindowI window,
                        EventKeyboard* e, WidgetI focusedWidget, WidgetI mouseWidget,) {
                    auto mc = e.keysym.modcode;
                    mc &= EnumKeyboardModCodeNOT.Locks;
                    writeln("tab pressed");
                    if (mc == EnumKeyboardModCode.LeftShift)
                    {
                        writeln("with shift");
                    }
                    return true;
                },};

                mgr.addKeyboardAction(ea);
            }

            {
                EventMouseAction ea = {
                    any_focusedWidget: true, any_mouseWidget: true, checkMatch: delegate bool(WindowEventMgrI mgr, WindowI window,
                            EventMouse* e, WidgetI focusedWidget, WidgetI mouseWidget,) {
                        return e.type == EventMouseType.button;
                    }, action: delegate bool(WindowEventMgrI mgr, WindowI window,
                            EventMouse* e, WidgetI focusedWidget, WidgetI mouseWidget,) {
                        if (mouseWidget is null)
                        {
                            writeln("error: got mouse event, but mouseWidget is null");
                            return false;
                        }

                        if (e.button.buttonState == EnumMouseButtonState.pressed)
                        {
                            mouseWidget.on_mouse_down_internal(e);
                        }

                        if (e.button.buttonState == EnumMouseButtonState.released)
                        {
                            mouseWidget.on_mouse_up_internal(e);

                            if (e.button.clicks != 0)
                            {
                                mouseWidget.on_mouse_click_internal(e);
                            }
                        }

                        return true;
                    },};

                    mgr.addMouseAction(ea);
                }

                {
                    EventWindowAction ea = {
                        any_focusedWidget: true, any_mouseWidget: true, checkMatch: delegate bool(WindowEventMgrI mgr, WindowI window,
                                EventWindow* e, WidgetI focusedWidget, WidgetI mouseWidget,) {
                            writeln("checkMatch 1 called");
                            return true;
                        }, action: delegate bool(WindowEventMgrI mgr, WindowI window,
                                EventWindow* e, WidgetI focusedWidget, WidgetI mouseWidget,) {
                            bool needs_resize = false;
                            bool needs_redraw = false;

                            switch (e.eventId)
                            {
                            default:
                                return false;
                                /* case EnumWindowEvent.show:
                                break; */
                            case EnumWindowEvent.show:
                            case EnumWindowEvent.resize:
                                needs_resize = true;
                                needs_redraw = true;
                                break;
                            }

                            if (needs_resize)
                            {
                                FormI _form = window.getForm();
                                if (_form !is null)
                                {
                                    _form.positionAndSizeRequest(Position2D(0,
                                            0), Size2D(e.size.width, e.size.height));
                                    needs_redraw = true;
                                }
                            }

                            if (needs_redraw)
                            {
                                window.redraw();
                            }
                            return true;
                        },};

                        mgr.addWindowAction(ea);
                    }
                }
            }
