(
var import, mainWin, mainGuiCreator;


/*** IMPORT DEFINITION ***/
import = {
	|path|
	var file;
	file = File.open(path.standardizePath, "r");
	this.interpret(file.readAllString);
};


/*** INIT ***/
~path = thisProcess.nowExecutingPath.replace("main.scd", "");
srcPath = ~path +/+ "src";
~mainGuiPath =  srcPath +/+ "mainGuiCreator.scd";
mainGuiCreator = import.(~mainGuiPath);
s = Server.local;

/*** GUI CREATION ***/
mainWin = mainGuiCreator[\mainWin].();

)