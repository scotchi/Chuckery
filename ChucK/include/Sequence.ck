#include (MidiHandler)
#include (MidiValues)

class Sequence
{
    float bpm;

    dur whole;
    dur half;
    dur quarter;
    dur eigth;
    dur sixteenth;

    false => int notesAdvanceTime;

    1 => int channel;

    setBPM(130.0);

    MidiHandler @ output;

    fun void setBPM(float beats)
    {
        beats => bpm;

        (1::minute / bpm * 4) => whole;

        whole / 2  => half;
        whole / 4  => quarter;
        whole / 8  => eigth;
        whole / 16 => sixteenth;
    }

    fun dur dotted(dur original)
    {
        return 1.5 * original;
    }

    fun dur tripplet(dur original)
    {
        return 2.0 / 3.0 * original;
    }

    fun void backgroundNote(int pitch, int velocity, dur length)
    {
        if(output == null)
        {
            <<< "no midi handler set" >>>;
            me.exit();
        }

        NoteOnMessage on;
        velocity => on.velocity;
        pitch => on.pitch;
        channel => on.channel;

        output.send(on);

        length => now;

        NoteOffMessage off;

        pitch => off.pitch;
        channel => off.channel;

        output.send(off);
    }

    fun void note(int pitch, int velocity, dur length)
    {
        if(notesAdvanceTime)
        {
            backgroundNote(pitch, velocity, length);
        }
        else
        {
            spork ~ backgroundNote(pitch, velocity, length);
        }
    }

    fun void note(int pitch, dur length)
    {
        note(pitch, 127, length);
    }

    fun void play()
    {
        <<< "empty sequence" >>>;
    }
}
