#include (MidiValues)
#include (MidiHandler)
#include (Scale)

class Arpegiator extends MidiHandler
{
    // public

    100::ms => dur noteLength;
    120::ms => dur noteSpacing;

    -1 => int inputChannel;
    1 => int outputChannel;

    true => int descend;

    2 => int steps;

    chromatic @=> Scale @ scale;

    MidiHandler @ output;

    // private

    int root;
    0 => int noteCount;

    setRoot(midi["C0"]);

    fun void setRoot(int pitch)
    {
        MidiValues.pitch(pitch) => root;
    }

    fun void noteOn(int channel, int pitch, int velocity)
    {
        if(inputChannel != -1 && channel != inputChannel)
        {
            return;
        }

        noteCount++;

        true => int ascending;

        ScaleIterator it;
        scale @=> it.scale;
        it.setRoot(MidiValues.build(MidiValues.adjustedOctave(pitch), root));

        while(noteCount > 0)
        {
            it.pitch => pitch;

            if(ascending)
            {
                it.next();

                if(it.step == steps)
                {
                    false => ascending;
                }
            }
            else
            {
                it.previous();

                if(it.step == 0)
                {
                    true => ascending;
                }
            }

            if(ascending || descend)
            {
                spork ~ output.sendNote(outputChannel, pitch, velocity, noteLength);
                noteSpacing => now;
            }
        }
    }

    fun void noteOff(int channel, int pitch, int velocity)
    {
        if(channel != -1 || channel != inputChannel)
        {
            return;
        }

        noteCount--;
    }
}
