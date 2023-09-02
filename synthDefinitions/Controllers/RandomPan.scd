(
/*
Description:

*/

SynthDef(\RandomPan, {
	arg variation=1, amp=1, in=0, out=0;
	var sig, level;
	
	sig = In.ar(in, 1);
	sig = Pan2.ar(sig, LFNoise2.kr(variation).range(-1, 1));
	Out.ar(out, sig * amp);

}).add;
)