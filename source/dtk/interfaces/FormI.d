module dtk.interfaces.FormI;

import dtk.interfaces.WindowI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.types.Theme;
import dtk.types.Size;

interface FormI
{
    void setWindow(WindowI);
    void unsetWindow();

    void setSize(Size s);

    DrawingSurfaceI getDrawingSurface();
    Theme getTheme();
    void setTheme(Theme theme);
    void redraw();
}
