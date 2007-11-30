#include (Control)
#include (Sequence)
#include (SmoothSynth)

class BassLine extends Sequence
{
    SmoothSynth synth;

    synth @=> output;

    true => synth.local;
    true => notesAdvanceTime;

    fun void play()
    {
        note(midi["C1"], quarter);

        note(midi["C1"], eigth);

        note(midi["C2"], eigth);

        note(midi["C1"], quarter);

        quarter => now;
    }
}

class Melody extends BassLine
{
    fun void play()
    {
        note(midi["C4"], eigth);
        eigth => now;
        note(midi["G4"], eigth);
        note(midi["G#4"], sixteenth);
        note(midi["A4"], sixteenth);
        half => now;
    }
}

class Beat extends BassLine
{
    true => notesAdvanceTime;

    10::ms => synth.envelope.attackTime;
    10::ms => synth.envelope.releaseTime;

    fun void play()
    {
        quarter => now;

        note(midi["C6"], sixteenth);

        dotted(eigth) => now;
        quarter => now;

        note(midi["C6"], sixteenth);

        dotted(eigth) => now;
    }
}

if(true)
{
    BassLine bass;
    Melody melody;
    Beat beat;

    while(true)
    {
        spork ~ beat.play();
        spork ~ melody.play();
        bass.play();
    }
}
else
{
    SmoothSynth s;
    s.run();
}
