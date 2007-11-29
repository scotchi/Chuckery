#include(Control)
#include(Sequence)

class Synth extends ControlDispatcher
{
    SinOsc bank;
    ADSR envelope;

    -1    => int lastPitch;
    false => int isPlaying;
    300   => int glideLengthInMs;

    init();

    fun void init()
    {
        // init oscilators

        0 => bank.gain;

        // init envelope

        30::ms => envelope.attackTime;
        // 3 => envelope.attackRate;
        // 20::ms => envelope.decayTime;
        // 1.0 => envelope.decayRate;
        0.7 => envelope.sustainLevel;
        160::ms => envelope.releaseTime;
        // 1.0 => envelope.releaseRate;
        
        // setup route

        bank => envelope => dac;
    }

    fun void noteOn(int pitch, int velocity)
    {
        (Std.mtof(pitch) != bank.freq() && isPlaying) => int doGlide;

        pitch => lastPitch;
        true => isPlaying;

        if(doGlide)
        {
            glide(pitch, velocity);
        }
        else
        {
            attack(pitch, velocity);
        }
    }

    fun void noteOff(int pitch, int velocity)
    {
        if(pitch == lastPitch)
        {
            -1 => lastPitch;

            // Give the system a little time to wait for another note on.

            10::ms => now;

            if(lastPitch == -1)
            {
                false => isPlaying;
                envelope.keyOff();
            }
        }
    }

    fun void glide(int pitch, int velocity)
    {
        // <<< "glide" >>>;

        bank.freq() => float oldFreq;
        bank.gain() => float oldGain;

        Std.mtof(pitch)  => float newFreq;
        velocity / 127.0 => float newGain;

        for(1 => int i; i <= glideLengthInMs && pitch == lastPitch; i++)
        {
            (i $ float) / (glideLengthInMs $ float) => float coef;

            Math.pow(coef, 3);

            (1.0 - coef) * oldFreq + coef * newFreq => bank.freq;
            (1.0 - coef) * oldGain + coef * newGain => bank.gain;

            1::ms => now;
        }
    }

    fun void attack(int pitch, int velocity)
    {
        // <<< "attack" >>>;

        Std.mtof(pitch) => bank.freq;
        velocity / 127.0 => bank.gain;

        envelope.keyOn();
    }
}

class BassLine extends Sequence
{
    Synth synth;

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
    Synth s;
    s.run();
}
