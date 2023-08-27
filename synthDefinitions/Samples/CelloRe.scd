(
/*
Description:

*/

SynthDef(\CelloRe, {
	arg mul=1, out=0;
	var path, buf;
	path = "C:/Users/Riccardo/Desktop/STUDIO/METS/Comp3Lezioni/Progetto/Test/re.wav";
	path = path.asString;
	buf = Buffer.read(s, path);
	Out.ar( out,
		PlayBuf.ar(2, buf, BufRateScale.kr(buf), 			doneAction: 2, loop: 1)
		* VarLag.kr(mul, 0.1)
	)

}).add;
)