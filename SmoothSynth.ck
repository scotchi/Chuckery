#include(Control)

class SmoothSynth extends ControlDispatcher
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
