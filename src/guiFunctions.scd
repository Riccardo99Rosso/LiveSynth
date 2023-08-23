var dict = Dictionary();
var import, constants;

import = {
	|path|
	var file;
	file = File.open(path.standardizePath, "r");
	this.interpret(file.readAllString);
};

constants = import.(~constants);

dict;