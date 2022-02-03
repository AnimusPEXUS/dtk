module dtk.interfaces.ContainerableI;

import std.typecons;

import dtk.interfaces.WidgetI;
import dtk.interfaces.ContainerI;

import dtk.types.Position2D;

interface ContainerableI // : WidgetI
{
	 typeof(this) setParent(ContainerI container);
	 typeof(this) unsetParent();
	 ContainerI getParent();
	 
	 static foreach (v; ["X", "Y", "Width", "Height"])
	 {
	 	 import std.format;
	 	 mixin(
	 	 	 q{
	 	 	 	 ulong get%1$s();
	 	 	 	 typeof(this) set%1$s(ulong v);
	 	 	 }.format(v)
	 	 	 );
	 }
	 
	 Tuple!(WidgetI, Position2D) getWidgetAtPosition(Position2D point);
	 void redraw();
	 void propagatePosAndSizeRecalc();
}
