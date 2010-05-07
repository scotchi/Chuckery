#include (Arpegiator)

Arpegiator arp;
MidiHandler synth;

true => arp.local;
true => synth.local;

false => arp.descend;

1 => arp.inputChannel;
2 => arp.outputChannel;

synth @=> arp.output;

arp.sendNote(1, midi["C2"], 127, 60::second);

