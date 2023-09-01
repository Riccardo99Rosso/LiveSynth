(
/*
Description:

*/

SynthDef(\WhiteNoise, {
	arg mul=0, add=0, out=0;
	var sig;

	sig = WhiteNoise.ar(
		VarLag.kr(mul, 0.1),
		VarLag.kr(add, 0.1)
	);

	Out.ar(out, sig);
}).add;
)