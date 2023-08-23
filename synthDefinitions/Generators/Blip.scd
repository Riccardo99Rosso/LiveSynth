(
/*
Description:
Blip generator
*/

SynthDef(\Blip, {
	arg freq=440.0, numharm=1, mul=1.0, add=0.0, out=0;
	var sig;

	sig = Blip.ar(
		VarLag.kr(freq,0.1), 
		VarLag.kr(numharm,0.1), 
		VarLag.kr(mul,0.1), 
		VarLag.kr(add,0.1)
	);
	Out.ar(out,sig);
}).add;
)