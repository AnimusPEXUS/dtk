module dtk.interfaces.FormI;

import dtk.interfaces.WindowI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.ThemeI;
/* import dtk.types.Theme; */
import dtk.types.Size2D;

interface FormI
{
    void setWindow(WindowI window);
    void unsetWindow();

    DrawingSurfaceI getDrawingSurface();
    void setDrawingSurface(DrawingSurfaceI);
    void unsetDrawingSurface();

    ThemeI getTheme();
    void setTheme(ThemeI theme);
    void unsetTheme();

    void redraw();
}
