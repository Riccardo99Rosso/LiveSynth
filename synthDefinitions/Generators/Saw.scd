(
/*
Description:
Sawtooth wave Oscillator
*/

SynthDef(\Saw, {
	arg freq=440,mul=0.5,add=0.0,out=0;
	var sig;

	sig = Saw.ar(
		VarLag.kr(freq,0.1), 
		VarLag.kr(mul,0.1), 
		VarLag.kr(add,0.1)
	);
	Out.ar(out,sig);
}).add;
)