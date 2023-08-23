(
/*
Description:
Volume slider for stereo signals
*/

SynthDef(\StereoMaster, {
	arg mul=1, in=0, out=0;
	var sig;

	sig = In.ar(in, 2);
	Out.ar(out, sig * VarLag.kr(mul, 0.1));
}).add;
)