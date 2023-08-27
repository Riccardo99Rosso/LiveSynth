(
/*
Description:

*/

SynthDef(\PitchShift, {
	arg windowSize=0.2, pitchRatio=1.0, pitchDispersion=0.0, 		timeDispersion=0.0, mul=1.0,  add=0.0, in=0, out=0;
    	var sig;

	sig = In.ar(in);
	sig = PitchShift.ar(sig, 
		VarLag.kr(windowSize,0.1), 
		VarLag.kr(pitchRatio,0.1), 
		VarLag.kr(pitchDispersion,0.1), 
		VarLag.kr(timeDispersion,0.1),
		VarLag.kr(mul,0.1),
		VarLag.kr(add,0.1)
	);
	Out.ar(out, sig);
}).add;
)