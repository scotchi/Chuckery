#include (MidiValues)

class Scale
{
    int steps[];
}

class ScaleIterator
{
    Scale @ scale;

    int root;
    int step;
    int pitch;

    setRoot(midi["C0"]);

    fun void setRoot(int value)
    {
        value => root;
        0 => step;
        value => pitch;
    }

    fun int next()
    {
        check();

        scale.steps[step++ % scale.steps.cap()] +=> pitch;

        if(pitch > 128)
        {
            previous() => pitch;
            <<< "Cannot increment to pitches over 127." >>>;
        }

        return pitch;
    }

    fun int previous()
    {
        check();

        scale.steps[step-- % scale.steps.cap()] -=> pitch;

        if(pitch < 0)
        {
            next() => pitch;
            <<< "Cannot decrement to pitches below 0." >>>;
        }

        return pitch;
    }

    fun void check()
    {
        if(scale == null)
        {
            <<< "No scale set." >>>;
            me.exit();
        }

        if(!scale.steps.cap())
        {
            <<< "Empty scale." >>>;
            me.exit();
        }
    }
}

Scale chromatic;

[ 1 ] @=> chromatic.steps;

Scale octatonic;

[ 1, 2 ] @=> octatonic.steps;

Scale hexatonic;

[ 3 ] @=> hexatonic.steps;
