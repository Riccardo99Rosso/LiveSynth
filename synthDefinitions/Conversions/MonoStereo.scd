(
/*
Description:
From Mono signal to Stereo signal
*/

SynthDef(\MonoStereo, {
	arg in=0, out=0;
	var sig;

	sig = In.ar(in);
	sig = sig.dup(2);
	Out.ar(out, sig);
}).add;
)