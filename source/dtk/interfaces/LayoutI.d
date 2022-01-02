module dtk.interfaces.LayoutI;

import dtk.interfaces.ContainerableWidgetI;

interface LayoutI : ContainerableWidgetI
{
	void checkChildren();
	LayoutChildI getLayoutChildByWidget(ContainerableWidgetI widget);
}

interface LayoutChildI
{
	
}
