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
// import dtk.types.WindowEventMgrHandler;
import dtk.types.EventWindow;
import dtk.types.EventKeyboard;
import dtk.types.EventMouse;
import dtk.types.EventTextInput;
import dtk.types.Image;

import dtk.interfaces.LafI;
import dtk.interfaces.WindowI;
// import dtk.interfaces.FormI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.DrawingSurfaceI;
// import dtk.interfaces.WindowEventMgrI;

import dtk.widgets.Form;
import dtk.widgets.Button;
import dtk.widgets.ButtonCheck;
import dtk.widgets.ButtonRadio;
import dtk.widgets.Layout;
import dtk.widgets.Menu;
import dtk.widgets.MenuItem;
import dtk.widgets.Bar;
import dtk.widgets.ScrollBar;
import dtk.widgets.TextEntry;

// TODO: deprecate Position2D and Size2D and pass values directly

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
        
        ds.drawRectangle(
        	pos, 
        	size, 
        	LineStyle(c1), 
        	LineStyle(c2), 
        	Nullable!FillStyle()
        	);
        
        ds.drawRectangle(
        	Position2D(pos.x + 1, pos.y + 1), 
        	Size2D(size.width - 2, size.height - 2), 
        	LineStyle(c3), 
        	LineStyle(c4), 
        	Nullable!FillStyle()
        	);
    }
    
    void drawForm(Form widget)
    {
    	
        auto ds = widget.getDrawingSurface();
        
        // auto pos = widget.getPosition();
        auto pos_x = cast(int) widget.getX();
        auto pos_y = cast(int) widget.getY();
        auto size_w = cast(int) widget.getWidth();
        auto size_h = cast(int) widget.getHeight();
        ds.drawRectangle(
        	Position2D(pos_x, pos_y), 
        	Size2D(size_w, size_h), 
        	LineStyle(formBackground), 
        	LineStyle(formBackground),
        	LineStyle(formBackground), 
        	LineStyle(formBackground),
        	nullable(FillStyle(formBackground))
        	);
        ds.present;
    }
    
    void drawButton(Button widget)
    {
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
        
        auto pos_x = cast(int) widget.getX();
        auto pos_y = cast(int) widget.getY();
        auto size_w = cast(int) widget.getWidth();
        auto size_h = cast(int) widget.getHeight();
        
        if (is_default)
        {
            ds.drawRectangle(
            	Position2D(pos_x, pos_y),
            	Size2D(size_w, size_h), 
            	LineStyle(Color(0)), 
            	Nullable!FillStyle()
            	);
            pos_x++;
            pos_y++;
            size_w -= 2;
            size_h -= 2;
        }
        
        drawBewel(ds, Position2D(pos_x, pos_y), Size2D(size_w, size_h),  is_down);
        
        ds.drawRectangle(
        	Position2D(pos_x + 2, pos_y + 2), 
        	Size2D(
        		size_w - 4,
        		size_h - 4
        		), 
        	LineStyle(buttonColor), 
        	nullable(FillStyle(buttonColor))
        	);
        
        if (is_focused)
        {
            ds.drawRectangle(
            	Position2D(pos_x + 4, pos_y + 4),
            	Size2D(size_w - 8, size_h - 8), 
            	LineStyle(Color(0), [true, false]), 
            	Nullable!FillStyle()
            	);
        }
        
        ds.present();
    }
    
    // TODO: Radio and Check Buttons have to be scalable, not fixed;
    void drawButtonRadio(ButtonRadio widget)
    {
        auto ds = widget.getDrawingSurface();
        
        auto pos_x = cast(int) widget.getX();
        auto pos_y = cast(int) widget.getY();
        auto size_w = cast(int) widget.getWidth();
        auto size_h = cast(int) widget.getHeight();
        
        // TODO: this have to be more flexible
        auto step = 2 * PI / 32;
        
        auto p = Position2D(6, 6);
        
        ds.drawRectangle(
        	Position2D(pos_x, pos_y),
        	Size2D(size_w + 1, size_h + 1),
        	LineStyle(formBackground), 
        	nullable(FillStyle(formBackground))
        	);
        
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
        
        {
            auto id = ImageDot();
            id.color = fillColor;
            id.enabled=true;
            id.intensivity=1;
            ds.drawDot(Position2D(6, 6), id);
        }
        
        if (widget.getForm().getFocusedWidget() == widget)
        {
            ds.drawRectangle(
            	Position2D(pos_x, pos_y), 
            	Size2D(size_w, size_h), 
            	LineStyle(
            		Color(0), 
            		[true, false]
            		), 
            	Nullable!FillStyle()
            	);
        }
        
        ds.present();
        
    }
    
    // TODO: Radio and Check Buttons have to be scalable, not fixed;
    void drawButtonCheck(ButtonCheck widget)
    {
        auto ds = widget.getDrawingSurface();
        auto pos_x = cast(int) widget.getX();
        auto pos_y = cast(int) widget.getY();
        auto size_w = cast(int) widget.getWidth();
        auto size_h = cast(int) widget.getHeight();
        
        drawBewel(ds, Position2D(pos_x, pos_y), Size2D(size_w, size_h), true);
        
        ds.drawRectangle(
        	Position2D(pos_x + 2, pos_y + 2), 
        	Size2D(size_w - 4, size_h - 4), 
        	LineStyle(Color(0xffffff)),
        	nullable(FillStyle(Color(0xffffff)))
        	);
        
        if (widget.getForm().getFocusedWidget() == widget)
        {
            ds.drawRectangle(
            	Position2D(pos_x, pos_y), 
            	Size2D(size_w, size_h), 
            	LineStyle(Color(0), [true, false]), 
            	Nullable!FillStyle()
            	);
        }
        
        auto fillColor = Color(0xffffff);
        
        if (widget.getChecked())
        {
            fillColor = Color(0);
        }
        
        ds.drawRectangle(
        	Position2D(pos_x + 3, pos_y + 3), 
        	Size2D(size_w - 6, size_h - 6), 
        	LineStyle(Color(0)), 
        	nullable(FillStyle(fillColor))
        	);
        
        ds.present();
    }
    
    void drawImage(Image widget)
    {
        
    }
    
    // TODO: move this to some more appropriate place or delete
    // NOTE: have copy of this function in TextProcessor
    // private ubyte chanBlend(ubyte lower, ubyte higher, real part)
    // {
    // return cast(ubyte)(lower + ((higher - lower) * part));
    // }
    
    void drawLayout(Layout widget)
    {
        auto ds = widget.getDrawingSurface();
        auto size_w = cast(int) widget.getWidth();
        auto size_h = cast(int) widget.getHeight();
        
        ds.drawRectangle(
        	Position2D(0, 0), 
        	Size2D(size_w, size_h), 
        	LineStyle(Color(0)), 
        	Nullable!FillStyle()
        	);
        
        ds.present();
    }
    
    void drawMenu(Menu widget)
    {
    }
    
    void drawMenuItem(MenuItem widget)
    {
    }
    
    void drawBar(Bar widget)
    {
    }
    
    void drawScrollBar(ScrollBar widget)
    {
    }
    
    void drawTextEntry(TextEntry widget)
    {
        auto ds = widget.getDrawingSurface();
        auto pos_x = cast(int) widget.getX();
        auto pos_y = cast(int) widget.getY();
        auto size_w = cast(int) widget.getWidth();
        auto size_h = cast(int) widget.getHeight();
        auto draw_bewel = widget.getDrawBewelAndBackground();
        auto bewel_bg_color = widget.getBewelBackgroundColor();
        
        if (draw_bewel)
        {
            drawBewel(
            	ds, 
            	Position2D(pos_x, pos_y), 
            	Size2D(size_w, size_h), 
            	true
            	);
            pos_x += 2;
            pos_y += 2;
            size_w -= 4;
            size_h -= 4;
            ds.drawRectangle(
                Position2D(pos_x, pos_y), 
                Size2D(size_w, size_h),  
                LineStyle(Color(0)),
                nullable(FillStyle(bewel_bg_color))
                );
        }
        
        if (widget.text_view !is null)
        {
        	widget.text_view.completeRedrawToDS();        	
        }
    }
    
    /*     void addEventHandling(WindowEventMgrI mgr)
    {
    {
    WindowEventMgrKeyboardHandler ea = {
    any_focusedWidget: true, 
    any_mouseWidget: true, 
    checkMatch: delegate bool(
    WindowEventMgrI mgr, 
    WindowI window,
    EventKeyboard* e, 
    WidgetI focusedWidget, 
    WidgetI mouseWidget, 
    ulong mouseWidget_x, 
    ulong mouseWidget_y
    ) 
    {
    return true;
    }, 
    action: delegate bool(
    WindowEventMgrI mgr, 
    WindowI window,
    EventKeyboard* e, 
    WidgetI focusedWidget, 
    WidgetI mouseWidget, 
    ulong mouseWidget_x, 
    ulong mouseWidget_y
    ) 
    {
    // auto mc = e.keysym.modcode;
    // mc &= EnumKeyboardModCodeNOT.Locks;
    if (focusedWidget is null)
    {
    return false;
    }
    
    if (e.key_state == EnumKeyboardKeyState.pressed)
    {
    focusedWidget.callKeyboardHandler(
    "key-down", 
    e,
    mouseWidget_x,
    mouseWidget_y
    );
    }
    
    if (e.key_state == EnumKeyboardKeyState.released)
    {
    focusedWidget.callKeyboardHandler(
    "key-up", 
    e,
    mouseWidget_x,
    mouseWidget_y
    );
    
    // TODO: fix this..?
    // if (e.button.clicks != 0)
    // {
    // focusedWidget.callKeyboardHandler(
    // "key-click", 
    // e,
    // mouseWidget_x,
    // mouseWidget_y
    // );
    // }
    }
    
    return true;
    },
    };
    
    mgr.addKeyboardHandler(ea);
    }
    
    {
    WindowEventMgrMouseHandler ea = {
    any_focusedWidget: true, 
    any_mouseWidget: true, 
    checkMatch: delegate bool(
    WindowEventMgrI mgr,
    WindowI window,
    EventMouse* e, 
    WidgetI focusedWidget,
    WidgetI mouseWidget, 
    ulong mouseWidget_x, 
    ulong mouseWidget_y
    ) 
    {
    return e.type == EventMouseType.button;
    }, 
    action: delegate bool(
    WindowEventMgrI mgr, 
    WindowI window,
    EventMouse* e, 
    WidgetI focusedWidget, 
    WidgetI mouseWidget, 
    ulong mouseWidget_x, 
    ulong mouseWidget_y
    ) 
    {
    if (mouseWidget is null)
    {
    return false;
    }
    
    if (e.button.buttonState 
    == EnumMouseButtonState.pressed)
    {
    mouseWidget.callMouseHandler(
    "button-down", 
    e,
    mouseWidget_x,
    mouseWidget_y
    );
    }
    
    if (e.button.buttonState 
    == EnumMouseButtonState.released)
    {
    mouseWidget.callMouseHandler(
    "button-up", 
    e,
    mouseWidget_x,
    mouseWidget_y
    );
    
    if (e.button.clicks != 0)
    {
    mouseWidget.callMouseHandler(
    "button-click", 
    e,
    mouseWidget_x,
    mouseWidget_y
    );
    }
    }
    
    return true;
    },
    };
    
    mgr.addMouseHandler(ea);
    }
    
    {
    WindowEventMgrWindowHandler ea = {
    any_focusedWidget: true, 
    any_mouseWidget: true, 
    checkMatch: delegate bool(
    WindowEventMgrI mgr,
    WindowI window,
    EventWindow* e, 
    WidgetI focusedWidget,
    WidgetI mouseWidget, 
    ulong mouseWidget_x, 
    ulong mouseWidget_y
    ) 
    {
    return true;
    }, 
    action: delegate bool(
    WindowEventMgrI mgr, 
    WindowI window,
    EventWindow* e, 
    WidgetI focusedWidget, 
    WidgetI mouseWidget, 
    ulong mouseWidget_x, 
    ulong mouseWidget_y
    ) 
    {
    
    switch (e.eventId)
    {
    default:
    debug writeln(
    "Chicago98Laf window event id not supported:",
    e.eventId
    );
    return false;
    case EnumWindowEvent.close:
    window.emitSignal_Close(e);
    return false;
    case EnumWindowEvent.move:
    window.emitSignal_Move(e);
    return false;
    case EnumWindowEvent.resize:
    window.emitSignal_Resize(e);
    return false;
    case EnumWindowEvent.maximize:
    window.emitSignal_Maximize(e);
    return false;
    case EnumWindowEvent.unmaximize:
    window.emitSignal_Unmaximize(e);
    return false;
    case EnumWindowEvent.minimize:
    window.emitSignal_Minimize(e);
    return false;
    case EnumWindowEvent.unminimize:
    window.emitSignal_Unminimize(e);
    return false;
    case EnumWindowEvent.restore:
    window.emitSignal_Restore(e);
    return false;
    case EnumWindowEvent.show:
    window.emitSignal_Show(e);
    return false;
    case EnumWindowEvent.hide:
    window.emitSignal_Hide(e);
    return false;
    case EnumWindowEvent.expose:
    window.emitSignal_Expose(e);
    return false;
    case EnumWindowEvent.keyboardFocus:
    window.emitSignal_KeyboardFocus(e);
    return false;
    case EnumWindowEvent.keyboardUnFocus:
    window.emitSignal_KeyboardUnFocus(e);
    return false;
    case EnumWindowEvent.mouseFocus:
    window.emitSignal_MouseFocus(e);
    return false;
    case EnumWindowEvent.mouseUnFocus:
    window.emitSignal_MouseUnFocus(e);
    return false;
    case EnumWindowEvent.focus:
    window.emitSignal_Focus(e);
    return false;
    case EnumWindowEvent.unFocus:
    window.emitSignal_UnFocus(e);
    return false;
    case EnumWindowEvent.focusProposed:
    window.emitSignal_FocusProposed(e);
    return false;
    }
    
    },
    };
    
    mgr.addWindowHandler(ea);
    }
    
    {
    WindowEventMgrTextInputHandler ea = {
    any_focusedWidget: true, 
    any_mouseWidget: true, 
    checkMatch: delegate bool(
    WindowEventMgrI mgr,
    WindowI window,
    EventTextInput* e, 
    WidgetI focusedWidget,
    WidgetI mouseWidget, 
    ulong mouseWidget_x, 
    ulong mouseWidget_y
    ) 
    {
    return true;
    }, 
    action: delegate bool(
    WindowEventMgrI mgr, 
    WindowI window,
    EventTextInput* e, 
    WidgetI focusedWidget, 
    WidgetI mouseWidget, 
    ulong mouseWidget_x, 
    ulong mouseWidget_y
    ) 
    {
    
    if (focusedWidget is null)
    {
    return false;
    }
    
    focusedWidget.callTextInputHandler(
    "text-input", 
    e,
    mouseWidget_x,
    mouseWidget_y
    );
    
    return true;
    },
    };
    
    mgr.addTextInputHandler(ea);
    }
    } */
}
