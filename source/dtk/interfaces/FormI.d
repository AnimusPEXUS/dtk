module dtk.interfaces.FormI;

import dtk.interfaces.WindowI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.ThemeI;
/* import dtk.types.Theme; */
import dtk.types.Size;

interface FormI
{
    void setWindow(WindowI window);
    void unsetWindow();

    DrawingSurfaceI getDrawingSurface();
    ThemeI getTheme();
    void setTheme(ThemeI theme);
}
