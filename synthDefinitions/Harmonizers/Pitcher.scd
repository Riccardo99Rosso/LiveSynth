(
/*
Description:
Mono Pitcher
*/

SynthDef(\Pitcher, {
	arg drywet=1, windowSize=0.2, pitchRatio=1.0, pitchDispersion=0.0, 		
	timeDispersion=0.0, mul=1.0,  add=0.0, in=0, out=0;
    	var sig, sig2, dry, wet;

	sig = In.ar(in);
	sig2 = PitchShift.ar(sig, 
		VarLag.kr(windowSize,0.1), 
		VarLag.kr(pitchRatio,0.1), 
		VarLag.kr(pitchDispersion,0.1), 
		VarLag.kr(timeDispersion,0.1),
		VarLag.kr(mul,0.1),
		VarLag.kr(add,0.1)
	);

	wet = sig2 * drywet;
	dry = sig * (1 - drywet);
	sig = wet + dry;

	Out.ar(out, sig);
}).add;
)