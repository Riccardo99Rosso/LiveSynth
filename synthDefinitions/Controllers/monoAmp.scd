(
/*
Description:

*/

SynthDef(\monoAmp, {
	arg amp=1, in=0, out=0;
	var sig;

	sig = In.ar(in);
	Out.ar(out, sig * amp);

}).add;
)