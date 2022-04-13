// root widget fro placing into Window or other pratform-provided host

module dtk.widgets.Form;

import core.sync.mutex;

import std.format;
import std.stdio;
import std.typecons;
import std.exception;
import std.datetime;

import observable.signal;

import dtk.interfaces.WindowI;
// import dtk.interfaces.FormI;
import dtk.interfaces.LaFI;
// import dtk.interfaces.Widget;
import dtk.interfaces.DrawingSurfaceI;
//import dtk.interfaces.Widget;
// import dtk.interfaces.Widget;
// import dtk.interfaces.LayoutI;

import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.LineStyle;
import dtk.types.FillStyle;
import dtk.types.Property;
import dtk.types.Event;
import dtk.types.EventWindow;
import dtk.types.EventForm;
import dtk.types.Image;
import dtk.types.Widget;

import dtk.widgets.mixins;
// import dtk.widgets.Widget;

import dtk.miscs.signal_tools;
import dtk.miscs.DrawingSurfaceShift;

import dtk.signal_mixins.Form;

const auto FormProperties = cast(PropSetting[]) [
PropSetting("gsun", "WindowI", "window", "Window", ""),
// PropSetting("gsun", "LaFI", "forced_laf", "ForcedLaf", ""),
// PropSetting("gsun", "Widget", "child", "Child", ""),

PropSetting("gsun", "Widget", "focusedWidget", "FocusedWidget", ""),
PropSetting("gsun", "Widget", "defaultWidget", "DefaultWidget", ""),
];

class Form : Widget
{
    mixin(mixin_FormSignals(false));
    mixin mixin_multiple_properties_define!(FormProperties);
    mixin mixin_multiple_properties_forward!(FormProperties, false);
    mixin mixin_Widget_renderImage!("Form");
    
    private
    {
    	SignalConnection sc_childChange;
    	SignalConnection sc_windowChange;
    	SignalConnection sc_focusedWidgetChange;
    	
    	SignalConnection sc_windowOtherEvents;
    	SignalConnection sc_windowEvents;
    	
    	SignalConnection sc_formEventHandler;
    }
    
    bool pressrelease_sequence_started;
    Widget pressrelease_sequence_widget;
    EnumMouseButton pressrelease_sequence_btn;

    // bool kb_pressrelease_sequence_started;
    // Widget kb_pressrelease_sequence_widget;
    // EnumMouseButton kb_pressrelease_sequence_btn;
    
    Widget mouse_focused_widget;
    
    this()
    {
    	super(0, 1);
    	mixin(mixin_multiple_properties_inst(FormProperties));
    	
    	sc_windowChange = connectToWindow_onAfterChanged(
    		delegate void(
    			WindowI o,
    			WindowI n
    			)
    		{
    			// TODO: simplify this
    			collectException(
    				{
    					debug writeln("Form window changed from ",o," to ",n);
    					
    					if (o == n)
    						return;
    					
    					sc_windowOtherEvents.disconnect();
    					sc_windowEvents.disconnect();
    					
    					if (o !is null)
    					{
    						o.unsetForm();
    					}
    					
    					if (n !is null)
    					{
    						sc_windowOtherEvents = n.connectToSignal_OtherEvents(
    							&onWindowOtherEvent
    							);
    						sc_windowEvents = n.connectToSignal_WindowEvents(
    							&onWindowEvent
    							);
    					}
    					
    					propagateParentChangeEmission();
    					
    				}()
    				);
    		}
    		);
    	
    	sc_focusedWidgetChange = connectToFocusedWidget_onAfterChanged(
    		delegate void(
    			Widget o,
    			Widget n
    			)
    		{
    			collectException(
    				{
    					if (o !is null)
    					{
    						o.redraw();
    					}
    					if (n !is null)
    					{
    						n.redraw();
    					}
    				}()
    				);
    		}
    		);
    	
    	sc_formEventHandler = this.connectToSignal_Event(&onFormSignal);
    }
    
    void onWindowOtherEvent(Event* event) nothrow
    {
    	collectException(
    		{
    			EventForm* fe = new EventForm();
    			
    			Widget focusedWidget = this.getFocusedWidget();
    			Widget mouseFocusedWidget;
    			
    			int mouseFocusedWidget_x = 0;
    			int mouseFocusedWidget_y = 0;
    			
    			{
    				int form_mouse_x;
    				int form_mouse_y;
    				
    				form_mouse_x = cast(int)event.em.x;
    				form_mouse_y = cast(int)event.em.y;
    				
    				auto res = this.getChildAtPosition(
    					Position2D(
    						cast(int)form_mouse_x,
    						cast(int)form_mouse_y
    						)
    					);
    				mouseFocusedWidget = res[0];
    				auto pos = res[1];
    				mouseFocusedWidget_x = pos.x;
    				mouseFocusedWidget_y = pos.y;
    			}
    			
    			fe.event = event;
    			fe.focusedWidget = focusedWidget;
    			fe.mouseFocusedWidget = mouseFocusedWidget;
    			fe.mouseFocusedWidget_x = mouseFocusedWidget_x;
    			fe.mouseFocusedWidget_y = mouseFocusedWidget_y;
    			
    			this.emitSignal_Event(fe);
    		}()
    		);
    }
    
    void onWindowEvent(EventWindow* event) nothrow
    {
    	collectException(
    		{
    			auto e = collectException(
    				{
    					bool propogate_resize_and_repaint = false;
    					
    					debug writeln("form received window event: ", event.eventId);
    					
    					switch (event.eventId)
    					{
    					default:
    						break;
    					case EnumWindowEvent.resize:
    					case EnumWindowEvent.show:
    						propogate_resize_and_repaint = true;
    					}
    					
    					if (propogate_resize_and_repaint)
    					{
    						auto ds = getDrawingSurface();
    						if (ds is null)
    						{
    							debug writeln(new Exception("drawing surface unavailable"));
    							return;
    						}
    						debug writeln("calling propagatePosAndSizeRecalc");
    						propagatePosAndSizeRecalc();
    						debug writeln("calling redraw");
    						redraw();
    					}
    				}()
    				);
    			debug if (e !is null) writeln("exception: ", e);
    		}()
    		);
    }
    
    void onFormSignal(EventForm* event) nothrow
    {
    	auto err = collectException(
    		{
    			if (event.mouseFocusedWidget != mouse_focused_widget)
    			{
    				Widget old = mouse_focused_widget;
    				mouse_focused_widget = event.mouseFocusedWidget;
    				if (old !is null)
    				{
    					old.intVisuallyRelease(this, old, event);
    					old.intMouseLeave(this, old, mouse_focused_widget, event);
    				}
    				if (this.pressrelease_sequence_started && this.pressrelease_sequence_widget == mouse_focused_widget)
    				{
    					mouse_focused_widget.intVisuallyPress(
    						this, 
    						mouse_focused_widget, 
    						event
    						);
    				}
    				mouse_focused_widget.intMouseEnter(this, old, mouse_focused_widget, event);
    			}
    			
    			switch (event.event.type)
    			{
    			default:
    				return;
    			case EventType.mouse:
    				switch (event.event.em.type)
    				{
    				default:
    					return;
    				case EventMouseType.movement:
    					event.mouseFocusedWidget.intMouseMove(
    						this,
    						event.mouseFocusedWidget,
    						event
    						);
    					return;
    				case EventMouseType.button:
    					switch (event.event.em.buttonState)
    					{
    					default:
    						return;
    					case EnumMouseButtonState.pressed:
    						pressrelease_sequence_started = true;
    						pressrelease_sequence_widget = event.mouseFocusedWidget;
    						pressrelease_sequence_btn = event.event.em.button;
    						setFocusedWidget(event.mouseFocusedWidget);
    						event.mouseFocusedWidget.intMousePress(
    							this,
    							event.mouseFocusedWidget,
    							event
    							);
    						event.mouseFocusedWidget.intVisuallyPress(
    							this,
    							event.mouseFocusedWidget,
    							event
    							);
    						return;
    					case EnumMouseButtonState.released:
    						event.mouseFocusedWidget.intMouseRelease(
    							this,
    							event.mouseFocusedWidget,
    							event
    							);
    						event.mouseFocusedWidget.intVisuallyRelease(
    							this,
    							event.mouseFocusedWidget,
    							event
    							);
    						if (pressrelease_sequence_started
    							&& pressrelease_sequence_widget == event.mouseFocusedWidget
    						&& pressrelease_sequence_btn == event.event.em.button)
    						{
    							event.mouseFocusedWidget.intMousePressRelease(
    								this,
    								event.mouseFocusedWidget,
    								event
    								);
    						}
    						pressrelease_sequence_started = false;
    						return;
    					}
    				}
    			case EventType.keyboard:
    				switch (event.event.ek.keyState)
    				{
    				default:
    					return;
    				case EnumKeyboardKeyState.pressed:
    					event.focusedWidget.intKeyboardPress(
    						this,
    						event.focusedWidget,
    						event
    						);
    					return;
    				case EnumKeyboardKeyState.released:
    					event.focusedWidget.intKeyboardRelease(
    						this,
    						event.focusedWidget,
    						event
    						);
    					return; 
    				}
    			case EventType.textInput:
    				switch (event.event.ek.keyState)
    				{
    				default:
    					return;
    				case EnumKeyboardKeyState.pressed:
    					event.focusedWidget.intTextInput(
    						this,
    						event.focusedWidget,
    						event
    						);
    					return;
    				}
    			}
    		}()
    		);
    	debug if (err !is null)
    	{
    		writeln("form exception caught: ", err);
    	}
    }
    
    // don't allow get Parent at From
    override Widget getParent()
    {
    	return null;
    }
    
    // don't allow set Parent at From
    override Form setParent(Widget v)
    {
    	throw new Exception("trying to set Parent at Form");
    	// unsetParent();
    	// return this;
    }
    
    private Widget focusXWidget(Widget delegate() getXFocusableWidget)
    {
        Widget cfw;
        
        if (isSetFocusedWidget())
        {
            cfw = getFocusedWidget();
        }
        
        auto w = getXFocusableWidget();
        setFocusedWidget(w);
        if (w is null)
        {
            unsetFocusedWidget();
        }
        
        return (isSetFocusedWidget() ? getFocusedWidget() : null);
    }
    
    Widget focusNextWidget()
    {
        return focusXWidget(&getNextFocusableWidget);
    }
    
    Widget focusPrevWidget()
    {
        return focusXWidget(&getPrevFocusableWidget);
    }
    
    Widget getNextFocusableWidget()
    {
        return null;
    }
    
    Widget getPrevFocusableWidget()
    {
        return null;
    }
    
}
