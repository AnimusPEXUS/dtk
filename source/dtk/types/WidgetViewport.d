module dtk.types.WidgetViewport;

import std.format;
import std.typecons;

import dtk.types.Widget;
import dtk.types.Position2D;

import dtk.miscs.calculateVisiblePart;

class VisibilityItem
{
    CalculateVisiblePartResult* visibilityData;
    Widget widget;

    this(Widget widget, CalculateVisiblePartResult* visibilityData)
    {
        this.widget = widget;
        this.visibilityData = visibilityData;
    }

	override string toString()
	{
		return "VisibilityItem: %s, x: %s, y: %s, w: %s, h: %s, w: %s, vx: %s, vy: %s;".format(
            this,
			visibilityData.x, visibilityData.y,
			visibilityData.w, visibilityData.h,
			visibilityData.vx, visibilityData.vy
			);
	}
}

class WidgetViewport
{
    int delegate() getX;
    int delegate() getY;
    int delegate() getWidth;
    int delegate() getHeight;

    WidgetChild[] delegate() getWidgets;

    VisibilityItem[] map;

    void recalcMap()
    {
        assert(getX);
        assert(getY);
        assert(getWidth);
        assert(getHeight);

        assert(getWidgets);

        map.length = 0;

        auto vpx = getX();
        auto vpy = getY();
        auto vpw = getWidth();
        auto vph = getHeight();

        assert(vpw >= 0);
        assert(vph >= 0);

        foreach(c; getWidgets())
        {
            auto res = calculateVisiblePart(
                vpx,
                vpy,
                vpw,
                vph,
                c.getX(),
                c.getY(),
                c.getWidth(),
                c.getHeight(),
                );

            if (!res)
                continue;

            map ~= new VisibilityItem(c.child, res);
        }
    }

    // determine object and it's visibility parameters.
    // input point is relative to viewport xy.
    // output point is relative to object xy.
    Tuple!(VisibilityItem, Position2D)[] getByViewPortPoint(
        Position2D point,
        bool only_last
        )
    {
        Tuple!(VisibilityItem, Position2D)[] ret;

        auto p_x = point.x;
        auto p_y = point.y;

        foreach_reverse (k, v; map)
        {
            auto vd = v.visibilityData;
            if (
                p_x >= vd.x
                && p_x < vd.x+vd.w

                && p_y >= vd.y
                && p_y < vd.y+vd.h
                )
            {
                ret = tuple(
                    v,
                    Position2D(
                        (p_x - vd.x),
                        (p_y - vd.y)
                        )
                    )
                ~ ret;
                if (only_last)
                    break;
            }
        }

        return ret;
    }
}
