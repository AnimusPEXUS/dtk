module dtk.miscs.Channel;

import std.stdio;
import std.format;

import core.atomic;
import core.sync.mutex;
import core.sync.condition;
import core.sync.semaphore;

debug
{
    void prt(string s)
    {
        synchronized
        {
            writeln(s);
        }
    }
}

class Channel(T)
{
    private
    {
        T[] pool;
        Mutex pool_mx;
        // Mutex pull_mx;
        // Mutex push_mx;

        shared Condition cond;
        shared Mutex cond_mx;

        bool waiting;

        int pull_counter;
    }

    this()
    {
        cond_mx = new shared Mutex();
        // cond_mx.lock();
        cond = new shared Condition(cond_mx);

        pool_mx = new Mutex();
    }

    synchronized void push(T value)
    {
        prt("push --> (start)");
        scope (exit) prt("push <-- (exit)");
        synchronized (pool_mx)
        {
            pool ~= value;
            prt("   cond.notify()");
            cond.notify();
        }
    }

    synchronized T pull()
    {
        prt("pull --> (start %d)".format(pull_counter));
        scope (exit)
        {
            prt("pull <-- (exit %d)".format(pull_counter));
            atomicOp!"+="(this.pull_counter, 1);
        }

        T ret;

        while (pool.length == 0)
        {
            //cond_mx.lock();
            prt("   cond.wait()");
            cond.wait();
            prt("   cond.wait() exited");
        }

        synchronized (pool_mx)
        {
            auto pl = pool.length;

            ret = pool[0];

            if (pl == 1)
                pool = pool[0 .. 0];
            else
                pool = pool[1 .. $];
        }

        return ret;
    }
}

// class Channel(T)
// {
//     private
//     {
//         T[] pool;
//         bool unavailable;
//         Mutex pool_mx;

//         Condition cond;
//         Mutex cond_mx;

//         Mutex pull_mx;
//     }

//     this()
//     {
//         pool_mx = new Mutex();
//         cond_mx = new Mutex();
//         cond = new Condition(cond_mx);
//         pull_mx = new Mutex();
//     }

//     void push(T value)
//     {
//         synchronized (pool_mx)
//         {
//             pool ~= value;
//             cond.notify();
//         }
//     }

//     T pull()
//     {
//         synchronized (pull_mx)
//         {
//             T ret;

//             synchronized (pool_mx) {
//                 if (pool.length == 0)
//                 {
//                     cond_mx.lock();
//                     unavailable=true;
//                 }
//             }

//             if (unavailable)
//             {
//                 cond.wait();
//             }

//             synchronized (pool_mx)
//             {
//                 if (pool.length != 0)
//                 {
//                     ret = pool[0];
//                     pool = pool[1 .. $];
//                 }

//                 return ret;
//             }
//         }
//     }
// }