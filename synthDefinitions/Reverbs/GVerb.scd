(
/*
Description:
GVerb implementation
*/

SynthDef(\GVerb, {
	arg roomsize=10, revtime=3, damping=0.5, inputbw=0.5, 
	spread=15, drylevel=1,
	earlyreflevel=0.7, taillevel=0.5, maxroomsize=300, mul=1, 
	add=0, in=0, out=0;
	var sig;
	
	sig = In.ar(in);
	sig = GVerb.ar(sig, 
		VarLag.kr(roomsize,0.1), 
		VarLag.kr(revtime,0.1),
		VarLag.kr(damping,0.1),
		VarLag.kr(inputbw,0.1),
		VarLag.kr(spread,0.1),
		VarLag.kr(drylevel,0.1),
		VarLag.kr(earlyreflevel,0.1),
		VarLag.kr(taillevel,0.1),
		VarLag.kr(maxroomsize,0.1),
		VarLag.kr(mul,0.1),
		VarLag.kr(add,0.1),
	);
	Out.ar(out, sig)
}).add;
)