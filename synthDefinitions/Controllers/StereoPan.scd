(
/*
Description:
Stereo panner: -1 = left, 1 = right
*/

SynthDef(\StereoPan, {
	arg pos=0, in=0, out=0;
	var sig, level;
	
	sig = In.ar(in, 1);
	sig = Pan2.ar(sig, VarLag.kr(pos, 0.1));
	Out.ar(out, sig);
}).add;
)