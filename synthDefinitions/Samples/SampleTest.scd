(
/*
Description:

*/

SynthDef(\SampleTest, {
	arg mul=1, out=0;
	var path, buf;
	path = Platform.resourceDir +/+ "sounds/personal/piano_loop.wav";
	path = path.asString;
	buf = Buffer.read(s, path);
	Out.ar( out,
		PlayBuf.ar(2, buf, BufRateScale.kr(buf), 			loop: 1, doneAction: 2)
		* VarLag.kr(mul, 0.1)
	)

}).add;
)