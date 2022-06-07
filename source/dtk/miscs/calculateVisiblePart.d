module dtk.miscs.calculateVisiblePart;

import std.typecons;

struct CalculateVisiblePartResult
{
	// visible image (object) part
	int x, y;
	int w, h;
	// horizontal and vertical offset where to put visible part (relative to viewport)
	int vx, vy;
}

// assume we have space s, which have object c on it and part of space is viewed
// via viewport vp - get visible part of c and c position in viewport.
// null returned is c isn't visible
CalculateVisiblePartResult* calculateVisiblePart(
		// viewport
		int vpx,
		int vpy,
		int vpw,
		int vph,

		// child
		int cx,
		int cy,
		int cw,
		int ch
		)
    {
		auto ret_invisible = cast(CalculateVisiblePartResult*) null;

		auto ret = new CalculateVisiblePartResult();

    	if (cw == 0 || ch == 0)
    	{
    		return ret_invisible;
    	}

    	auto cx_p_cw = cx+cw;
    	auto cy_p_ch = cy+ch;
    	auto vpx_p_vpw = vpx+vpw;
    	auto vpy_p_vph = vpy+vph;

    	if (
    		vpx > cx_p_cw
    	|| vpy > cy_p_ch
    	|| vpx_p_vpw < cx
    	|| vpy_p_vph < cy
    	)
    	{
    		return ret_invisible;
    	}

    	{
    		if (vpx >= cx)
    		{
    			ret.vx = 0;
    		}
    		else
    		{
    			ret.vx = cx - vpx;
    		}

    		if (vpy >= cy)
    		{
    			ret.vy = 0;
    		}
    		else
    		{
    			ret.vy = cy - vpy;
    		}
    	}

    	{
    		if (vpx < cx)
    		{
    			ret.x = 0;
    		}
    		else
    		{
    			ret.x = vpx - cx;
    		}

    		if (vpy < cy)
    		{
    			ret.y = 0;
    		}
    		else
    		{
    			ret.y = vpy - cy;
    		}
    	}

    	{
    		if (vpx_p_vpw > cx_p_cw)
    		{
    			ret.w = cw;
    		}
    		else
    		{
    			ret.w = cw - (cx_p_cw - vpx_p_vpw);
    		}

    		if (vpy_p_vph > cy_p_ch)
    		{
    			ret.h = ch;
    		}
    		else
    		{
    			ret.h = ch - (cy_p_ch - vpy_p_vph);
    		}
    	}

		{
			if (ret.x>ret.w) {
				ret.w=0;
			} else {
				ret.w-=ret.x;
			}

			if (ret.y>ret.h) {
				ret.h=0;
			} else {
				ret.h-=ret.y;
			}
		}

    	if (ret.w==0 || ret.h==0)
    	{
    		return ret_invisible;
    	}

    	return ret;
    }
