module dtk.miscs.Channel;

import core.sync.mutex;
import core.sync.condition;

synchronized class Channel(T)
{
    private
    {
        T[] pool;
        bool unavailable;
        Mutex pool_mx;

        Condition cond;
        Mutex cond_mx;

        Mutex pull_mx;
    }

    this()
    {
        pool_mx = new shared Mutex();
        cond_mx = new shared Mutex();
        cond = new shared Condition(cond_mx);
        pull_mx = new shared Mutex();
    }

    void push(T value)
    {
        synchronized (pool_mx)
        {
            pool ~= value;
            cond.notify();
        }
    }

    T pull()
    {
        synchronized (pull_mx)
        {
            T ret;

            synchronized (pool_mx) {
                if (pool.length == 0)
                {
                    cond_mx.lock();
                    unavailable=true;
                }
            }

            if (unavailable)
            {
                cond.wait();
            }

            synchronized (pool_mx)
            {
                if (pool.length != 0)
                {
                    ret = pool[0];
                    pool = pool[1 .. $];
                }

                return ret;
            }
        }
    }
}