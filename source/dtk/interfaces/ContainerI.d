module dtk.interfaces.ContainerI;

import std.typecons;

import dtk.types.Position2D;
import dtk.types.Image;

import dtk.interfaces.WidgetI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.ContainerFunctionSetI;

interface ContainerI : ContainerFunctionSetI
{
	final WidgetI asWidgetI()
	{
		return cast(WidgetI) this;
	}
	
	// ContainerI getParent();
	//
	// DrawingSurfaceI getDrawingSurface();
	// DrawingSurfaceI shiftDrawingSurfaceForChild(
	// DrawingSurfaceI ds,
	// WidgetI child
	// );
}
