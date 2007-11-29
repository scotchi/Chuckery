#include (MidiHandler)
#include (Sequence)
#include (Control)

MidiHandler handler;

class DrumLine extends Sequence
{
    setBPM(300);

    handler @=> output;

    true => notesAdvanceTime;
    3 => channel;

    midi["D1"] => int bass;
    midi["B1"] => int snare;
    midi["F#1"] => int hihat;
}

class Line1 extends DrumLine
{
    fun void playBass()
    {
        note(bass, quarter);
        note(bass, quarter);
        note(bass, quarter);
        note(bass, quarter);
    }

    fun void playAccent()
    {
        quarter => now;
        quarter => now;
        note(snare, eigth);
        note(snare, eigth);
        quarter => now;
    }

    fun void play()
    {
        spork ~ playAccent();
        playBass();
    }
}

class Line2 extends Line1
{
    fun void playBass()
    {
        note(bass, quarter);
        note(bass, quarter);
        note(bass, eigth);
        note(bass, eigth);
    }

    fun void playAccent()
    {
        quarter => now;
        note(snare, eigth);
        note(snare, eigth);
        quarter => now;
    }
}

class Line3 extends Line1
{
    fun void playBass()
    {
        note(bass, tripplet(half));
        note(bass, tripplet(half));
        note(bass, tripplet(half));
    }

    fun void playAccent()
    {
        quarter => now;
        note(snare, quarter);
        quarter => now;
        note(snare, quarter);
    }
}

class Line4 extends Line1
{
    fun void playBass()
    {
        // just let it continue to the next
    }

    fun void playAccent()
    {
        now + whole => time end;

        1 => float f;

        while(now < end && eigth / f > 5::ms)
        {
            note(hihat, eigth / f);
            1.0 +=> f;
        }
    }
}

Line1 line1;
Line2 line2;
Line3 line3;
Line4 line4;

Sequence patterns[10];

line1 @=> patterns[0];
line2 @=> patterns[1];
line3 @=> patterns[2];
line4 @=> patterns[3];

4 => int patternCount;

ControlDispatcher dispatcher;
dispatcher.open(1, 1);

class PatternSelector extends Control
{
    10 => cc;

    1 => int last;

    fun void set(int value)
    {
        (value $ float / 128.0 * (patternCount $ float)) $ int => last;
    }
}

PatternSelector selector;

spork ~ dispatcher.run();

while(true)
{
    Std.rand2(0, selector.last) => int slot;

    // <<< "Pattern: ", slot >>>;

    patterns[slot].play();
}

