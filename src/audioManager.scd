var dict = Dictionary();
var import, constants, keyCode;
var serverNotRunningWin, audioDrivers, masterKnob, serverMeter,
freqScope, cpuIndicator;

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

serverNotRunningWin = {
	arg menu;
	var win, left, top, text,
	driversBtn, postponeBtn, width, height;

	width = 280;
	height = 110;

	win = Window("Audio disabled")
	.setTopLeftBounds(
		Rect(
			(Window.screenBounds.width-width)/2,
			(Window.screenBounds.height-height)/3,
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
	.string_("Audio disabled.\nRecommended: Select drivers")
	.font_(constants[\popUpFont]);

	driversBtn = Button(win, Rect(20, 70, 110, 30))
	.font_(constants[\popUpFont])
	.canFocus_(false)
	.states_([["Drivers",
		constants[\synthEditorListStringColor],
		constants[\newFolderColor]
	]])
	.mouseOverAction_({
		driversBtn.font_(constants[\buttonMouseOnFont]);
		driversBtn.states_([["Drivers", constants[\menuStringSelectedColor],
			constants[\viewBackground]]])
	})
	.mouseLeaveAction_({
		driversBtn.font_(constants[\buttonFont]);
		driversBtn.states_([["Drivers", constants[\synthEditorListStringColor],
			constants[\newFolderColor]]])
	})
	.action_({
		audioDrivers.().front;
		win.close;
	});

	postponeBtn = Button(win, Rect(150, 70, 110, 30))
	.font_(constants[\popUpFont])
	.canFocus_(false)
	.states_([["Postpone",
		constants[\synthEditorListStringColor],
		constants[\synthEditorNotSavedColor]
	]])
	.mouseOverAction_({
		postponeBtn.font_(constants[\buttonMouseOnFont]);
		postponeBtn.states_([["Postpone", constants[\menuStringSelectedColor],
			constants[\viewBackground]]])
	})
	.mouseLeaveAction_({
		postponeBtn.font_(constants[\buttonFont]);
		postponeBtn.states_([["Postpone", constants[\synthEditorListStringColor],
			constants[\synthEditorNotSavedColor]]])
	})
	.action_({
		win.close;
	});

	win;
};

audioDrivers = {
	var outAudio, inAudio, default, defIn, defOut, inVal, outVal,
	audioWin, inText, outText, inList, fun, outList, reset,
	width, height;

	outAudio = ServerOptions.outDevices.asArray;
	inAudio = ServerOptions.inDevices.asArray;
	default = Server.default.options;
	defIn = 0;
	defOut = 0;
	inVal = 0;
	outVal = 0;
	width = 710;
	height = 310;

	audioWin = Window("Audio drivers")
	.setTopLeftBounds(
		Rect(
			(Window.screenBounds.width-width)/2,
			(Window.screenBounds.height-height)/3,
			width,
			height
		)
	)
	.alwaysOnTop_(true)
	.background_(constants[\mainBackground])
	.acceptsMouseOver_(true);

	inText = StaticText(audioWin, Rect(10, 20, 150, 25))
	.font_(constants[\synthsListFont])
	.string_("Input Devices")
	.stringColor_(constants[\menuStringSelectedColor]);

	outText = StaticText(audioWin, Rect(400, 20, 150, 25))
	.font_(constants[\synthsListFont])
	.string_("Output Devices")
	.stringColor_(constants[\menuStringSelectedColor]);

	inList = ListView(audioWin,Rect(10,60,300,200))
	.items_(inAudio)
	.background_(constants[\viewBackground])
	.font_(constants[\synthsEditorListFont])
	.stringColor_(constants[\synthEditorListStringColor])
	.selectedStringColor_(constants[\synthEditorListStringColor])
	.hiliteColor_(constants[\synthEditorListHiliteColor])
	.value_(defIn)
	.action_({ arg sbs;
		inVal = sbs.value;
		defIn = inVal;
		//[sbs.value, inList.items[sbs.value]].postln;
	});

	outList = ListView(audioWin,Rect(400,60,300,200))
	.items_(outAudio)
	.background_(constants[\viewBackground])
	.font_(constants[\synthsEditorListFont])
	.stringColor_(constants[\synthEditorListStringColor])
	.selectedStringColor_(constants[\synthEditorListStringColor])
	.hiliteColor_(constants[\synthEditorListHiliteColor])
	.value_(defOut)
	.action_({ arg sbs;
		outVal = sbs.value;
		defOut = outVal;
	});

	reset = Button(audioWin, Rect(620, 270, 80, 30))
	.font_(constants[\buttonFont])
	.states_([["Apply",
		constants[\synthEditorListStringColor],
		constants[\newFolderColor]]])
	.mouseOverAction_({
		reset.font_(constants[\buttonMouseOnFont]);
		reset.states_([["Apply", constants[\menuStringSelectedColor],
			constants[\viewBackground]]])
	})
	.mouseLeaveAction_({
		reset.font_(constants[\buttonFont]);
		reset.states_([["Apply", constants[\synthEditorListStringColor],
			constants[\newFolderColor]]])
	})
	.action_({
		Server.killAll;
		Server.default.options.inDevice_(inList.items[inVal]);
		Server.default.options.outDevice_(outList.items[outVal]);
		s.reboot;
		audioWin.close;

	});

	audioWin;
};

masterKnob = {
	arg view;
	var master, masterText, masterValue, maxColor, minColor;

	masterText = StaticText(view, Rect(40, 10, 100, 30))
	.string_("Master")
	.stringColor_(constants[\menuStringSelectedColor])
	.font_(constants[\synthsListFont])
	.align_(\center);

	masterValue = StaticText(view, Rect(50, 180, 77.5, 30))
	.string_(s.volume.volume.trunc(0.001).asString)
	.align_(\center)
	.font_(constants[\synthsListFont])
	.stringColor_(constants[\menuStringSelectedColor])
	.canFocus_(false);

	maxColor = constants[\masterKnobMaxColor];
	minColor = constants[\masterKnobMinColor];

	master = Knob(view, Rect(30, 50, 120, 120))
	.color_([
		constants[\masterKnobMaxColor],
		constants[\masterIndicatorColor],
		constants[\masterDeviationColor],
		constants[\masterBackgroundDeviationColor]
	])
	.background_(constants[\masterKnobMaxColor])
	.canFocus_(false)
	.value_(s.volume.volume.dbamp)
	.action_({
		var value;
		value = master.value;
		value = value.ampdb;
		s.volume.volume = value;
		masterValue.string_(value.trunc(0.001).asString);
		master.background_(minColor.blend(maxColor, master.value));
	});

	master;
};

cpuIndicator = {
	arg view;
	var indicator, cpuText, cpuValue;

	cpuText = StaticText(view, Rect(180, 10, 50, 30))
	.string_("Cpu")
	.font_(constants[\synthsListFont])
	.stringColor_(constants[\menuStringSelectedColor])
	.align_(\center);

	indicator = LevelIndicator(view, Rect(190, 50, 30, 115))
	.warning_(0.5)
	.critical_(0.85);

	cpuValue = StaticText(view, Rect(180, 180, 50, 30))
	.string_(0)
	.font_(constants[\synthsListFont])
	.stringColor_(constants[\menuStringSelectedColor])
	.align_(\center);


	[indicator, cpuValue];
};

serverMeter = {
	arg view;
	var meter;

	meter = ServerMeterView(s, view, 610@0,
		s.options.numInputBusChannels,
		s.options.numOutputBusChannels
	);

	meter;
};

freqScope = {
	arg view;
	var scope;

	scope = FreqScopeView(view, Rect(280, 10, 300, 210), s)
	.freqMode_(1)
	.active_(true);

	scope;
};

dict.put(\serverNotRunningWin, serverNotRunningWin);
dict.put(\audioDrivers, audioDrivers);
dict.put(\masterKnob, masterKnob);
dict.put(\cpuIndicator, cpuIndicator);
dict.put(\serverMeter, serverMeter);
dict.put(\freqScope, freqScope);

dict;