module dtk.interfaces.WindowI;

interface WindowI
{
    DrawingSurfaceI getDrawingSurface();
    void setRootWidget(WidgetI widget);
}
