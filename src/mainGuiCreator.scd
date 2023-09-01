var dict = Dictionary();
var import, constants, keyCode;
var mainWin, mainMenu, viewContainer, metersView, workspaceView,
synthMenu, synthsList, fixedWidthSyntList, synthListContainer,
playStopView, inspector, parametersView, linkerView, controlsCreator, inspectorComponents,
newFile, clearAll, midiPlay, create, recordWin;

import = {
	|path|
	var file, content;
	file = File.open(path.standardizePath, "r");
	content = file.readAllString;
	file.close;
	this.interpret(content);
};

fixedWidthSyntList = 150;

constants = import.(~constants);
keyCode = import.(~keyCode);

mainWin = {
	var win;

	win = Window(constants[\programName] ++ "untitled")
	.setTopLeftBounds(Rect(100, 50, 800, 600))
	.background_(constants[\mainBackground])
	//.fullScreen
	.front;

	win;
};

viewContainer = {
	var container;

	container = View().
	background_(constants[\mainBackground]);

	container;
};

metersView = {
	var meters;

	meters = View().
	background_(constants[\viewBackground])
	.fixedHeight_(235);

	meters;
};

workspaceView = {
	var view;

	view = View().
	background_(constants[\viewBackground]);

	view;
};

synthMenu = {
	var menu;

	menu = UserView()
	.background_(constants[\viewBackground])
	.fixedWidth_(fixedWidthSyntList);

	menu;
};

synthListContainer = {
	var container;

	container = UserView()
	.fixedWidth_(fixedWidthSyntList);

	container;
};

playStopView = {
	var view;

	view = UserView()
	.background_(constants[\viewBackground])
	.fixedHeight_(52)
	.fixedWidth_(fixedWidthSyntList);

	view;
};

parametersView = {
	var view;

	view = ScrollView()
	.hasBorder_(false)
	.background_(constants[\parametersViewBackground]);

	view;
};

linkerView = {
	var view;

	view = UserView()
	.background_(constants[\linkerViewBackground]);

	view;
};

inspector = {
	var view;

	view = UserView()
	.background_(constants[\viewBackground])
	.fixedWidth_(200);

	view;
};

synthsList = {
	var menu;

	menu = ListView()
	.background_(constants[\viewBackground])
	.fixedWidth_(fixedWidthSyntList)
	.font_(constants[\synthsListFont])
	.stringColor_(constants[\synthEditorListStringColor])
	.selectedStringColor_(constants[\synthEditorListStringColor])
	.hiliteColor_(constants[\synthEditorListHiliteColor]);

	menu
};

controlsCreator = {
	arg parametersView;
	var controlSliders = [], offset, slidersLabel = [],
	maxSliders = [], minSliders = [], slidersValue = [];

	offset = constants[\controlsOffset];
	constants[\maxNumControls].do({
		arg item, i;
		controlSliders =
		controlSliders.add(
			Slider(parametersView, Rect(offset, 80, 30, 220))
			.canFocus_(false)
			.background_(constants[\slidersMinColor])
			.knobColor_(constants[\slidersKnobColor])
			.action_({
				controlSliders[i].background_(
					constants[\slidersMinColor].blend(
						constants[\slidersMaxColor],
						controlSliders[i].value));
				slidersValue[i].value_(
					controlSliders[i].value.trunc(0.001))
			})
			.visible_(false);
		);
		slidersLabel =
		slidersLabel.add(
			StaticText(parametersView, Rect(offset-35, 15, 100, 30))
			.align_(\center)
			.font_(constants[\parametersFont])
			.stringColor_(constants[\parametersColor])
			.string_("Arguments")
			.mouseOverAction_({
				slidersLabel[i].stringColor_(constants[\parametersMouseOnColor]);
				slidersLabel[i].font_(
					constants[\parametersMouseOnFont]);
			})
			.mouseLeaveAction_({
				slidersLabel[i].stringColor_(constants[\parametersColor]);
				slidersLabel[i].font_(
					constants[\parametersFont]);
			})
			.mouseDownAction_({
				"Clicked".postln;
			})
			.visible_(false);
		);
		maxSliders =
		maxSliders.add(
			StaticText(parametersView, Rect(offset-35, 50, 100, 30))
			.align_(\center)
			.font_(constants[\parametersFont])
			.stringColor_(constants[\parametersColor])
			.string_("1")
			.mouseOverAction_({
				maxSliders[i].stringColor_(constants[\parametersMouseOnColor]);
				maxSliders[i].font_(
					constants[\parametersMouseOnFont]);
			})
			.mouseLeaveAction_({
				maxSliders[i].stringColor_(constants[\parametersColor]);
				maxSliders[i].font_(
					constants[\parametersFont]);
			})
			.mouseDownAction_({
				"Clicked".postln;
			})
			.visible_(false);
		);
		minSliders =
		minSliders.add(
			StaticText(parametersView, Rect(offset-35, 302, 100, 30))
			.align_(\center)
			.font_(constants[\parametersFont])
			.stringColor_(constants[\parametersColor])
			.string_("0")
			.mouseOverAction_({
				minSliders[i].stringColor_(constants[\parametersMouseOnColor]);
				minSliders[i].font_(
					constants[\parametersMouseOnFont]);
			})
			.mouseLeaveAction_({
				minSliders[i].stringColor_(constants[\parametersColor]);
				minSliders[i].font_(
					constants[\parametersFont]);
			})
			.mouseDownAction_({
				"Clicked".postln;
			})
			.visible_(false);
		);
		slidersValue =
		slidersValue.add(
			TextField(parametersView, Rect(offset-20, 350, 70, 30))
			.align_(\center)
			.value_(0.0)
			.font_(constants[\parametersInputFont])
			.background_(constants[\viewBackground])
			.stringColor_(constants[\parametersColor])
			.visible_(false)
		);
		offset = offset + 120;
	});

	[controlSliders,slidersLabel,
		maxSliders, minSliders, slidersValue];
};

inspectorComponents = {
	arg inspector;
	var inspectorComponents = Dictionary();
	var visibleBtn, maxText, minText, maxBox, minBox,
	warpText, warpMenu, instancesMenu, midiCCBtn, midiCCBox;

	visibleBtn = Button(inspector, Rect(30, 12, 140, 30))
	.states_([["", constants[\parametersColor], constants[\visibleFalseColor]]])
	.font_(constants[\parametersFont])
	.canFocus_(false)
	.mouseOverAction_({
		visibleBtn.font_(constants[\parametersMouseOnFont]);
		visibleBtn.states_([["", constants[\parametersColor],
			constants[\mainBackground]]])
	})
	.mouseLeaveAction_({
		visibleBtn.font_(constants[\parametersFont]);
		visibleBtn.states_([["", constants[\parametersColor],
			constants[\visibleFalseColor]]])
	});

	maxText = StaticText(inspector, Rect(30, 60, 50, 30))
	.string_("Max:")
	.font_(constants[\inspectorFont])
	.stringColor_(constants[\inspectorStringColor]);

	maxBox = NumberBox(inspector, Rect(90, 60, 80, 30))
	.font_(constants[\inspectorFont])
	.background_(constants[\mainBackground])
	.typingColor_(constants[\inspectorStringColor])
	.normalColor_(constants[\inspectorStringColor]);

	minText = StaticText(inspector, Rect(30, 110, 50, 30))
	.string_("Min:")
	.font_(constants[\inspectorFont])
	.stringColor_(constants[\inspectorStringColor]);

	minBox = NumberBox(inspector, Rect(90, 110, 80, 30))
	.font_(constants[\inspectorFont])
	.background_(constants[\mainBackground])
	.typingColor_(constants[\inspectorStringColor])
	.normalColor_(constants[\inspectorStringColor]);

	warpText = StaticText(inspector, Rect(30, 160, 50, 30))
	.string_("Warp:")
	.font_(constants[\inspectorFont])
	.stringColor_(constants[\inspectorStringColor]);

	warpMenu = PopUpMenu(inspector, Rect(90, 160, 80, 30))
	.background_(constants[\mainBackground])
	.font_(constants[\inspectorFont])
	.stringColor_(constants[\inspectorStringColor])
	.items_([\linear, \exp, \decibel]);

	instancesMenu = PopUpMenu(inspector, Rect(30, 210, 140, 30))
	.background_(constants[\mainBackground])
	.font_(constants[\inspectorFont])
	.stringColor_(constants[\inspectorStringColor])
	.items_(["Instances: 1", "Instances: inf"]);

	midiCCBtn = Button(inspector, Rect(30, 260, 90, 30))
	.states_([["Midi CC", constants[\parametersColor], constants[\viewBackground]]])
	.font_(constants[\parametersInputFont])
	.canFocus_(false)
	.mouseOverAction_({
		midiCCBtn.font_(constants[\parametersInpuMouseOnFont]);
		midiCCBtn.states_([["Midi CC", constants[\parametersColor],
			constants[\mainBackground]]])
	})
	.mouseLeaveAction_({
		midiCCBtn.font_(constants[\parametersInputFont]);
		midiCCBtn.states_([["Midi CC", constants[\parametersColor],
			constants[\viewBackground]]])
	});

	midiCCBox = NumberBox(inspector, Rect(130, 260, 40, 30))
	.value_(-1)
	.font_(constants[\inspectorFont])
	.background_(constants[\mainBackground])
	.typingColor_(constants[\inspectorStringColor])
	.normalColor_(constants[\inspectorStringColor]);


	inspectorComponents.put(\visibleBtn, visibleBtn);
	inspectorComponents.put(\maxText, maxText);
	inspectorComponents.put(\minText, minText);
	inspectorComponents.put(\maxBox, maxBox);
	inspectorComponents.put(\minBox, minBox);
	inspectorComponents.put(\warpMenu, warpMenu);
	inspectorComponents.put(\warpText, warpText);
	inspectorComponents.put(\instancesMenu, instancesMenu);
	inspectorComponents.put(\midiCCBtn, midiCCBtn);
	inspectorComponents.put(\midiCCBox, midiCCBox);

	inspectorComponents;
};

newFile = {
	arg mainWin;
	var win, width, height, text, createBtn, noBtn;

	width = 280;
	height = 110;

	win = Window("New Session")
	.setTopLeftBounds(
		Rect(
			(mainWin.bounds.width-width)/2,
			(mainWin.bounds.height-height)/3,
			width,
			height
		)
	)
	.background_(constants[\mainBackground])
	.acceptsMouseOver_(true)
	.alwaysOnTop_(true);

	text = StaticText(win, Rect(0, 0, 280, 60))
	.stringColor_(constants[\synthEditorListStringColor])
	.align_(\center)
	.string_("Create a New Session?")
	.font_(constants[\popUpFont]);

	createBtn = Button(win, Rect(20, 70, 110, 30))
	.font_(constants[\popUpFont])
	.canFocus_(false)
	.states_([["Create",
		constants[\synthEditorListStringColor],
		constants[\newFolderColor]
	]])
	.mouseOverAction_({
		createBtn.font_(constants[\buttonMouseOnFont]);
		createBtn.states_([["Create", constants[\menuStringSelectedColor],
			constants[\viewBackground]]])
	})
	.mouseLeaveAction_({
		createBtn.font_(constants[\buttonFont]);
		createBtn.states_([["Create", constants[\synthEditorListStringColor],
			constants[\newFolderColor]]])
	});


	noBtn = Button(win, Rect(150, 70, 110, 30))
	.font_(constants[\popUpFont])
	.canFocus_(false)
	.states_([["Not now",
		constants[\synthEditorListStringColor],
		constants[\synthEditorNotSavedColor]
	]])
	.mouseOverAction_({
		noBtn.font_(constants[\buttonMouseOnFont]);
		noBtn.states_([["Not now", constants[\menuStringSelectedColor],
			constants[\viewBackground]]])
	})
	.mouseLeaveAction_({
		noBtn.font_(constants[\buttonFont]);
		noBtn.states_([["Not now", constants[\synthEditorListStringColor],
			constants[\synthEditorNotSavedColor]]])
	});

	[win, createBtn, noBtn];
};

clearAll = {
	arg mainWin;
	var win, width, height, text, clearBtn, noBtn;

	width = 280;
	height = 110;

	win = Window("Clear Session")
	.setTopLeftBounds(
		Rect(
			(mainWin.bounds.width-width)/2,
			(mainWin.bounds.height-height)/3,
			width,
			height
		)
	)
	.background_(constants[\mainBackground])
	.acceptsMouseOver_(true)
	.alwaysOnTop_(true);

	text = StaticText(win, Rect(0, 0, 280, 60))
	.stringColor_(constants[\synthEditorListStringColor])
	.align_(\center)
	.string_("Clear the Session?")
	.font_(constants[\popUpFont]);

	clearBtn = Button(win, Rect(20, 70, 110, 30))
	.font_(constants[\popUpFont])
	.canFocus_(false)
	.states_([["Clear",
		constants[\synthEditorListStringColor],
		constants[\newFolderColor]
	]])
	.mouseOverAction_({
		clearBtn.font_(constants[\buttonMouseOnFont]);
		clearBtn.states_([["Clear", constants[\menuStringSelectedColor],
			constants[\viewBackground]]])
	})
	.mouseLeaveAction_({
		clearBtn.font_(constants[\buttonFont]);
		clearBtn.states_([["Clear", constants[\synthEditorListStringColor],
			constants[\newFolderColor]]])
	});


	noBtn = Button(win, Rect(150, 70, 110, 30))
	.font_(constants[\popUpFont])
	.canFocus_(false)
	.states_([["Not now",
		constants[\synthEditorListStringColor],
		constants[\synthEditorNotSavedColor]
	]])
	.mouseOverAction_({
		noBtn.font_(constants[\buttonMouseOnFont]);
		noBtn.states_([["Not now", constants[\menuStringSelectedColor],
			constants[\viewBackground]]])
	})
	.mouseLeaveAction_({
		noBtn.font_(constants[\buttonFont]);
		noBtn.states_([["Not now", constants[\synthEditorListStringColor],
			constants[\synthEditorNotSavedColor]]])
	});

	[win, clearBtn, noBtn];
};

midiPlay = {
	arg mainWin, synthsList;
	var win, width, height, currentMidiPlayColor, currentMidiStopColor,
	midiPlayBtn, midiPlayBox, midiStopBtn, midiStopBox, id;

	width = 200;
	height = 140;

	win = Window("Midi Play/Stop")
	.setTopLeftBounds(
		Rect(
			(mainWin.bounds.width-width)/5,
			(mainWin.bounds.height-height)/4,
			width,
			height
		)
	)
	.background_(constants[\mainBackground])
	.acceptsMouseOver_(true)
	.alwaysOnTop_(true);

	currentMidiPlayColor = constants[\viewBackground];
	currentMidiStopColor = constants[\viewBackground];

	midiPlayBtn = Button(win, Rect(20, 20, 100, 30))
	.states_([["Midi Play", constants[\parametersColor], constants[\viewBackground]]])
	.font_(constants[\parametersInputFont])
	.canFocus_(false)
	.mouseOverAction_({
		midiPlayBtn.font_(constants[\parametersInpuMouseOnFont]);
		midiPlayBtn.states_([["Midi Play", constants[\parametersColor],
			constants[\mainBackground]]])
	})
	.mouseLeaveAction_({
		midiPlayBtn.font_(constants[\parametersInputFont]);
		midiPlayBtn.states_([["Midi Play", constants[\parametersColor],
			currentMidiPlayColor
		]])
	})
	.action_({
		if(currentMidiPlayColor == constants[\viewBackground],
			{
				currentMidiPlayColor = constants[\midiOnListening];
				midiPlayBtn
				.states_([["Midi Play",
					constants[\parametersColor],
					currentMidiPlayColor]]);
				MIDIIn.connectAll;
				MIDIdef.cc(\midiListener, {arg ...args;
					{
						midiPlayBox.value_(args[1])
					}.defer;
				}, (0..127));
			},
			{
				var name;

				currentMidiPlayColor = constants[\viewBackground];
				midiPlayBtn
				.states_([["Midi Play",
					constants[\parametersColor],
					currentMidiPlayColor]]);

				MIDIdef.cc(\midiListener).free;

				name = "midiPlay" ++
				midiPlayBox.value.asString;
				name = name.asSymbol;

				if(midiPlayBox.value >= 0, {

					~groups[~idForMap][0][\midiPlay] = midiPlayBox.value;
					id = ~groups[~idForMap][0][\id];

					MIDIdef(name).free;

					MIDIdef.cc(name, {
						arg ...args;
						var pos;

						if(args[0] == 127,
							{
								var synth, argValueList;

								~groups.do({
									arg item, j;
									if(id == item[0][\id]){
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

					}, midiPlayBox.value);
				});
			}
		);
	});

	midiPlayBox = NumberBox(win, Rect(140, 20, 40, 30))
	.value_(~groups[~idForMap][0][\midiPlay])
	.font_(constants[\inspectorFont])
	.background_(constants[\mainBackground])
	.typingColor_(constants[\inspectorStringColor])
	.normalColor_(constants[\inspectorStringColor]);

	midiStopBtn = Button(win, Rect(20, 70, 100, 30))
	.states_([["Midi Stop", constants[\parametersColor], constants[\viewBackground]]])
	.font_(constants[\parametersInputFont])
	.canFocus_(false)
	.mouseOverAction_({
		midiStopBtn.font_(constants[\parametersInpuMouseOnFont]);
		midiStopBtn.states_([["Midi Stop", constants[\parametersColor],
			constants[\mainBackground]]])
	})
	.mouseLeaveAction_({
		midiStopBtn.font_(constants[\parametersInputFont]);
		midiStopBtn.states_([["Midi Stop", constants[\parametersColor],
			currentMidiStopColor]])
	})
	.action_({
		if(currentMidiStopColor == constants[\viewBackground],
			{
				currentMidiStopColor = constants[\midiOnListening];
				midiStopBtn
				.states_([["Midi Stop",
					constants[\parametersColor],
					currentMidiStopColor]]);
				MIDIIn.connectAll;
				MIDIdef.cc(\midiListener, {arg ...args;
					{
						midiStopBox.value_(args[1])
					}.defer;
				}, (0..127));
			},
			{
				var name;

				currentMidiStopColor = constants[\viewBackground];
				midiStopBtn
				.states_([["Midi Stop",
					constants[\parametersColor],
					currentMidiStopColor]]);

				MIDIdef.cc(\midiListener).free;

				name = "midiFree" ++
				midiStopBox.value.asString;
				name = name.asSymbol;

				if(midiStopBox.value >= 0, {

					~groups[~idForMap][0][\midiFree] = midiStopBox.value;
					id = ~groups[~idForMap][0][\id];

					MIDIdef(name).free;

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

					}, midiStopBox.value);
				});
			}
		);
	});

	midiStopBox = NumberBox(win, Rect(140, 70, 40, 30))
	.value_(~groups[~idForMap][0][\midiFree])
	.font_(constants[\inspectorFont])
	.background_(constants[\mainBackground])
	.typingColor_(constants[\inspectorStringColor])
	.normalColor_(constants[\inspectorStringColor]);

	[win];
};

recordWin = {
	arg mainWin, currentPath;
	var width, height, win, currPathString, currPathLabel,
	recordBtn, timer, recFun, elapsedTime = 0, inRec = false,
	myPath, folder, file;

	width = 400;
	height = 160;

	win = Window("Recorder")
	.setTopLeftBounds(
		Rect(
			mainWin.bounds.width + width,
			mainWin.bounds.height,
			width,
			height
		)
	)
	.background_(constants[\mainBackground])
	.acceptsMouseOver_(true)
	.alwaysOnTop_(true)
	.onClose_({
		recFun.stop;
	});

	file = "YourFile";
	r = Recorder.new(s);
	r.recHeaderFormat = "wav";
	r.recSampleFormat = "int24";
	r.filePrefix = file;

	timer = StaticText(win, Rect(125, 60, 150, 30))
	.stringColor_(constants[\synthEditorNotSavedColor])
	.font_(constants[\timerFont])
	.align_(\center)
	.string_("00:00");

	currPathString = StaticText(win, Rect(125, 10, 150, 30))
	.stringColor_(constants[\synthEditorListStringColor])
	.string_(file)
	.align_(\center)
	.font_(constants[\buttonFont])
	.mouseOverAction_({
		currPathString.font_(constants[\buttonMouseOnFont]);
	})
	.mouseLeaveAction_({
		currPathString.font_(constants[\buttonFont]);
	})
	.mouseDownAction_({
		FileDialog({
			|path|
			myPath = PathName(path[0]);
			folder = myPath.pathOnly;
			file = myPath.fileNameWithoutExtension;
			currentPath = folder;
			thisProcess.platform.recordingsDir = currentPath;
			currPathString.string_(file);
			r.filePrefix = file;
		},
		acceptMode: 1,
		path: currentPath);
	});

	recordBtn = Button(win, Rect(125, 114, 150, 30))
	.font_(constants[\popUpFont])
	.canFocus_(false)
	.states_([
		["Record",
			constants[\synthEditorListStringColor],
			constants[\newFolderColor]
		],
		["Stop Recording",
			constants[\synthEditorListStringColor],
			constants[\newFolderColor]
		]
	])
	.action_({
		if(recordBtn.value == 1, {
			Routine{
				1.wait;
				inRec = true;
				r.record;
			}.play;
			timer.stringColor_(constants[\playColor]);
		});
		if(recordBtn.value == 0, {
			inRec = false;
			r.stopRecording;
			timer.string_("00:00");
			timer.stringColor_(constants[\synthEditorNotSavedColor]);
			elapsedTime = 0;
		});
	});

	recFun = Routine{
		loop{
			if(inRec == true, {
				var min, sec;
				elapsedTime = elapsedTime + 1;
				min = (elapsedTime / 60).asInteger;
				sec = elapsedTime % 60;
				min = min.asString.padLeft(2, "00");
				sec = sec.asString.padLeft(2, "00");
				timer.string = min.asString ++ ":" ++ sec.asString;
			});
			1.wait;
		}
	}.play(AppClock);


	[win, currentPath];
};

dict.put(\mainWin, mainWin);
dict.put(\viewContainer, viewContainer);
dict.put(\metersView, metersView);
dict.put(\workspaceView, workspaceView);
dict.put(\synthMenu, synthMenu);
dict.put(\synthListContainer, synthListContainer);
dict.put(\playStopView, playStopView);
dict.put(\parametersView, parametersView);
dict.put(\linkerView, linkerView);
dict.put(\inspector, inspector);
dict.put(\synthsList, synthsList);
dict.put(\controlsCreator, controlsCreator);
dict.put(\inspectorComponents, inspectorComponents);
dict.put(\newFile, newFile);
dict.put(\clearAll, clearAll);
dict.put(\midiPlay, midiPlay);
dict.put(\recordWin, recordWin);

dict;