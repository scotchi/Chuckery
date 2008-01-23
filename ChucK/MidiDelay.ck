#include (MidiHandler)
#include (Sequence)

class MidiDelay extends MidiHandler
{
    Sequence sequence;

    sequence.setBPM(125);

    sequence.quarter * 6 * 59 => dur totalLength;
    sequence.quarter * 4 => dur totalDelay;

    time end;

    true => int first;

    fun dur delay()
    {
        if(first)
        {
            false => first;
            now + totalLength => end;
        }

        if(now > end)
        {
            return totalDelay;
        }

        return (1 - ((end - now) / totalLength)) * totalDelay;
    }

    fun void noteOn(int channel, int pitch, int velocity)
    {
        if(channel != 1)
        {
            return;
        }

        <<< delay() >>>;

        delay() => now;

        NoteOnMessage on;

        2 => on.channel;
        pitch => on.pitch;
        velocity => on.velocity;

        send(on);
    }

    fun void noteOff(int channel, int pitch, int velocity)
    {
        if(channel != 1)
        {
            return;
        }

        delay() => now;

        NoteOffMessage off;

        2 => off.channel;
        pitch => off.pitch;
        velocity => off.velocity;

        send(off);
    }
}

MidiDelay delay;
delay.run();
