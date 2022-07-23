module dtk.DrawingSurface_collection.vulkan.DrawingSurface;

import std.stdio;
import std.typecons;
import std.math;
import std.conv;

import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.Color;
import dtk.types.LineStyle;
import dtk.types.FillStyle;
import dtk.types.fontinfo;
import dtk.types.TextStyle;
import dtk.types.Image;

import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.FaceI;

class DrawingSurface : DrawingSurfaceI
{
    void drawDot(Position2D pos, ImageDot dot)
    {
    }

    bool canGetDot()
    {
        return true;
    }

    ImageDot getDot(Position2D pos)
    {
        ImageDot ret;
        return ret;
    }

    void drawLine(
        Position2D pos,
        Position2D pos2,
        LineStyle style
        )
    {
    }

    void drawRectangle(
        Position2D pos,
        Size2D size,
        LineStyle top_style,
        LineStyle left_style,
        LineStyle bottom_style,
        LineStyle right_style,
        Nullable!FillStyle fill_style
        )
    {
    }

    void drawArc(
        Position2D pos,
        uint radius,
        real start_angle,
        real stop_angle,
        real turn_step,
        Color color
        )
    {
    }

    void drawCircle(
        Position2D pos,
        uint radius,
        real turn_step,
        Color color
        )
    {
    }

    void drawImage(Position2D pos, Image image)
    {
    }

    bool canGetImage()
    {
        return true;
    }

    Image getImage(Position2D pos, Size2D size)
    {
        Image ret;
        return ret;
    }

    bool canPresent()
    {
        return true;
    }

    void present()
    {
    }

}
