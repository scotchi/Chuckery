#include (MidiHandler)
#include (Sequence)

class DrumVariator extends MidiHandler
{
    Sequence seq;

    5 => float chance;

    seq.setBPM(125);

    class Delayed
    {
        int pitch;
        int velocity;
        dur length;

        clear();

        fun void clear()
        {
            -1 => pitch;
            -1 => velocity;
        }

        fun int active()
        {
            return pitch >= 0;
        }
    }

    Delayed delayed;

    fun void noteOn(int channel, int pitch, int velocity)
    {
        if(channel != 2)
        {
            return;
        }

        (Std.fabs(Std.randf()) > 1.0 - (1.0 / chance)) => int doIt;
        
        if(pitch == seq.midi["D1"] && !delayed.active() && doIt)
        {
            pitch => delayed.pitch;
            velocity => delayed.velocity;
            seq.sixteenth => delayed.length;

            <<< "delaying beat" >>>;

            delayed.length => now;
        }

        NoteOnMessage on;

        3 => on.channel;
        pitch => on.pitch;
        velocity => on.velocity;

        send(on);
    }

    fun void noteOff(int channel, int pitch, int velocity)
    {
        if(channel != 2)
        {
            return;
        }

        if(delayed.pitch == pitch)
        {
            delayed.length => now;
            delayed.clear();
            <<< "resume" >>>;
        }

        NoteOffMessage off;

        3 => off.channel;
        pitch => off.pitch;
        velocity => off.velocity;

        send(off);
    }
}

DrumVariator v;
v.run();
