module dtk.interfaces.FormI;

import dtk.interfaces.DrawingSurfaceI;
import dtk.types.Theme;

interface FormI
{
    DrawingSurfaceI getDrawingSurface();
    Theme getTheme();
    void setTheme(Theme theme);
    void redraw();
}
