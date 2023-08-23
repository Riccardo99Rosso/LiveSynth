(
/*
Description:
Mono In
*/

SynthDef(\In, {
	arg in=0, out=0;
	var sig;
	
	sig = In.ar(in);
	Out.ar(out, sig);
}).add;
)