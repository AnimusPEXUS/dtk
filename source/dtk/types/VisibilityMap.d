module dtk.types.VisibilityMap;

import std.typecons;

import dtk.miscs.calculateVisiblePart;

import dtk.types.Position2D;

class Visibility(T)
{
	ulong x;
	ulong y;
	ulong w;
	ulong h;
	ulong vx;
	ulong vy;
	T o;
}

class VisibilityMap(T)
{
	ulong vp_x;
	ulong vp_y;
	ulong vp_w;
	ulong vp_h;
	
	Visibility!(T)[] map;
	
	void init(
		ulong vp_x, 
		ulong vp_y,
		ulong vp_w, 
		ulong vp_h
		)
	{
		this.vp_x = vp_x;
		this.vp_y = vp_y;
		this.vp_w = vp_w;
		this.vp_h = vp_h;
		this.map = this.map[0 .. 0]; 
	}
	
	// visible?
	bool put(
		ulong x,
    	ulong y,
    	ulong w,
    	ulong h,
    	T o
    	)
    {
    	auto res = calculateVisiblePart(
    		vp_x,
    		vp_y,
    		vp_w,
    		vp_h,
    		x,
    		y,
    		w,
    		h
    		);
    	if (!res[0])
    	{
    		return false;
    	}
    	
    	Visibility!(T) vis = new Visibility!(T)();
    	
    	vis.o = o;
    	vis.x=res[1];
    	vis.y=res[2];
    	vis.w=res[3];
    	vis.h=res[4];
    	vis.vx=res[5];
    	vis.vy=res[6];
    	
    	map ~= vis;
    	return true;
    }
	
	Tuple!(Visibility!(T), Position2D)[] getByPoint(
		Position2D point,
		bool only_last
		)
	{
		Tuple!(Visibility!(T), Position2D)[] ret;
		
		auto p_x = point.x;
		auto p_y = point.y;
		
		foreach_reverse (k, v; map)
		{
			if (
				p_x >= v.vx 
				&& p_x < v.vx+v.w

				&& p_y >= v.vy 
				&& p_y < v.vy+v.h
				)
			{
				ret = tuple(
					v, 
					Position2D(
						cast(int)(p_x - v.vx),
						cast(int)(p_y - v.vy)
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