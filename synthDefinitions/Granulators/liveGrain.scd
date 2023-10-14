(
/*
Description:

*/

SynthDef(\liveGrain, { |drywet=1, out, in, envBuf, trigRate = 50, overlap = 0.5, panMax = 0.5,
    panType = 0, amp = 1, minGDur = 0.001|
    var inSig, sig, trig, grainDur, pan, dry, wet;
	
	inSig = In.ar(in);
    	// reduce feedback
    	inSig = DelayC.ar(LPF.ar(inSig.tanh, 2000), 0.1, 0.01);

    	trig = Impulse.ar(trigRate);
    	grainDur = max(trigRate.reciprocal * overlap, minGDur);

    	// select L/R or random sequencing
    	/*pan = Demand.ar(
        	trig,
        	0,
        	Dswitch1([
            	Dseq([1, -1], inf),
            	Dwhite(-1, 1)
        	], panType)
    	) * min(panMax, 0.999);
	*/

    	wet = GrainIn.ar(
        	2,
        	trig,
        	grainDur,
        	inSig,
       	 0,
        	envBuf
    	);

	wet = wet * drywet;
	dry = inSig * (1 - drywet); 
	sig = wet + dry;

    	Out.ar(out, sig * EnvGate.new * amp);
}).add;
)