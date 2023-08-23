(

//Extern Modules
var import, srcPath, constants, mainGuiCreator, keyCode, guiFunctions,
synthsManager, audioManager, fileManager, linkerManager;
//Views
var mainWin, fileBtn, mainMenu, editBtn, viewBtn, audioBtn,
helpBtn, metersView,viewContainer, workspaceView, synthEditor = nil,
synthMenu, synthsList, synthListContainer, playStopView, inspector, parametersView, searchSynthWin = nil, searchSynthField, searchSynthList,
serverNotRunningWin, serverMeter, freqScope, cpuIndicator, cpuValue, clearBtn,
stopAllBtn, playAllBtn, reloadBtn, panicBtn, duplicateBtn, midiBtn;
//View Controls
var metersViewVisible = false, playLabel,
stopLabel, playColor, stopColor, addBtn, removeBtn, beforeBtn, afterBtn,
mainFullScreen = true, moveBefore = false, moveAfter = false, toMove,
cpuIndicatorRoutine, playColorNow, clicked, relativeWhere, linkModeBtn;
//Inspector Controls
var inspectorComponents;
//Workspace Controls
var controlSliders, slidersLabel, maxSliders, minSliders, slidersValue,
emptyWorkspace;
//Session functions
var filePath = nil, new, save, saveAs, open;

/*** IMPORT DEFINITION ***/
import = {
	|path|
	var file, content;
	file = File.open(path.standardizePath, "r");
	content = file.readAllString;
	file.close;
	this.interpret(content);
};


/*** INIT ***/
~id = 0;
~synths = [];
~groups = [];
~midi = [];
~path = thisProcess.nowExecutingPath.dirname;

srcPath = ~path +/+ "src";
~constants =  srcPath +/+ "constants.scd";
constants = import.(~constants);
~keyCode =  srcPath +/+ "winKeyCode.scd";
keyCode = import.(~keyCode);
~mainGuiPath =  srcPath +/+ "mainGuiCreator.scd";
mainGuiCreator = import.(~mainGuiPath);
~synthsManager =  srcPath +/+ "synthsManager.scd";
synthsManager = import.(~synthsManager);
~audioManager =  srcPath +/+ "audioManager.scd";
audioManager = import.(~audioManager);
~guiFunctions =  srcPath +/+ "guiFunctions.scd";
guiFunctions = import.(~guiFunctions);
~fileManager =  srcPath +/+ "fileManager.scd";
fileManager = import.(~fileManager);
~linkerManager=  srcPath +/+ "linkerManager.scd";
linkerManager = import.(~linkerManager);
synthsManager[\loadAll].();
~idForMap = -1;
~selectedMidiMap = 0;
~midiMaps = Array.fill(8, { Dictionary() });

s = Server.local;
MIDIIn.disconnectAll;
MIDIClient.init;
MIDIIn.connectAll;

/*** MAIN MENU ***/
mainMenu = UserView().fixedHeight_(30);
fileBtn = StaticText(mainMenu, Rect(20, 0, 70, 30))
.string_("Session")
.stringColor_(constants[\menuStringColor])
.font_(constants[\mainToolBarFont])
.mouseOverAction_({
	fileBtn.stringColor_(constants[\menuStringSelectedColor]);
	fileBtn.font_(constants[\mainToolBarMouseOnFont]);
})
.mouseLeaveAction_({
	fileBtn.stringColor_(constants[\menuStringColor]);
	fileBtn.font_(constants[\mainToolBarFont]);
})
.mouseDownAction_({
	Menu(
		MenuAction("New", {
			new.();
		})
		.font_(constants[\mainToolBarMenuFont])
		.shortcut_("Ctrl+n"),
		MenuAction("Open", {
			open.();
		})
		.font_(constants[\mainToolBarMenuFont])
		.shortcut_("Ctrl+o"),
		MenuAction("Save", {
			save.();
		})
		.shortcut_("Ctrl+s")
		.font_(constants[\mainToolBarMenuFont]),
		MenuAction("Save As", {
			saveAs.();
		})
		.font_(constants[\mainToolBarMenuFont])
		.shortcut_("Ctrl+Shift+s"),
	).front;
});

editBtn = StaticText(mainMenu, Rect(100, 0, 40, 30))
.string_("Edit")
.stringColor_(constants[\menuStringColor])
.font_(constants[\mainToolBarFont])
.mouseDownAction_({
	Menu(
		MenuAction("Synths editor", {
			synthEditor = synthsManager[\synthEditor].(editBtn).front;
		})
		.font_(constants[\mainToolBarMenuFont]),
		MenuAction("Preferences", { "A selected".postln })
		.font_(constants[\mainToolBarMenuFont]),
	).front;
})
.mouseOverAction_({
	editBtn.stringColor_(constants[\menuStringSelectedColor]);
	editBtn.font_(constants[\mainToolBarMouseOnFont]);
})
.mouseLeaveAction_({
	editBtn.stringColor_(constants[\menuStringColor]);
	editBtn.font_(constants[\mainToolBarFont]);
});

viewBtn = StaticText(mainMenu, Rect(155, 0, 45, 30))
.string_("View")
.stringColor_(constants[\menuStringColor])
.font_(constants[\mainToolBarFont])
.mouseDownAction_({
	Menu(
		MenuAction("Controller", {
			parametersView.visible_(true);
			~linkerView.visible_(false);
			linkModeBtn.visible_(false);
		})
		.font_(constants[\mainToolBarMenuFont]),
		MenuAction("Linker", {
			parametersView.visible_(false);
			inspector.visible_(false);
			~linkerView.visible_(true);
			linkModeBtn.visible_(true);
		})
		.font_(constants[\mainToolBarMenuFont]),
		MenuAction("Show meters", {
			metersViewVisible = metersViewVisible.not;
			metersView.visible_(metersViewVisible);
		})
		.font_(constants[\mainToolBarMenuFont]),
		MenuAction("Fullscreen", {
			mainFullScreen = mainFullScreen.not;
			if(mainFullScreen == true,
				{
					mainWin.fullScreen;
				},
				{
					mainWin.endFullScreen;
				}
			);
		})
		.font_(constants[\mainToolBarMenuFont]),
	).front;
})
.mouseOverAction_({
	viewBtn.stringColor_(constants[\menuStringSelectedColor]);
	viewBtn.font_(constants[\mainToolBarMouseOnFont]);
})
.mouseLeaveAction_({
	viewBtn.stringColor_(constants[\menuStringColor]);
	viewBtn.font_(constants[\mainToolBarFont]);
});

audioBtn = StaticText(mainMenu, Rect(215, 0, 45, 30))
.string_("Audio")
.stringColor_(constants[\menuStringColor])
.font_(constants[\mainToolBarFont])
.mouseDownAction_({
	Menu(
		MenuAction.separator("Audio/Midi"),
		MenuAction("Load all Synths", {
			synthsManager[\loadAll].();
		}).font_(constants[\mainToolBarMenuFont]),
		MenuAction("Audio drivers", {
			audioManager[\audioDrivers].().front;
		})
		.font_(constants[\mainToolBarMenuFont]),
		MenuAction("MIDI: connect", {
			Routine{
				MIDIClient.init;
				0.5.wait;
				MIDIIn.connectAll;
			}.play;
		})
		.font_(constants[\mainToolBarMenuFont]),
		MenuAction("MIDI: clear all", {
			/*MIDIIn.disconnectAll;*/
			MIDIdef.freeAll;
			~midiMaps = Array.fill(8, { Dictionary() });
		})
		.font_(constants[\mainToolBarMenuFont]),
	).front;
})
.mouseOverAction_({
	audioBtn.stringColor_(constants[\menuStringSelectedColor]);
	audioBtn.font_(constants[\mainToolBarMouseOnFont]);
})
.mouseLeaveAction_({
	audioBtn.stringColor_(constants[\menuStringColor]);
	audioBtn.font_(constants[\mainToolBarFont]);
});

helpBtn = StaticText(mainMenu, Rect(285, 0, 45, 30))
.string_("Help")
.stringColor_(constants[\menuStringColor])
.font_(constants[\mainToolBarFont])
.mouseDownAction_({
	Menu(
		MenuAction("", { "A selected".postln })
		.font_(constants[\mainToolBarMenuFont]),
	).front;
})
.mouseOverAction_({
	helpBtn.stringColor_(constants[\menuStringSelectedColor]);
	helpBtn.font_(constants[\mainToolBarMouseOnFont]);
})
.mouseLeaveAction_({
	helpBtn.stringColor_(constants[\menuStringColor]);
	helpBtn.font_(constants[\mainToolBarFont]);
});

/*** SYNTH MENU ***/
//Add
synthMenu = mainGuiCreator[\synthMenu].();
addBtn = Button(synthMenu, Rect(25, 12, 100, 30))
.states_([["Add", constants[\menuStringSelectedColor], constants[\viewBackground]]])
.canFocus_(false)
.font_(constants[\buttonFont])
.mouseOverAction_({
	addBtn.font_(constants[\buttonMouseOnFont]);
	addBtn.states_([["Add", constants[\menuStringSelectedColor],
		constants[\mainBackground]]])
})
.mouseLeaveAction_({
	addBtn.font_(constants[\buttonFont]);
	addBtn.states_([["Add", constants[\menuStringSelectedColor],
		constants[\viewBackground]]])
})
.action_({
	searchSynthList = synthsManager[\searchSynthList].();
	playColor = constants[\playColorDeactivated];
	playColorNow = constants[\playColorDeactivated];
	playStopView.refresh;
	synthsManager[\loadAll].();

	searchSynthList.action_({
		arg sel;
		moveBefore = false;
		moveAfter = false;
		synthsManager[\synthAddAction].
		(sel, searchSynthList, synthsList, searchSynthWin,
			controlSliders, slidersLabel, maxSliders, minSliders, slidersValue,
			inspector, inspectorComponents);
		inspector.visible_(false);
		~idForMap = synthsList.value;
	});

	searchSynthField = synthsManager[\searchSynthField].()
	.keyUpAction_({
		synthsManager[\synthSearchAction].
		(searchSynthList, searchSynthField);
	});

	searchSynthWin = synthsManager[\searchSynthWin].(addBtn);
	searchSynthWin.front;
	searchSynthWin.layout_(VLayout(searchSynthField,searchSynthList)
		.margins_(0).spacing_(0));
});

//Remove
removeBtn = Button(synthMenu, Rect(25, 52, 100, 30))
.states_([["Remove", constants[\menuStringSelectedColor],
	constants[\viewBackground]]])
.canFocus_(false)
.font_(constants[\buttonFont])
.action_({
	moveBefore = false;
	moveAfter = false;
	if(synthsList.value != nil){
		var list, midiListToDelete = [], keyPlayToDelete,
		keyFreeToDelete;
		list = synthsList.items;

		~midiMaps.do({
			arg dict, i;
			dict.keysValuesDo({
				arg key, value;
				if(~groups[synthsList.value][0][\id] == value[2],
					{
						midiListToDelete =
						midiListToDelete.add([i, key]);
						key = key.asSymbol;
						MIDIdef(key).free;
					}
				)
			});
		});
		midiListToDelete.do({
			arg item;
			~midiMaps[item[0]].removeAt(item[1]);
		});
		keyPlayToDelete = "midiPlay" ++
		~groups[synthsList.value][0][\id].value.asString;
		keyPlayToDelete = keyPlayToDelete.asSymbol;
		keyFreeToDelete = "midiFree" ++
		~groups[synthsList.value][0][\id].value.asString;
		keyFreeToDelete = keyFreeToDelete.asSymbol;

		MIDIdef(keyPlayToDelete).free;
		MIDIdef(keyFreeToDelete).free;

		~groups[synthsList.value][0][\group].free;
		~groups.removeAt(synthsList.value);
		list.removeAt(synthsList.value);
		synthsList.items_(list);
		inspector.visible_(false);
		~linkerView.refresh;

		if(list.size > 0,
			{
				synthsList.valueAction_(0);
			},
			{
				synthsManager[\hideSliders].(
					controlSliders, slidersLabel,
					maxSliders, minSliders, slidersValue);
				playColor = constants[\playColorDeactivated];
				playColorNow = constants[\playColorDeactivated];
				playStopView.refresh;
			}
		);
	};
})
.mouseOverAction_({
	removeBtn.font_(constants[\buttonMouseOnFont]);
	removeBtn.states_([["Remove", constants[\menuStringSelectedColor],
		constants[\mainBackground]]])
})
.mouseLeaveAction_({
	removeBtn.font_(constants[\buttonFont]);
	removeBtn.states_([["Remove", constants[\menuStringSelectedColor],
		constants[\viewBackground]]])
});

//Move beforeT
beforeBtn = Button(synthMenu, Rect(25, 92, 100, 30))
.states_([["Before", constants[\menuStringSelectedColor],
	constants[\viewBackground]]])
.canFocus_(false)
.font_(constants[\buttonFont])
.action_({
	moveBefore = true;
	moveAfter = false;
	toMove = synthsList.value;
})
.mouseOverAction_({
	beforeBtn.font_(constants[\buttonMouseOnFont]);
	beforeBtn.states_([["Before", constants[\menuStringSelectedColor],
		constants[\mainBackground]]])
})
.mouseLeaveAction_({
	beforeBtn.font_(constants[\buttonFont]);
	beforeBtn.states_([["Before", constants[\menuStringSelectedColor],
		constants[\viewBackground]]])
});

//Move after
afterBtn = Button(synthMenu, Rect(25, 132, 100, 30))
.states_([["After", constants[\menuStringSelectedColor],
	constants[\viewBackground]]])
.canFocus_(false)
.font_(constants[\buttonFont])
.action_({
	moveBefore = false;
	moveAfter = true;
	toMove = synthsList.value;
})
.mouseOverAction_({
	afterBtn.font_(constants[\buttonMouseOnFont]);
	afterBtn.states_([["After", constants[\menuStringSelectedColor],
		constants[\mainBackground]]])
})
.mouseLeaveAction_({
	afterBtn.font_(constants[\buttonFont]);
	afterBtn.states_([["After", constants[\menuStringSelectedColor],
		constants[\viewBackground]]])
});

//Link mode
linkModeBtn = Button(synthMenu, Rect(25, 172, 100, 30))
.states_([
	["Move", constants[\menuStringSelectedColor],
		constants[\linkModeMoveColor]],
	["Bus", constants[\menuStringSelectedColor],
		constants[\linkModeBusColor]],
	["Inspector", constants[\menuStringSelectedColor],
		constants[\linkModeInspectorColor]]
])
.canFocus_(false)
.visible_(false)
.font_(constants[\buttonFont])
.action_({
});

//Clear space
clearBtn = Button(synthMenu, Rect(25, 212, 100, 30))
.states_([["Clear", constants[\menuStringSelectedColor],
	constants[\clearBtnBackground]]])
.canFocus_(false)
.font_(constants[\buttonFont])
.action_({
	var newWin, clearBtn, noBtn;

	#newWin, clearBtn, noBtn =
	mainGuiCreator[\clearAll].(mainWin);
	newWin.front;
	clearBtn.action_({
		var tmpPath;
		newWin.close;
		tmpPath = filePath;
		emptyWorkspace.();
		filePath = tmpPath;
	});
	noBtn.action_({
		newWin.close;
	});
})
.mouseOverAction_({
	clearBtn.font_(constants[\buttonMouseOnFont]);
	clearBtn.states_([["Clear", constants[\menuStringSelectedColor],
		constants[\mainBackground]]])
})
.mouseLeaveAction_({
	clearBtn.font_(constants[\buttonFont]);
	clearBtn.states_([["Clear", constants[\menuStringSelectedColor],
		constants[\clearBtnBackground]]])
});

//Midi Button
midiBtn = Button(synthMenu, Rect(25, 252, 100, 30))
.states_([["Midi Play", constants[\menuStringSelectedColor],
	constants[\clearBtnBackground]]])
.canFocus_(false)
.font_(constants[\buttonFont])
.action_({
	var newWin, clearBtn, noBtn;
	if(~idForMap >= 0, {
		#newWin =
		mainGuiCreator[\midiPlay].(mainWin, synthsList);
		newWin.front;
	});

})
.mouseOverAction_({
	midiBtn.font_(constants[\buttonMouseOnFont]);
	midiBtn.states_([["Midi Play", constants[\menuStringSelectedColor],
		constants[\mainBackground]]])
})
.mouseLeaveAction_({
	midiBtn.font_(constants[\buttonFont]);
	midiBtn.states_([["Midi Play", constants[\menuStringSelectedColor],
		constants[\clearBtnBackground]]])
});

/*** SYNTHS LIST ***/
synthsList = mainGuiCreator[\synthsList].()
.action_({
	arg sbs;
	var selNum, selSynth;

	selNum = sbs.value;
	~idForMap = selNum.asInteger;
	selSynth = synthsList.items[selNum];
	inspector.visible_(false);
	~linkerView.refresh;

	if(moveBefore == true, {
		var toDelete, list;

		if(toMove != nil,{
			moveBefore = false;
			toDelete = synthsList.items[toMove];
			~groups[toMove][0][\group].moveBefore(~groups[selNum][0][\group]);
			list = synthsList.items;
			list = list.insert(selNum, toDelete);
			~groups = ~groups.insert(selNum, ~groups[toMove]);

			if(toMove < selNum,
				{
					list.removeAt(toMove);
					~groups.removeAt(toMove);
					synthsList.items_(list);
					synthsList.value = selNum - 1;
					selNum = selNum - 1;
				},
				{
					toMove = toMove + 1;
					~groups.removeAt(toMove);
					list.removeAt(toMove);
					synthsList.items_(list);
					synthsList.valueAction_(selNum);
				}
			);
		});
	});
	if(moveAfter == true, {
		var toDelete, list;

		if(toMove != nil,{
			moveAfter = false;
			toDelete = synthsList.items[toMove];
			~groups[toMove][0][\group].moveAfter(~groups[selNum][0][\group]);
			list = synthsList.items;
			list = list.insert(selNum + 1, toDelete);
			~groups = ~groups.insert(selNum + 1, ~groups[toMove]);

			if(toMove < selNum,
				{
					list.removeAt(toMove);
					~groups.removeAt(toMove);
					synthsList.items_(list);
					synthsList.value = selNum;
					selNum = selNum;
				},
				{
					toMove = toMove + 1;
					~groups.removeAt(toMove);
					list.removeAt(toMove);
					synthsList.items_(list);
					synthsList.valueAction_(selNum + 1);
				}
			);
		});
	});
	synthsManager[\hideSliders].(controlSliders, slidersLabel,
		maxSliders, minSliders, slidersValue);
	synthsManager[\synthSelected].(selNum, controlSliders, slidersLabel,
		maxSliders, minSliders, slidersValue, inspector, inspectorComponents);
	if(~groups[selNum][0][\play] == false,
		{
			playColor = constants[\playColorDeactivated];
			playColorNow = constants[\playColorDeactivated];
			playStopView.refresh;
		},
		{
			playColor = constants[\playColor];
			playColorNow = constants[\playColor];
			playStopView.refresh;
		}
	);

});

/*** PLAY STOP VIEW ***/
playColor = constants[\playColorDeactivated];
stopColor = constants[\stopColorDeactivated];
playColorNow = constants[\playColorDeactivated];
playStopView = mainGuiCreator[\playStopView].()
.drawFunc_({
	var startX, startY, width, height;

	//play;
	startX = 30;
	startY =12;
	width = 30;
	height = 30;
	Pen.fillColor = playColor;
	Pen.moveTo(startX @ startY);
	Pen.lineTo(startX + (width/2) @ startY + (height/2));
	Pen.lineTo(startX-width/2 @ startY + height);
	Pen.lineTo(startX @ startY);
	Pen.fill;

	//stop;
	startX = 90;
	startY = 12;
	width = 30;
	height = 30;
	Pen.fillColor = stopColor;
	Pen.moveTo(startX @ startY);
	Pen.lineTo(startX + width @ startY);
	Pen.lineTo(startX @ startY + height);
	Pen.lineTo(startX-width @ startY + height);
	Pen.lineTo(startX @ startY);
	Pen.fill;
});
playLabel = StaticText(playStopView, Rect(0, 0, 75, 50))
.mouseDownAction_({
	var synth, selection, argValueList;

	selection = synthsList.value;
	if(selection != nil,{
		if((~groups[selection][0][\maxInstances] == 1
			&& ~groups[selection][0][\play] == false) ||
		(~groups[selection][0][\maxInstances] == "inf")
		,{
			synth = Synth(~groups[selection][0][\name],
				target: ~groups[selection][0][\group]);
			argValueList = ~groups[selection][1];
			argValueList.do({
				arg dict;
				synth.set(dict[\control], dict[\value])
			});
			~groups[selection][0][\play] = true;
			playColorNow = constants[\playColor];
			playStopView.refresh;
		});
	});
})
.mouseOverAction_({
	playColor = constants[\playColorMouseOn];
	playStopView.refresh;
})
.mouseLeaveAction_({
	playColor = playColorNow;
	playStopView.refresh;
});

stopLabel = StaticText(playStopView, Rect(75, 0, 75, 50))
.mouseDownAction_({
	var selection;

	selection = synthsList.value;
	if(selection != nil){
		~groups[selection][0][\group].freeAll;
		~groups[selection][0][\play] = false;
		playColorNow = constants[\playColorDeactivated];
		playColor = playColorNow;
		playStopView.refresh;
	};
})
.mouseOverAction_({
	stopColor = constants[\stopColorMouseOn];
	playStopView.refresh;
})
.mouseLeaveAction_({
	stopColor = constants[\stopColorDeactivated];
	playStopView.refresh;
});
/*** INSPECTOR ***/
inspector = mainGuiCreator[\inspector].().visible_(false);
inspectorComponents = mainGuiCreator[\inspectorComponents].(inspector);

/*** SYNTHS LIST CONTAINER***/
synthListContainer = mainGuiCreator[\synthListContainer].().
layout_(VLayout(playStopView, synthsList).margins_(0).spacing_(0));

/*** PARAMETERS VIEW ***/
parametersView = mainGuiCreator[\parametersView].();

/*** PARAMETERS VIEW ***/
~linkerView = mainGuiCreator[\linkerView].()
.visible_(false)
.drawFunc_({
	~groups.do { |synth, i|
		if(~idForMap == i,
			{
				Pen.color_(constants[\ovalSelectedColor]);
			},
			{
				Pen.color_(constants[\ovalColor]);
			}
		);
		Pen.addOval(synth[0][\rect]);
		Pen.draw;
	};
	Pen.draw;
});
~linkerView.mouseDownAction = { |v, x, y|
	~groups.do { |synth, i|
		if(synth[0][\rect].contains(Point(x, y))) {
			clicked = i;
			relativeWhere = Point(x, y) - synth[0][\rect].origin;
			synthsList.valueAction_(clicked);
			"clicked".postln;
		};
	};
};
~linkerView.mouseMoveAction = { |v, x, y|
	var rect, tmpCoord;
	if(linkModeBtn.value == 0 && clicked.notNil) {
		rect = ~groups[clicked][0][\rect];
		tmpCoord = Point(x, y) - relativeWhere;
		x.postln;
		y.postln;
		if(((tmpCoord.x > -10) &&
			(tmpCoord.y > -10) &&
			(tmpCoord.y < (~linkerView.bounds.height - 10)) &&
			(tmpCoord.x < (~linkerView.bounds.width - 10))
		),
		{
			rect.origin = tmpCoord;
			~groups[clicked][0][\rect] = rect;
			~linkerView.refresh;
		},

		);
	}
};
~linkerView.mouseUpAction = {
	clicked = nil;
};

/*** WORKSPACE ***/
workspaceView = mainGuiCreator[\workspaceView].()
.layout_(HLayout(synthMenu, synthListContainer, parametersView, ~linkerView, inspector)
	.margins_(0).spacing_(0));

/*** CONTROLS INIT ***/
#controlSliders,slidersLabel,
maxSliders, minSliders, slidersValue =
mainGuiCreator[\controlsCreator].(parametersView);

/*** METERS ***/
metersView = mainGuiCreator[\metersView].()
.visible_(metersViewVisible);
audioManager[\masterKnob].(metersView);
#cpuIndicator, cpuValue = audioManager[\cpuIndicator].(metersView);
serverMeter = audioManager[\serverMeter].(metersView);
freqScope = audioManager[\freqScope].(metersView);

/*** VIEW CONTAINER ***/
viewContainer = mainGuiCreator[\viewContainer].()
.layout_(VLayout(workspaceView, metersView).margins_(0).spacing_(0));

/*** MAIN WIN ***/
mainWin = mainGuiCreator[\mainWin].()
.acceptsMouseOver_(true)
.front
.layout_(VLayout(
	mainMenu,
	viewContainer
).margins_(0).spacing_(0))
.view.keyDownAction_({
	arg doc, char, mod, unicode, kc, key;

	if(key == keyCode[\esc],
		{
			mainWin.endFullScreen;
			mainFullScreen = false;
		};
	);

	if(mod == keyCode[\ctrl] && key == keyCode[\n]){
		new.();
	};

	if(mod == keyCode[\ctrl] && key == keyCode[\s]){
		save.();
	};

	if(mod == keyCode[\ctrl] && key == keyCode[\o]){
		open.();
	};

	if(mod == keyCode[\ctrlShift] && key == keyCode[\s]){
		saveAs.();
	};

	//[doc, char, mod, unicode, kc, key].postln
})
.onClose_({
	Window.closeAll;
	freqScope.kill;
	Node.free;
	Routine{
		cpuIndicatorRoutine.stop;
		0.5.wait;
		MIDIdef.freeAll;
		Server.freeAll;
	}.play;
});

/*** SERVER CHECK ***/
if(s.serverRunning == false,
	{
		serverNotRunningWin =
		audioManager[\serverNotRunningWin].(viewBtn)
		.front;
	};
);

/*** FILE FUNCTIONS ***/
new = {
	var newWin, createBtn, noBtn;

	#newWin, createBtn, noBtn =
	mainGuiCreator[\newFile].(mainWin);
	newWin.front;
	createBtn.action_({
		mainWin.name = constants[\programName] ++ "untitled";
		newWin.close;
		emptyWorkspace.();
		~linkerView.refresh;
	});
	noBtn.action_({
		newWin.close;
	});
};

save = {
	if(filePath == nil,
		{
			Dialog.savePanel({
				arg path;
				var name;

				filePath = path;
				name = fileManager[\saveSession].(path);
				mainWin.name = constants[\programName] ++ name;
			},{
			});
		},
		{
			fileManager[\saveSession].(filePath);
		}
	);
};

saveAs = {
	Dialog.savePanel({
		arg path;
		var name;

		filePath = path;
		name = fileManager[\saveSession].(path);
		mainWin.name = constants[\programName] ++ name;
	},{
	});
};

open = {
	moveBefore = false;
	moveAfter = false;
	Dialog.openPanel({
		arg path;
		var name, list;
		emptyWorkspace.();
		#name = fileManager[\openSession].(path, controlSliders, slidersLabel,
			maxSliders, minSliders, slidersValue, inspector,
			inspectorComponents, synthsList);
		if(name != nil, {
			filePath = path;
			mainWin.name = constants[\programName] ++ name;
			if(~groups.size != 0,{
				Routine{
					0.5.wait;
					~groups.collect({
						arg item, i;
						item[0][\group] =
						Group(s.defaultGroup, 'addToTail');
					});
				}.play(AppClock);
			});

			~midiMaps.do({
				arg map;
				map.keysValuesDo({
					arg key, value;
					var cc, synthName, i, id,
					min, max, val, oldVal, oldSelected, realValue,
					sliderSpec, pos;

					synthName = value[0];
					i = value[1];
					id = value[2];

					cc = key.asString.replace("midiCtrl","");
					cc = cc.asInteger;

					MIDIdef.cc(key, {
						arg ...args;
						//args.postln;

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
								if(~groups[pos][1][i][\warp] != \decibel){
									sliderSpec = ControlSpec(
										~groups[pos][1][i][\min],
										~groups[pos][1][i][\max],
										~groups[pos][1][i][\warp], 0.01);
									realValue =
									sliderSpec.map(realValue);
								};
								if(~groups[pos][1][i][\warp] == \decibel){
									sliderSpec =
									ControlSpec(0.001, 1, \exp, 0.001);
									realValue = sliderSpec.map(realValue) - 0.001;
								};
								~groups[pos][1][i][\value] = realValue;

								~groups[pos][0][\group].set(
									~groups[pos][1][i][\control],
									~groups[pos][1][i][\value]);
							}
						);

					}, cc);
				})
			});
			~linkerView.refresh;
		});
	});
};

/*** AUX FUNCTIONS ***/
cpuIndicatorRoutine = Routine{
	var value, cpu;
	inf.do({
		if(s.serverRunning, {
			cpu = s.avgCPU;
			cpuIndicator.value = cpu/100;
			cpuValue.string_(cpu.trunc(0.01).asString++"%");
		});
		0.2.wait;
	});
};
cpuIndicatorRoutine.play(AppClock);

emptyWorkspace = {
	filePath = nil;
	synthsList.items_([]);
	synthsManager[\hideSliders].(
		controlSliders, slidersLabel,
		maxSliders, minSliders, slidersValue);
	playColor = constants[\playColorDeactivated];
	playColorNow = constants[\playColorDeactivated];
	playStopView.refresh;
	~groups = [];
	~midiMaps = Array.fill(8, { Dictionary() });
	Server.freeAll;
};

/*parametersView.visible_(false);
~linkerView.visible_(true);
linkModeBtn.visible_(true);*/
)

ColorHsvPicker()