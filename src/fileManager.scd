var dict = Dictionary();
var import, constants, synthsManager;
var saveSession, openSession;

import = {
	|path|
	var file, content;
	file = File.open(path.standardizePath, "r");
	content = file.readAllString;
	file.close;
	this.interpret(content);
};

constants = import.(~constants);
synthsManager = import.(~synthsManager);

saveSession = {
	arg mainPath;
	var file, tmpGroups, generalDict = Dictionary(), dirOk;

	mainPath = mainPath.replace(".ls", "");
	mainPath = mainPath ++ ".ls";
	mainPath = PathName(mainPath);

	tmpGroups = ~groups;
	generalDict.put(\software, "LiveSynth");
	generalDict.put(\version, "0.0.1");

	file = File(mainPath.fullPath.standardizePath, "w");
	file.write(generalDict.asCompileString);
	file.write("^");
	file.write(tmpGroups.asCompileString.replace("'play' -> true", "'play' -> false"));
	file.write("^");
	file.write(~midiMaps.asCompileString);
	file.close;

	mainPath.fileNameWithoutExtension;
};

openSession = {
	arg mainPath, controlSliders, slidersLabel,
	maxSliders, minSliders, slidersValue, inspector, inspectorComponents,
	synthsList;
	var return, file, toParse, list = [], tmpGroups, maxId = 0;

	mainPath = PathName(mainPath);

	if(mainPath.extension == "ls",
		{

			file = File(mainPath.fullPath.standardizePath, "r");
			toParse = file.readAllString;
			toParse = toParse.replace("Group.new", 0);
			toParse = toParse.split($^);
			file.close;

			~groups = this.interpret(toParse[1]);
			~midiMaps = this.interpret(toParse[2]);
			tmpGroups = ~groups;
			tmpGroups.do({
				arg item, i;
				if(item[0][\id] > maxId){
					maxId = item[0][\id];
				};
			});

			~id = maxId + 1;
			if(~groups.size != 0,{

				~idForMap = 0;
				~groups = ~groups.do({
					arg item, i;
					var group, name, id;
					list = list.add(item[0][\name]);

					if(item[0][\midiPlay] >= 0, {
						name = "midiPlay" ++
						item[0][\midiPlay].asString;
						name = name.asSymbol;

						id = item[0][\id];

						MIDIdef.cc(name, {
							arg ...args;
							var pos;

							if(args[0] == 127,
								{
									var synth, argValueList;

									~groups.do({
										arg obj, j;
										if(id == obj[0][\id]){
											pos = j;
										}
									});

									if((~groups[pos][0][\maxInstances] == 1
										&& ~groups[pos][0][\play] == false) ||
									(~groups[pos][0][\maxInstances] == "inf")
									,{

										synth = Synth(~groups[pos][0][\name],
											target: ~groups[pos][0][\group]);
										argValueList = ~groups[pos][1];
										argValueList.do({
											arg dict;
											synth.set(dict[\control], dict[\value])
										});

										~groups[pos][0][\play] = true;
										if(~groups[~idForMap][0][\id] == id, {
											{
												synthsList.valueAction_(pos);
											}.defer;
										});
									});
								}
							);

						}, item[0][\midiPlay]);
					});

					if(item[0][\midiFree] >= 0, {
						name = "midiFree" ++
						item[0][\midiFree].asString;
						name = name.asSymbol;

						id = item[0][\id];


						MIDIdef.cc(name, {
							arg ...args;
							var pos;

							if(args[0] == 127,
								{
									~groups.do({
										arg item, j;
										if(id == item[0][\id]){
											pos = j;
										}
									});

									~groups[pos][0][\group].freeAll;
									~groups[pos][0][\play] = false;
									if(~groups[~idForMap][0][\id] == id, {
										{
											synthsList.valueAction_(pos);
										}.defer;
									});
								}
							);

						}, item[0][\midiFree]);
					});
				});

				synthsList.items_(list);
				synthsManager[\hideSliders].(controlSliders, slidersLabel,
					maxSliders, minSliders, slidersValue);
				synthsManager[\synthSelected].(0, controlSliders, slidersLabel,
					maxSliders, minSliders,
					slidersValue, inspector, inspectorComponents);
			});
			return = mainPath.fileNameWithoutExtension;
		},
		{
			return = nil;
		}
	);

	[return];
};

dict.put(\saveSession, saveSession);
dict.put(\openSession, openSession);

dict;