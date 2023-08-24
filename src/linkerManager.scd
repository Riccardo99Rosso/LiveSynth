var dict = Dictionary();
var import, constants;
var createBus, insertBus, moveSynth, removeSynth, busEliminator,
linkWin;

import = {
	|path|
	var file, content;
	file = File.open(path.standardizePath, "r");
	content = file.readAllString;
	file.close;
	this.interpret(content);
};

constants = import.(~constants);

createBus = {
	arg allBusStart, allBusEnd, currBus, clicked, synths;
	var centroid, newBus;

	centroid = ~groups[clicked][0][\rect].origin;
	centroid = Point(
		(centroid.x+(constants[\rectSize]/2)),
		(centroid.y)+(constants[\rectSize]/2));

	allBusStart = allBusStart.add(centroid);
	allBusEnd = allBusEnd.add(centroid);
	currBus = allBusStart.size - 1;

	newBus = Dictionary();

	newBus.put(\fromId, ~groups[clicked][0][\id]);
	newBus.put(\toId, ~groups[clicked][0][\id]);
	newBus.put(\from, centroid);
	newBus.put(\to, centroid);
	newBus.put(\fromControl, nil);
	newBus.put(\toControl, nil);

	~allBus = ~allBus.add(newBus);

	[allBusStart, allBusEnd, currBus, clicked];
};

insertBus = {
	arg busReceiver, clicked,
	allBusStart, allBusEnd, currBus, x, y;
	var centroid, done, deleteAfter = false;

	done = true;

	~groups.do { |synth, i|
		if(synth[0][\rect].contains(Point(x, y))) {
			busReceiver = i;
		};
	};

	if(busReceiver == nil,
		{
			busReceiver = -1;
		},
		{
			~allBus.do({
				arg busDict, index;
				if((
					(busDict[\fromId] == ~groups[clicked][0][\id]) &&
					(busDict[\toId] == ~groups[busReceiver][0][\id])
				),{
					deleteAfter = true;
				});
			});
		}
	);

	if(deleteAfter == true, {
		busReceiver = -1;
	});

	if(((busReceiver < 0) || (busReceiver <= clicked)),
		{
			var toDelete = nil;
			~allBus.do({
				arg busDict, index;

				if(busDict[\fromId] == busDict[\toId],
					{
						toDelete = index;
					}
				)
			});

			if(toDelete != nil, {
				~allBus.removeAt(toDelete);
			});
			done = false;
		},
		{
			centroid = ~groups[busReceiver][0][\rect].origin;
			centroid = Point(
				(centroid.x+(constants[\rectSize]/2)),
				(centroid.y)+(constants[\rectSize]/2));

			~allBus.collect({
				arg busDict;

				if(busDict[\fromId] == busDict[\toId],
					{
						busDict[\toId] = ~groups[busReceiver][0][\id];
						busDict[\to] = centroid;
					}
				)
			});
		}
	);
	[allBusStart, allBusEnd, busReceiver, done];
};

moveSynth = {
	arg relativeWhere, clicked, allBusStart, allBusEnd, x, y;
	var rect, tmpCoord, centroid, id;

	rect = ~groups[clicked][0][\rect];
	id = ~groups[clicked][0][\id];
	centroid = ~groups[clicked][0][\rect].origin;
	centroid = Point(
		(centroid.x+(constants[\rectSize]/2)),
		(centroid.y)+(constants[\rectSize]/2));

	~allBus.collect({
		arg busDict;
		var fromId, toId, from, to;

		fromId = busDict[\fromId];
		toId = busDict[\toId];

		if(fromId == id, {
			busDict[\from] = centroid;
		});
		if(toId == id, {
			busDict[\to] = centroid;
		});
	});

	tmpCoord = Point(x, y) - relativeWhere;
	if(((tmpCoord.x > -10) &&
		(tmpCoord.y > -10) &&
		(tmpCoord.y < (~linkerView.bounds.height - 10)) &&
		(tmpCoord.x < (~linkerView.bounds.width - 10))
	),
	{
		rect.origin = tmpCoord;
		~groups[clicked][0][\rect] = rect;
		~linkerView.refresh;
	});
};

busEliminator = {
	arg busEliminator, clicked;
	var centroid;

	centroid = ~groups[clicked][0][\rect].origin;
	centroid = Point(
		(centroid.x+(constants[\rectSize]/2)),
		(centroid.y)+(constants[\rectSize]/2));
	busEliminator[2] = centroid;
	busEliminator[3] = centroid;
	2.postln;
	busEliminator;
};

removeSynth = {
	arg id;
	var toDelete = [];
	~allBus.postln;
	~allBus.do({
		arg busDict, index;
		var fromId, toId, from, to;

		fromId = busDict[\fromId];
		toId = busDict[\toId];


		if(((fromId == id) || (toId == id)), {
			toDelete = toDelete.add(index - toDelete.size);
		});
	});

	if(toDelete.size > 0, {
		toDelete.do({
			arg item;
			item.postln;
			~allBus.removeAt(item);
		})
	});
};

linkWin = {
	arg busReceiver, clicked,
	allBusStart, allBusEnd, currBus, x, y, synthsList;
	var win, fromSynthString, toSynthString, fromControls, toControls,
	fromControlsMenu, toControlsMenu, argValueList, index, typeText, typeMenu,
	channelsText, channelsBox, linkBtn, linked = false, from, to;

	from = ~groups[clicked][0][\id];
	to = ~groups[busReceiver][0][\id];

	win = Window("Link Parameters")
	.setTopLeftBounds(Rect(x+100, y-100, 250, 242))
	.background_(constants[\mainBackground])
	.acceptsMouseOver_(true)
	.alwaysOnTop_(true)
	.onClose_({
		if(linked == false, {
			~groups.do { |synth, i|
				if(synth[0][\rect].contains(Point(x, y))) {
					busReceiver = i;
				};
			};
			/*		clicked.postln;
			busReceiver.postln;*/

			if(((busReceiver.notNil) && (busReceiver != clicked)), {
				var toDelete;

				~allBus.do({
					arg busDict, index;

					if(((busDict[\fromId] == from) && (busDict[\toId] == to)) , {
						toDelete = index;
					});
				});
				~allBus.removeAt(toDelete);
			});
		});
		~linkerView.refresh;
	});

	fromSynthString = StaticText(win, Rect(10, 12, 110, 30))
	.stringColor_(constants[\synthEditorListStringColor])
	.string_(~groups[clicked][0][\name].asString)
	.font_(constants[\popUpFont]);

	argValueList = ~groups[clicked][1];
	fromControls = [];
	argValueList.do({
		arg dict;
		var control;
		control = dict[\control];
		fromControls = fromControls.add(control.asString);
	});

	fromControlsMenu = PopUpMenu(win, Rect(120, 12, 120, 30))
	.background_(constants[\viewBackground])
	.canFocus_(false)
	.items_(fromControls)
	//.value_(typeList.value)
	.stringColor_(constants[\synthEditorListStringColor])
	.font_(constants[\popUpFont]);

	index = fromControls.find(["out"]);

	if(index != nil,
		{
			fromControlsMenu.value_(index);
		},
		{
			fromControlsMenu.value_(0);
		}
	);

	toSynthString = StaticText(win, Rect(10, 57, 110, 30))
	.stringColor_(constants[\synthEditorListStringColor])
	.string_(~groups[busReceiver][0][\name].asString)
	.font_(constants[\popUpFont]);

	argValueList = ~groups[busReceiver][1];
	toControls = [];
	argValueList.do({
		arg dict;
		var control;
		control = dict[\control];
		toControls = toControls.add(control.asString);
	});

	toControlsMenu = PopUpMenu(win, Rect(120, 57, 120, 30))
	.background_(constants[\viewBackground])
	.canFocus_(false)
	.items_(toControls)
	//.value_(typeList.value)
	.stringColor_(constants[\synthEditorListStringColor])
	.font_(constants[\popUpFont]);

	index = toControls.find(["in"]);

	if(index != nil,
		{
			toControlsMenu.value_(index);
		},
		{
			toControlsMenu.value_(0);
		}
	);

	typeText = StaticText(win, Rect(10, 102, 80, 30))
	.stringColor_(constants[\synthEditorListStringColor])
	.string_("Type: ")
	.font_(constants[\popUpFont]);

	typeMenu = PopUpMenu(win, Rect(120, 102, 120, 30))
	.background_(constants[\viewBackground])
	.canFocus_(false)
	.items_(["Audio", "Control"])
	.value_(0)
	.stringColor_(constants[\synthEditorListStringColor])
	.font_(constants[\popUpFont]);

	channelsText = StaticText(win, Rect(10, 147, 80, 30))
	.stringColor_(constants[\synthEditorListStringColor])
	.string_("Channels: ")
	.font_(constants[\popUpFont]);

	channelsBox = NumberBox(win, Rect(120, 147, 120, 30))
	.font_(constants[\popUpFont])
	.value_(1)
	.clipLo_(1)
	.background_(constants[\viewBackground])
	.typingColor_(constants[\synthEditorListStringColor])
	.normalColor_(constants[\synthEditorListStringColor]);

	linkBtn = Button(win, Rect(75, 200, 100, 30))
	.font_(constants[\popUpFont])
	.canFocus_(false)
	.states_([["Link",
		constants[\synthEditorListStringColor],
		constants[\newFolderColor]
	]])
	.mouseOverAction_({
		linkBtn.font_(constants[\buttonMouseOnFont]);
		linkBtn.states_([["Link", constants[\menuStringSelectedColor],
			constants[\viewBackground]]])
	})
	.mouseLeaveAction_({
		linkBtn.font_(constants[\buttonFont]);
		linkBtn.states_([["Link", constants[\synthEditorListStringColor],
			constants[\newFolderColor]]])
	})
	.action_({
		var startControl, endControl;
		linked = true;
		startControl = ~groups[clicked][1][fromControlsMenu.value][\control];
		endControl = ~groups[busReceiver][1][toControlsMenu.value][\control];
		~allBus.collect({
			arg busDict;

			if(((busDict[\fromId] == from) && (busDict[\toId] == to)),
				{
					var newBus;

					busDict.put(\fromControl, fromControlsMenu.value);
					busDict.put(\endControl, toControlsMenu.value);
					synthsList.valueAction_(clicked);


					//Il to è già preso, me ne frego dei parametri inseriti e non creo un nuovo
					//bus. Utilizzo quello già presente

					if(~groups[clicked][1][fromControlsMenu.value][\number] == false, {
						linked = false;
					});

					if(~groups[clicked][1][fromControlsMenu.value][\number] == true &&
						~groups[busReceiver][1][toControlsMenu.value][\number] == true, {
							if(channelsBox.value >= 1, {
								if(typeMenu.value == 0,
									{
										newBus = Bus.audio(s, channelsBox.value);
										busDict.put(\type, "audio");
										busDict.put(\channels, channelsBox.value);
									},
									{
										newBus = Bus.control(s, channelsBox.value);
										busDict.put(\type, "control");
										busDict.put(\channels, channelsBox.value);
									}
								);

								~groups[clicked][0][\group].set(
									startControl, newBus);
								~groups[busReceiver][0][\group].set(
									endControl, newBus);
								~groups[clicked][1][fromControlsMenu.value][\value] = newBus;
								~groups[busReceiver][1][toControlsMenu.value][\value] = newBus;
								~groups[clicked][1][fromControlsMenu.value][\number] = false;
								~groups[busReceiver][1][toControlsMenu.value][\number] = false;
							},
							{

							});
						},
						{
							"try".postln;
							~groups[busReceiver][1][toControlsMenu.value][\number].postln;
							~groups[clicked][1][fromControlsMenu.value][\number].postln;
							linked = false;
							if(~groups[busReceiver][1][toControlsMenu.value][\number] == false &&
								~groups[clicked][1][fromControlsMenu.value][\number] == true,
								{
									var bus, control;
									bus = ~groups[busReceiver][1][toControlsMenu.value][\value];
									~groups[clicked][1][fromControlsMenu.value][\value] = bus;
									~groups[clicked][1][fromControlsMenu.value][\number] = false;
									~groups[clicked][0][\group].set(
										startControl, bus);
									"eccomi".postln;
									linked = true;
								},

							);
						}
					);
				}
			)
		});
		win.close;
	});

	[win];
};

dict.put(\createBus, createBus);
dict.put(\insertBus, insertBus);
dict.put(\moveSynth, moveSynth);
dict.put(\busEliminator, busEliminator);
dict.put(\removeSynth, removeSynth);
dict.put(\linkWin, linkWin);

dict;