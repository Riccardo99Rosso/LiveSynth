(
/*
Description:
Mono duplicator
*/

SynthDef(\MonoDup, {
	arg in=0, out1=0, out2=0, mul1=0.2, mul2=0.2;
	var sig;

	sig = In.ar(in);
	Out.ar(out1, sig * mul1);
	Out.ar(out2, sig * mul2);
}).add;
)