module dtk.widgets.WidgetDrawingSurface;

import std.stdio;
import std.typecons;

import dtk.interfaces.WidgetI;
import dtk.interfaces.DrawingSurfaceI;

import dtk.widgets.Widget;

import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.Color;
import dtk.types.LineStyle;
import dtk.types.FillStyle;
import dtk.types.Font;
import dtk.types.FontStyle;
import dtk.types.TextStyle;

class WidgetDrawingSurfaceShifted : DrawingSurfaceI
{
    private
    {
        Widget widget;
        /* int w,h, x,y; */
    }

    this(Widget widget)
    {
        this.widget = widget;

        // TODO: fix next or delete next
        /* this.widget.connectToPosition_onAfterChanged(&onWidgetPosChange);
        this.widget.connectToSize_onAfterChanged(&onWidgetSizeChange); */
    }

    bool isValid()
    {
        return getParentDS() !is null;
    }

    DrawingSurfaceI getParentDS()
    {
        /* DrawingSurfaceI ret; */
        if (!widget)
            return null;
        auto p = widget.getParent();
        if (!p)
            return null;
        auto pds = p.getDrawingSurface();
        if (!pds)
            return null;
        return pds;
    }

    // TODO: probably refactoring needed
    private int x() @property
    {
        return widget.getPosition().x;
    }

    // TODO: probably refactoring needed
    private int y() @property
    {
        return widget.getPosition().y;
    }

    // TODO: probably refactoring needed
    private int w() @property
    {
        return widget.getSize().width;
    }

    // TODO: probably refactoring needed
    private int h() @property
    {
        return widget.getSize().height;
    }

    /* void onWidgetPosChange() nothrow
    {
        try {
        writeln("WidgetDrawingSurfaceShifted:onWidgetPosChange");
        auto pos = widget.getPosition();
        x = pos.x;
        y = pos.y;
        } catch (Exception e) {

        }
    }

    void onWidgetSizeChange() nothrow
    {
        try {
        writeln("WidgetDrawingSurfaceShifted:onWidgetSizeChange");
        auto size = widget.getSize();
        w = size.width;
        h = size.height;
        } catch (Exception e) {

        }
    } */

    // =============== implimentation ===============

    void drawDot(Position2D pos, Color color)
    {
        Position2D npos;
        npos.x = pos.x + x;
        npos.y = pos.y + y;
        auto pds = getParentDS();
        if (pds)
            pds.drawDot(npos, color);
    }

    void drawLine(Position2D pos, Position2D pos2, LineStyle style)
    {
        Position2D npos;
        Position2D npos2;
        npos.x = pos.x + x;
        npos.y = pos.y + y;
        npos2.x = pos2.x + x;
        npos2.y = pos2.y + y;
        auto pds = getParentDS();
        if (pds)
            pds.drawLine(npos, npos2, style);
    }

    void drawRectangle(Position2D pos, Size2D size, LineStyle top_style, LineStyle left_style,
            LineStyle bottom_style, LineStyle right_style, Nullable!FillStyle fill_style)
    {
        Position2D npos;
        npos.x = pos.x + x;
        npos.y = pos.y + y;
        auto pds = getParentDS();
        if (pds)
            pds.drawRectangle(npos, size, top_style, left_style, bottom_style,
                    right_style, fill_style);
    }

    void drawText(string text, Position2D pos, Font font, FontStyle font_style, TextStyle text_style)
    {
        Position2D npos;
        npos.x = pos.x + x;
        npos.y = pos.y + y;
        auto pds = getParentDS();
        if (pds)
            pds.drawText(text, npos, font, font_style, text_style);
    }

    void drawArc(Position2D pos, uint radius, real start_angle, real stop_angle,
            real turn_step, Color color)
    {
        Position2D npos;
        npos.x = pos.x + x;
        npos.y = pos.y + y;
        auto pds = getParentDS();
        if (pds)
            pds.drawArc(npos, radius, start_angle, stop_angle, turn_step, color);
    }

    void drawCircle(Position2D pos, uint radius, real turn_step, Color color)
    {
        Position2D npos;
        npos.x = pos.x + x;
        npos.y = pos.y + y;
        auto pds = getParentDS();
        if (pds)
            pds.drawCircle(npos, radius, turn_step, color);
    }

    void present()
    {
        auto pds = getParentDS();
        pds.present();
    }

}
