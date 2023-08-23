var dict = Dictionary();
var import, constants;
var createBus, insertBus, moveSynth, removeSynth, busEliminator;

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

	~allBus = ~allBus.add(newBus);

	[allBusStart, allBusEnd, currBus, clicked];
};

insertBus = {
	arg busReceiver, clicked,
	allBusStart, allBusEnd, currBus, x, y;
	var centroid, ok=true;
	~groups.do { |synth, i|
		if(synth[0][\rect].contains(Point(x, y))) {
			busReceiver = i;
		};
	};


	if(busReceiver == nil,
		{
			busReceiver = -1;
		}
	);

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
	[allBusStart, allBusEnd, busReceiver];
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

dict.put(\createBus, createBus);
dict.put(\insertBus, insertBus);
dict.put(\moveSynth, moveSynth);
dict.put(\busEliminator, busEliminator);
dict.put(\removeSynth, removeSynth);

dict;