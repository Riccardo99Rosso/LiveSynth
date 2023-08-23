var dict = Dictionary();
var import, constants, keyCode, fontName, fontSize;
var synthEditor, snippet, loadAll, searchSynthWin, searchSynthField,
searchSynthList, synthSearchAction, synthAddAction, synthRemoveAction,
synthSelected, hideSliders, showOnInspector;

import = {
	|path|
	var file, content;
	file = File.open(path.standardizePath, "r");
	content = file.readAllString;
	file.close;
	this.interpret(content);
};

constants = import.(~constants);
keyCode = import.(~keyCode);

snippet = {
	arg name="";
	var text;

	text = "(
/*
Description:

*/

SynthDef(\\" ++ name ++ ", {

//insert your code here

}).add;
)";

	text;
};

synthEditor = {
	arg menu;
	var left, top, editor;
	var allSynthsPath = PathName(constants[\synthsPath].standardizePath);
	var paths = Dictionary(), synths = Dictionary(), synthsPath = Dictionary();
	var files, typeList, synthList, tempList, codeEditor, synthsMenu,
	codeMenu, newBtn, deleteBtn, saveBtn, fontName, fontSize, currentSaveColor,
	newWin, synthsInit, deleteWin;

	left = menu.absoluteBounds.left;
	top = menu.absoluteBounds.top;
	fontName = constants[\synthsEditorListFont].name;
	fontSize = constants[\synthsEditorListFont].size;
	currentSaveColor = constants[\synthEditorSavedColor];

	synthsMenu = UserView().fixedHeight_(25);
	newBtn = StaticText(synthsMenu, Rect(20, 0, 40, 25))
	.string_("New")
	.stringColor_(constants[\menuStringColor])
	.font_(constants[\mainToolBarMenuFont])
	.mouseOverAction_({
		newBtn.stringColor_(constants[\menuStringSelectedColor]);
		newBtn.font_(constants[\mainToolBarMouseOnFont]);
	})
	.mouseLeaveAction_({
		newBtn.stringColor_(constants[\menuStringColor]);
		newBtn.font_(constants[\mainToolBarFont]);
	})
	.mouseDownAction_({
		var left, top;
		var folderString, folderMenu, newSynth, items, newFolder,
		nameText, newSynthBtn, index, newVal;

		left = newBtn.absoluteBounds.left;
		top = newBtn.absoluteBounds.top;

		newWin = Window("New Synth")
		.setTopLeftBounds(Rect(left+5, top+5, 450, 150))
		.background_(constants[\mainBackground])
		.acceptsMouseOver_(true)
		.alwaysOnTop_(true)
		.front;

		folderString = StaticText(newWin, Rect(10, 12, 70, 30))
		.stringColor_(constants[\synthEditorListStringColor])
		.string_("Folder: ")
		.font_(constants[\popUpFont]);

		items = [];
		items = typeList.items;

		folderMenu = PopUpMenu(newWin, Rect(70, 14, 120, 30))
		.background_(constants[\viewBackground])
		.canFocus_(false)
		.items_(items)
		.value_(typeList.value)
		.stringColor_(typeList.stringColor)
		.font_(constants[\popUpFont]);

		newFolder = TextField(newWin, Rect(210, 14, 120, 30))
		.background_(constants[\viewBackground])
		.stringColor_(constants[\synthEditorListStringColor])
		.string_("")
		.font_(constants[\popUpFont])
		.keyUpAction_({
			if(newFolder.string != "",
				{
					newFolder.background_(constants[\newFolderColor]);
				},
				{
					newFolder.background_(constants[\viewBackground]);
				}
			);
		});

		nameText = StaticText(newWin, Rect(10, 57, 70, 30))
		.stringColor_(constants[\synthEditorListStringColor])
		.string_("Name: ")
		.font_(constants[\popUpFont]);

		newSynth = TextField(newWin, Rect(70, 59, 120, 30))
		.background_(constants[\viewBackground])
		.stringColor_(constants[\synthEditorListStringColor])
		.string_("")
		.font_(constants[\popUpFont])
		.keyUpAction_({
			if(newSynth.string != "",
				{
					newSynth.background_(constants[\newFolderColor]);
				},
				{
					newSynth.background_(constants[\viewBackground]);
				}
			);
		});

		newSynthBtn = Button(newWin, Rect(150, 104, 150, 30))
		.font_(constants[\popUpFont])
		.canFocus_(false)
		.states_([["New",
			constants[\synthEditorListStringColor],
			constants[\newFolderColor]
		]])
		.mouseOverAction_({
			newSynthBtn.font_(constants[\buttonMouseOnFont]);
			newSynthBtn.states_([["New", constants[\menuStringSelectedColor],
				constants[\viewBackground]]])
		})
		.mouseLeaveAction_({
			newSynthBtn.font_(constants[\buttonFont]);
			newSynthBtn.states_([["New", constants[\synthEditorListStringColor],
				constants[\newFolderColor]]])
		})
		.action_({
			var newPath, file;
			if(newSynth.string != "",
				{
					var folder;
					if(newFolder.string != "",
						{
							folder = newFolder.string;
						},
						{
							folder = folderMenu.item;
						}
					);
					newPath = allSynthsPath.fullPath ++ "/"
					++ folder;
					File.mkdir(newPath.standardizePath);
					newPath = newPath ++ "/" ++ newSynth.string ++ ".scd";
					newPath = PathName(newPath.standardizePath);
					file = File(newPath.fullPath, "w");
					file.write(snippet.(newSynth.string));
					file.close;
					synthsInit.();
					index = 0;
					newVal = 0;
					typeList.items.do({
						arg item;
						if(item.asString == folder.asString){
							newVal = index;
						};
						index = index + 1;
					});
					typeList.valueAction_(newVal);
					index = 0;
					newVal = 0;
					synthList.items.do({
						arg item;
						if(item.asString == newSynth.string){
							newVal = index;
						};
						index = index + 1;
					});
					synthList.valueAction_(newVal);
				};
			);
			newWin.close;
		});

	});

	deleteBtn = StaticText(synthsMenu, Rect(75, 0, 50, 25))
	.string_("Delete")
	.stringColor_(constants[\menuStringColor])
	.font_(constants[\mainToolBarMenuFont])
	.mouseOverAction_({
		deleteBtn.stringColor_(constants[\menuStringSelectedColor]);
		deleteBtn.font_(constants[\mainToolBarMouseOnFont]);
	})
	.mouseLeaveAction_({
		deleteBtn.stringColor_(constants[\menuStringColor]);
		deleteBtn.font_(constants[\mainToolBarFont]);
	})
	.mouseDownAction_({
		var msgText, synthName, delete;

		deleteWin = Window("Delete")
		.setTopLeftBounds(Rect(left+5, top+5, 200, 100))
		.background_(constants[\mainBackground])
		.acceptsMouseOver_(true)
		.alwaysOnTop_(true)
		.front;

		msgText = StaticText(deleteWin, Rect(30, 0, 70, 50))
		.stringColor_(constants[\synthEditorListStringColor])
		.string_("Delete ")
		.font_(constants[\popUpFont]);

		synthName = StaticText(deleteWin, Rect(80, 0, 150, 50))
		.stringColor_(constants[\synthEditorNotSavedColor])
		.string_(synthList.items[synthList.value])
		.font_(constants[\popUpFont]);

		delete = Button(deleteWin, Rect(50, 50, 100, 30))
		.font_(constants[\popUpFont])
		.canFocus_(false)
		.states_([["Delete",
			constants[\synthEditorListStringColor],
			constants[\synthEditorNotSavedColor]
		]])
		.mouseOverAction_({
			delete.font_(constants[\buttonMouseOnFont]);
			delete.states_([["Delete", constants[\menuStringSelectedColor],
				constants[\viewBackground]]])
		})
		.mouseLeaveAction_({
			delete.font_(constants[\buttonFont]);
			delete.states_([["Delete", constants[\synthEditorListStringColor],
				constants[\synthEditorNotSavedColor]]])
		})
		.action_({
			var file, selection;

			selection = synthList.value;
			editor.close;
			file = File.delete(
				synthsPath[synthList.items[selection]].fullPath);
			synthEditor.(menu).front;
		});
	});

	codeMenu = UserView().fixedHeight_(25);
	saveBtn = StaticText(codeMenu, Rect(20, 0, 50, 25))
	.string_("Save")
	.stringColor_(currentSaveColor)
	.font_(constants[\mainToolBarMenuFont])
	.mouseOverAction_({
		saveBtn.stringColor_(constants[\menuStringSelectedColor]);
		saveBtn.font_(constants[\mainToolBarMouseOnFont]);
	})
	.mouseLeaveAction_({
		saveBtn.stringColor_(currentSaveColor);
		saveBtn.font_(constants[\mainToolBarFont]);
	})
	.mouseDownAction_({
		var synth, path, file;
		currentSaveColor = constants[\synthEditorSavedColor];
		saveBtn.stringColor_(currentSaveColor);
		synth = synthList.items[synthList.value];
		path = synthsPath[synth];
		file = File(path.fullPath.standardizePath, "w");
		file.write(codeEditor.string);
		file.close;
	});

	editor = Window("Synths editor")
	.setTopLeftBounds(Rect(left+5, top+5, 700, 400))
	.background_(constants[\mainBackground])
	.acceptsMouseOver_(true)
	.alwaysOnTop_(true)
	.view.keyDownAction_({
		arg doc, char, mod, unicode, kc, key;

		if(((mod == keyCode[\ctrl]) && (key == keyCode[\plusZoom])),
			{
				fontSize = fontSize + 2;
				codeEditor.font_(Font(fontName, fontSize));
			}
		);
		if(((mod == keyCode[\ctrl]) && (key == keyCode[\minusZoom])),
			{
				fontSize = fontSize - 2;
				codeEditor.font_(Font(fontName, fontSize));
			}
		);

		//[doc, char, mod, unicode, kc, key].postln
	})
	.onClose_({
		if(newWin != nil,
			{
				newWin.close;
			}
		);
		if(deleteWin != nil,
			{
				deleteWin.close;
			}
		);
		loadAll.();
	});

	codeEditor = TextView()
	.palette_(QPalette.dark)
	.font_(constants[\synthsEditorCodeFont])
	.keyDownAction_({
		arg doc, char, mod, unicode, kc, key;
		if(mod == 0,
			{
				currentSaveColor = constants[\synthEditorNotSavedColor];
				saveBtn.stringColor_(currentSaveColor);
			}
		);
		//[doc, char, mod, unicode, kc, key].postln
	});

	typeList = ListView()
	.background_(constants[\viewBackground])
	.font_(constants[\synthsEditorListFont])
	.stringColor_(constants[\synthEditorListStringColor])
	.selectedStringColor_(constants[\synthEditorListStringColor])
	.hiliteColor_(constants[\synthEditorListHiliteColor])
	.fixedWidth_(110)
	.action_({
		arg sbs;
		var value, name;
		value = sbs.value;
		name = typeList.items[sbs.value];

		tempList = [];
		synths.keysValuesDo({
			arg key, value;
			if(value.asString == name.asString,
				{
					tempList = tempList.add(key);
				}
			);
		});
		synthList.items_(tempList);
		synthList.valueAction_(0);
	});
	synthList = ListView()
	.background_(typeList.background)
	.stringColor_(typeList.stringColor)
	.selectedStringColor_(typeList.selectedStringColor)
	.hiliteColor_(typeList.hiliteColor)
	.font_(typeList.font)
	.fixedWidth_(110)
	.action_({
		arg sbs;
		var value, name, codePath, file;

		value = sbs.value;
		name = synthList.items[sbs.value];
		codePath = synthsPath[name];
		currentSaveColor = constants[\synthEditorSavedColor];
		saveBtn.stringColor_(currentSaveColor);

		file = File(codePath.fullPath, "r");
		codeEditor.string_(file.readAllString);
		file.close;
	});

	editor.layout_(
		HLayout(
			VLayout(
				synthsMenu,
				HLayout(typeList, synthList)
			), VLayout(codeMenu, codeEditor)
	).spacing_(0).margins_(0));

	synthsInit = {
		allSynthsPath.filesDo{
			arg synthPath;
			var folder, file;

			file = synthPath.fileNameWithoutExtension;
			folder = synthPath.folderName;
			paths.put(folder.asSymbol, synthPath.pathOnly);
			synths.put(file, folder);
			synthsPath.put(file, synthPath);
		};

		tempList = [];
		paths.keysValuesDo({
			arg key, value;
			tempList = tempList.add(key);
		});
		typeList.items_(tempList);

		tempList = [];
		synths.keysValuesDo({
			arg key, value;
			if(value.asString == typeList.items[0].asString,
				{
					tempList = tempList.add(key);
				}
			);
		});
		synthList.items_(tempList);
	};

	synthsInit.();
	synthList.valueAction_(0);
	editor;
};

loadAll = {
	var allSynthsPath = PathName(constants[\synthsPath].standardizePath);
	~synths = [];
	allSynthsPath.filesDo{
		arg synthPath;
		var folder, name, file, path, content;

		name = synthPath.fileNameWithoutExtension;
		~synths = ~synths.add(name);
		path = synthPath.fullPath.standardizePath;
		file = File(path, "r");
		content = file.readAllString;
		file.close;
		this.interpret(content);
	};
};

searchSynthWin = {
	arg menu;
	var win, left, top;

	left = menu.absoluteBounds.left;
	top = menu.absoluteBounds.top;
	win = Window("Synths", border: false)
	.setTopLeftBounds(Rect(left, top-15, 200, 200))
	.background_(constants[\mainBackground])
	.alwaysOnTop_(true)
	.view.keyDownAction = {
		|doc, char, mod, unicode, keycode, key|
		if(key == keyCode[\esc],{
			win.close;
		});
	};

	win;
};

searchSynthField = {
	var field;

	field = TextField()
	.font_(constants[\popUpFont])
	.background_(constants[\mainBackground])
	.stringColor_(constants[\menuStringSelectedColor]);

	field;
};

searchSynthList = {
	var list;

	list = ListView()
	.font_(constants[\popUpFont])
	.background_(constants[\mainBackground])
	.stringColor_(constants[\menuStringSelectedColor])
	.items_(~synths)
	.value_(-1);

	list;
};

synthSearchAction = {
	arg searchSynthList, searchSynthField;
	var written, items, newItems = [];

	written = searchSynthField.string;
	items = ~synths;
	items.do({
		arg item;
		if(item.findAllRegexp(written)[0] == 0,
			{
				newItems = newItems.add(item);
			}
		)
	});
	searchSynthList.items_(newItems);
	if(written == "",
		{
			searchSynthList.items_(~synths.sort);
		}
	);
	searchSynthList.value_(nil);
};

synthAddAction = {
	arg sel, searchSynthList, synthsList, searchSynthWin,
	controlSliders, slidersLabel, maxSliders, minSliders, slidersValue,
	inspector, inspectorComponents;
	var synthIndex, synthName, list, synthAsSymbol, synthControls,
	synthControlDict, synthControlsList = [], idDict;

	synthIndex = sel.value;
	synthName = searchSynthList.items[synthIndex];
	list = synthsList.items;
	if(list == nil){
		list = [];
	};
	list = list.addFirst(synthName);
	synthsList.items_(list);
	searchSynthWin.close;

	synthAsSymbol = synthName.asSymbol;
	synthControls = SynthDescLib.global.at(synthAsSymbol).controls;

	synthControls.do({
		arg item;
		synthControlDict = Dictionary();
		synthControlDict.put(\value, item.defaultValue);
		synthControlDict.put(\noNumValue, "");
		synthControlDict.put(\control, item.name);
		synthControlDict.put(\warp, \linear);
		synthControlDict.put(\min, 0);
		synthControlDict.put(\max, 1);
		synthControlDict.put(\visible, true);
		synthControlDict.put(\number, true);
		synthControlDict.put(\midiCtrl, -1);
		synthControlsList = synthControlsList.add(synthControlDict);
	});

	idDict = Dictionary();
	idDict.put(\name, synthAsSymbol);
	idDict.put(\id, ~id);
	idDict.put(\play, false);
	idDict.put(\midiPlay, -1);
	idDict.put(\midiFree, -1);
	idDict.put(\maxInstances, 1);
	idDict.put(\group, Group());
	idDict.put(\rect, Rect(10, 10, constants[\rectSize], constants[\rectSize]));
	~linkerView.refresh;

	~groups = ~groups.addFirst([idDict, synthControlsList]);
	~id = ~id + 1;
	hideSliders.(controlSliders, slidersLabel,
		maxSliders, minSliders, slidersValue);
	synthSelected.(0, controlSliders, slidersLabel,
		maxSliders, minSliders, slidersValue, inspector, inspectorComponents);
};

synthSelected = {
	arg selected, controlSliders, slidersLabel,
	maxSliders, minSliders, slidersValue, inspector, inspectorComponents;
	var sliderSpec;


	~groups[selected][1].do({
		arg argument, i;
		if(argument[\number] == true,{
			if(argument[\visible] == true,{
				controlSliders[i].visible_(true);
				maxSliders[i].
				visible_(true).
				string_(argument[\max]);
				minSliders[i].
				visible_(true).
				string_(argument[\min]);
			});
			maxSliders[i].mouseDownAction_({
				inspector.visible_(true);
				showOnInspector.(selected, i,
					argument, controlSliders[i], inspectorComponents,
					maxSliders[i], minSliders[i], inspectorComponents[\maxBox],
					controlSliders
				);
			});
			minSliders[i].mouseDownAction_({
				inspector.visible_(true);
				showOnInspector.(selected, i,
					argument, controlSliders[i], inspectorComponents,
					maxSliders[i], minSliders[i], inspectorComponents[\minBox],
					controlSliders
				);
			});
			slidersLabel[i]
			.visible_(true)
			.string_(argument[\control])
			.mouseDownAction_({
				inspector.visible_(true);
				showOnInspector.(selected, i,
					argument, controlSliders[i], inspectorComponents,
					maxSliders[i], minSliders[i], nil,
					controlSliders
				);
			});
			slidersValue[i].
			visible_(true)
			.background_(constants[\viewBackground])
			.keyDownAction_({
				slidersValue[i].background_(constants[\notActionedColor]);
			})
			.action_({
				var val = slidersValue[i].value.asFloat;
				slidersValue[i].background_(constants[\viewBackground]);
				if(argument[\warp] == \linear,{
					controlSliders[i].value_(val.linlin(
						argument[\min], argument[\max], 0.00, 1.00));
				});
				if(argument[\warp] == \exp,{
					controlSliders[i]
					.value_(val.explin(
						argument[\min], argument[\max], 0.00, 1.00));
				});
				if(argument[\warp] == \decibel,{
					var value;
					value = val;
					sliderSpec = ControlSpec(0.001, 1, \exp, 0.001);
					value = sliderSpec.unmap(value);
					controlSliders[i].value_(value);
				});
				controlSliders[i].background_(constants[\slidersMinColor].blend(
					constants[\slidersMaxColor],
					controlSliders[i].value));
				~groups[selected][1][i][\value] = val;
				~groups[selected][0][\group].set(
					argument[\control], val);
			})
			.value_(argument[\value].trunc(0.01));

			if((argument[\warp] == \linear),{
				controlSliders[i].value_(argument[\value].linlin(
					argument[\min], argument[\max], 0.00, 1.00));
			});
			if(argument[\warp] == \exp,{
				controlSliders[i]
				.value_(argument[\value].explin(
					argument[\min], argument[\max], 0.00, 1.00));
			});
			if(argument[\warp] == \decibel,{
				var val;
				val = argument[\value];
				sliderSpec = ControlSpec(0.001, 1, \exp, 0.001);
				val = sliderSpec.unmap(val);
				controlSliders[i].value_(val);
			});

			controlSliders[i]
			.background_(constants[\slidersMinColor].blend(
				constants[\slidersMaxColor],
				controlSliders[i].value))
			.action_({
				var val;
				slidersValue[i].background_(constants[\viewBackground]);
				controlSliders[i].background_(
					constants[\slidersMinColor].blend(
						constants[\slidersMaxColor],
						controlSliders[i].value));
				if(argument[\warp] != \decibel){
					sliderSpec = ControlSpec(
						argument[\min],
						argument[\max],
						argument[\warp], 0.01);
					val = sliderSpec.map(controlSliders[i].value);
				};
				if(argument[\warp] == \decibel){
					sliderSpec = ControlSpec(0.001, 1, \exp, 0.001);
					val = controlSliders[i].value;
					val = sliderSpec.map(val) - 0.001;
				};
				~groups[selected][1][i][\value] = val;
				slidersValue[i].value_(argument[\value].trunc(0.01));
				~groups[selected][0][\group].set(
					argument[\control], argument[\value]);
				showOnInspector.(selected, i,
					argument, controlSliders[i], inspectorComponents,
					maxSliders[i], minSliders[i], inspectorComponents[\maxBox],
					controlSliders
				);
			});
		});
	});
};

showOnInspector = {
	arg selected, i, argument, controlSlider, inspectorComponents,
	maxSlider, minSlider, toFocus = nil, controlSliders, synthsList;
	var visibleBtnColor, sliderSpec, currentMidiColor;

	if(argument[\visible] == true,
		{
			visibleBtnColor = constants[\visibleTrueColor];
		},
		{
			visibleBtnColor = constants[\visibleFalseColor];
		};
	);

	inspectorComponents[\visibleBtn]
	.states_([[argument[\control],
		constants[\parametersColor],visibleBtnColor]])
	.mouseOverAction_({
		inspectorComponents[\visibleBtn]
		.font_(constants[\parametersMouseOnFont]);

		inspectorComponents[\visibleBtn]
		.states_([[argument[\control], constants[\parametersColor],
			constants[\mainBackground]]])
	})
	.mouseLeaveAction_({
		inspectorComponents[\visibleBtn]
		.font_(constants[\parametersFont]);

		inspectorComponents[\visibleBtn]
		.states_([[argument[\control], constants[\parametersColor],
			visibleBtnColor]])
	})
	.action_({
		if(~groups[selected][1][i][\visible] == true,
			{
				~groups[selected][1][i][\visible] = false;
				controlSlider.visible_(false);
				maxSlider.visible_(false);
				minSlider.visible_(false);
				visibleBtnColor = constants[\visibleFalseColor];
			},
			{
				~groups[selected][1][i][\visible] = true;
				controlSlider.visible_(true);
				maxSlider.visible_(true);
				minSlider.visible_(true);
				visibleBtnColor = constants[\visibleTrueColor];
			};
		);
		inspectorComponents[\visibleBtn]
		.states_([[argument[\control],
			constants[\parametersColor], visibleBtnColor]])
	});
	inspectorComponents[\minBox].value = minSlider.string.asFloat;
	inspectorComponents[\maxBox].value = maxSlider.string.asFloat;
	if(~groups[selected][1][i][\warp] == \linear,{
		inspectorComponents[\warpMenu].value_(0);
	});
	if(~groups[selected][1][i][\warp] == \exp,{
		inspectorComponents[\warpMenu].value_(1);
	});
	if(~groups[selected][1][i][\warp] == \decibel,{
		inspectorComponents[\warpMenu].value_(2);
	});
	inspectorComponents[\warpMenu].action_({
		~groups[selected][1][i][\warp] = inspectorComponents[\warpMenu].item;
		if(~groups[selected][1][i][\warp] == \linear,{
			controlSlider
			.value_(~groups[selected][1][i][\value].linlin(
				~groups[selected][1][i][\min],
				~groups[selected][1][i][\max], 0.00, 1.00));
			controlSlider.background_(constants[\slidersMinColor].blend(
				constants[\slidersMaxColor],
				controlSlider.value));
		});
		if(~groups[selected][1][i][\warp] == \exp,{
			controlSlider
			.value_(~groups[selected][1][i][\value].explin(
				~groups[selected][1][i][\min],
				~groups[selected][1][i][\max], 0.00, 1.00));
			controlSlider.background_(constants[\slidersMinColor].blend(
				constants[\slidersMaxColor],
				controlSlider.value));
		});
		if(~groups[selected][1][i][\warp] == \decibel,{
			var val;
			val = ~groups[selected][1][i][\value].value;
			sliderSpec = ControlSpec(0.001, 1, \exp, 0.001);
			val = sliderSpec.unmap(val) + 0.001;
			controlSlider.value_(val);
			controlSlider.background_(constants[\slidersMinColor].blend(
				constants[\slidersMaxColor],
				controlSlider.value));
		});
	});
	inspectorComponents[\minBox].action_({
		arg val;
		val = inspectorComponents[\minBox].value.asInteger;
		minSlider.string_(val);
		~groups[selected][1][i][\min] = val;
		controlSlider.value_(~groups[selected][1][i][\value].linlin(
			~groups[selected][1][i][\min],
			~groups[selected][1][i][\max], 0.00, 1.00));
		controlSlider.background_(constants[\slidersMinColor].blend(
			constants[\slidersMaxColor],
			controlSlider.value));
	});
	inspectorComponents[\maxBox].action_({
		arg val;
		val = inspectorComponents[\maxBox].value.asInteger;
		maxSlider.string_(val);
		~groups[selected][1][i][\max] = val;
		controlSlider.value_(~groups[selected][1][i][\value].linlin(
			~groups[selected][1][i][\min],
			~groups[selected][1][i][\max], 0.00, 1.00));
		controlSlider.background_(constants[\slidersMinColor].blend(
			constants[\slidersMaxColor],
			controlSlider.value));
	});
	if(~groups[selected][0][\maxInstances] == 1,
		{
			inspectorComponents[\instancesMenu].value_(0);
		},
		{
			inspectorComponents[\instancesMenu].value_(1);
		}
	);

	inspectorComponents[\instancesMenu].action_({
		if(inspectorComponents[\instancesMenu].value == 0,
			{
				~groups[selected][0][\maxInstances] = 1;
			},
			{
				~groups[selected][0][\maxInstances] = inf;
			}
		);
	});
	if(toFocus != nil, {
		toFocus.focus;
	});

	currentMidiColor = constants[\viewBackground];

	inspectorComponents[\midiCCBox].value_(-1);
	~midiMaps[~selectedMidiMap].keysValuesDo({
		arg key, value;
		if((value[2] == ~groups[selected][0][\id]) &&
			(value[1] == i),
			{
				var ccNum;
				ccNum = key.asString.replace("midiCtrl","");
				ccNum = ccNum.asInteger;
				inspectorComponents[\midiCCBox].value_(ccNum);
			}
		);
	});

	inspectorComponents[\midiCCBtn]
	.states_([["Midi CC",
		constants[\parametersColor],
		constants[\mainBackground]]])
	.mouseOverAction_({
		inspectorComponents[\midiCCBtn].font_(constants[\parametersInpuMouseOnFont]);
		inspectorComponents[\midiCCBtn].states_([["Midi CC", constants[\parametersColor],
			constants[\mainBackground]]])
	})
	.mouseLeaveAction_({
		inspectorComponents[\midiCCBtn].font_(constants[\parametersInputFont]);
		inspectorComponents[\midiCCBtn].states_([["Midi CC", constants[\parametersColor],
			currentMidiColor]])
	})
	.action_({
		if(currentMidiColor == constants[\viewBackground],
			{
				currentMidiColor = constants[\midiOnListening];
				inspectorComponents[\midiCCBtn]
				.states_([["Midi CC",
					constants[\parametersColor],
					currentMidiColor]]);
				MIDIIn.connectAll;
				MIDIdef.cc(\midiListener, {arg ...args;
					{
						inspectorComponents[\midiCCBox].value_(args[1])
					}.defer;
				}, (0..127));
			},
			{
				currentMidiColor = constants[\viewBackground];
				inspectorComponents[\midiCCBtn]
				.states_([["Midi CC",
					constants[\parametersColor],
					currentMidiColor]]);

				MIDIdef.cc(\midiListener).free;

				if(inspectorComponents[\midiCCBox].value >= 0, {
					var name, synthName, id, toSet, group;

					name = "midiCtrl" ++
					inspectorComponents[\midiCCBox].value.asString;
					name = name.asSymbol;
					id = ~groups[selected][0][\id];
					synthName = ~groups[selected][0][\name];
					group = ~groups[selected][0];

					~midiMaps[~selectedMidiMap].keysValuesDo({
						arg key, value;
						if((value[2] == ~groups[selected][0][\id]) &&
							(value[1] == i),
							{
								MIDIdef(key).free;
								~midiMaps[~selectedMidiMap]
								.removeAt(key);
							};
						);
					});

					MIDIdef(name).free;

					MIDIdef.cc(name, {
						arg ...args;
						var min, max, val, oldVal, oldSelected, realValue,
						sliderSpec, pos;

						~groups.do({
							arg item, j;
							if(id == item[0][\id]){
								pos = j;
								min = item[1][i][\min];
								max = item[1][i][\max];
								val = args[0].asFloat;
								val = val.linlin(0, 127,
									min.asFloat, max.asFloat).trunc(0.001);
							}
						});

						realValue = val.linlin(min.asFloat, max.asFloat,
							0, 1);

						if(~groups[~idForMap][0][\id] == id,
							{
								{controlSliders[i].valueAction_(realValue)}.defer;
							},
							{
								if(argument[\warp] != \decibel){
									sliderSpec = ControlSpec(
										argument[\min],
										argument[\max],
										argument[\warp], 0.01);
									realValue =
									sliderSpec.map(realValue);
								};
								if(argument[\warp] == \decibel){
									sliderSpec = ControlSpec(0.001, 1, \exp, 0.001);
									realValue = sliderSpec.map(realValue) - 0.001;
								};
								~groups[pos][1][i][\value] = realValue;
								~groups[pos][0][\group].set(
									argument[\control], argument[\value]);
							}
						);

					}, inspectorComponents[\midiCCBox].value);

					~midiMaps[~selectedMidiMap].put
					(name, [synthName, i, id]);
				})
			}
		);
	});
};

hideSliders = {
	arg controlSliders, slidersLabel,
	maxSliders, minSliders, slidersValue;

	for(0, (constants[\maxNumControls] - 1), {
		arg i;
		controlSliders[i].visible_(false);
		slidersLabel[i].visible_(false);
		maxSliders[i].visible_(false);
		minSliders[i].visible_(false);
		slidersValue[i].visible_(false);
	});
};

synthRemoveAction = {
	arg searchSynthList;
};

dict.put(\synthEditor, synthEditor);
dict.put(\loadAll, loadAll);
dict.put(\searchSynthWin, searchSynthWin);
dict.put(\searchSynthField, searchSynthField);
dict.put(\searchSynthList, searchSynthList);
dict.put(\synthSearchAction, synthSearchAction);
dict.put(\synthAddAction, synthAddAction);
dict.put(\synthRemoveAction, synthRemoveAction);
dict.put(\synthSelected, synthSelected);
dict.put(\hideSliders, hideSliders);
dict.put(\showOnInspector, showOnInspector);

dict;