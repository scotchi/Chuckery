#include(MidiHandler)
#include(MidiValues)

fun float instantaneousBpm(float bpmStart, float bpmEnd, float position)
{
    return ((bpmEnd - bpmStart) * position) + bpmStart;
    // return bpmEnd * position + bpmStart * (1.0 - position);
}

fun float durationInSeconds(float bpmStart, float bpmEnd, float beats)
{
    10000 => int resolution;

    0 => float sum;

    for(0 => int n; n < resolution; n++)
    {
        (n $ float) / (resolution $ float) => float position;

        instantaneousBpm(bpmStart, bpmEnd, position) => float bpmCurrent;

        (beats * 60.0) / (bpmCurrent * (resolution $ float)) +=> sum;
        // beats * (-bpmCurrent / bpmEnd + 1.5) +=> sum;
    }

    return sum;
}

fun float findStartBpm(float bpmConstant, float adjustedBeats, float constantBeats)
{
    0.001 => float delta;

    durationInSeconds(bpmConstant, bpmConstant, constantBeats) => float target;

    bpmConstant => float adjustment;

    bpmConstant => float bpmStart;

    while(Math.fabs(target - durationInSeconds(bpmStart, bpmConstant, adjustedBeats)) > delta)
    {
        adjustment / 2 => adjustment;

        if(durationInSeconds(bpmStart, bpmConstant, adjustedBeats) < target)
        {
            adjustment -=> bpmStart;
        }
        else
        {
            adjustment +=> bpmStart;
        }
    }

    <<< bpmStart >>>;

    return bpmStart;
}

fun float[] scaleBeatsInSeconds(float bpmConstant, int adjustedBeats, int constantBeats)
{
    findStartBpm(bpmConstant, adjustedBeats, constantBeats) => float bpmStart;

    float durations[adjustedBeats];

    for(0 => int i; i < adjustedBeats; i++)
    {
        (i $ float) / (adjustedBeats $ float) => float position;

        instantaneousBpm(bpmStart, bpmConstant, position) => float currentBpm;

        60.0 / currentBpm => float beatLength;

        beatLength => durations[i];
    }

    return durations;
}

scaleBeatsInSeconds(125, 7 * 4, 8 * 4) @=> float durations[];

<<< "Durations computed." >>>;

MidiHandler handler;

for(0 => int i; i < durations.cap(); i++)
{
    if(i > 0)
    {
        <<< durations[i], durations[i - 1] - durations[i] >>>;
    }
    else
    {
        <<< durations[i], 0.0 >>>;
    }

    handler.sendNote(2, midi["B1"], 100, durations[i]::second);
}

