var dict = Dictionary();

var mainFont = "Book Antiqua";
var mouseOnFont = "Palatino Linotype";
//var mouseOnFont = "Century Schoolbook";

dict.put(\programName, "LiveSynth: ");
dict.put(\synthsPath, ~path +/+ "synthDefinitions");

dict.put(\maxNumControls, 50);
dict.put(\controlsOffset, 70);

dict.put(\mainBackground, Color.new255(40, 42, 54));
dict.put(\viewBackground, Color.new255(48, 52, 77));
dict.put(\parametersViewBackground, Color.new255(40, 42, 54));
dict.put(\linkerViewBackground, Color.new255(132, 162, 216));
dict.put(\menuStringColor, Color.white);
dict.put(\menuStringSelectedColor, Color.new255(213, 213, 213));
dict.put(\synthEditorListStringColor, Color.new255(213, 213, 213));
dict.put(\synthEditorListHiliteColor, Color.new255(22, 22, 28));
dict.put(\synthEditorNotSavedColor, Color.new255(194, 80, 80));
dict.put(\synthEditorSavedColor, Color.new255(62, 187, 81));
dict.put(\newFolderColor, Color.new255(37, 80, 29));
dict.put(\playColor, Color.new255(62, 187, 81));
dict.put(\playColorMouseOn, Color.new255(62, 250, 81));
dict.put(\stopColor, Color.new255(194, 80, 80));
dict.put(\stopColorMouseOn, Color.new255(250, 80, 80));
dict.put(\playColorDeactivated, Color.new255(63, 101, 146));
dict.put(\stopColorDeactivated, Color.new255(63, 101, 146));
dict.put(\masterKnobMaxColor, Color.new255(24, 35, 48));
dict.put(\masterKnobMinColor, Color.new255(63, 101, 146));
dict.put(\masterIndicatorColor, dict[\playColor]);
dict.put(\masterDeviationColor, dict[\synthEditorListStringColor]);
dict.put(\masterBackgroundDeviationColor, dict[\playColor]);
dict.put(\parametersColor, Color.new255(213, 213, 213));
dict.put(\parametersMouseOnColor, Color.new255(62, 187, 81));
dict.put(\slidersMaxColor, Color.new255(63, 101, 146));
dict.put(\slidersMinColor, Color.new255(24, 35, 48));
dict.put(\slidersKnobColor, Color.new255(242, 242, 242));
dict.put(\slidersKnobColor, Color.new255(242, 242, 242));
dict.put(\visibleTrueColor, Color.new255(24, 78, 12));
dict.put(\visibleFalseColor, Color.new255(194, 80, 80));
dict.put(\inspectorStringColor, Color.new255(213, 213, 213));
dict.put(\notActionedColor, Color.new255(194, 80, 80));
dict.put(\clearBtnBackground, Color.new255(38, 42, 67));
dict.put(\midiOnListening, Color.new255(140, 102, 35));
dict.put(\linkModeMoveColor, Color.new255(79, 21, 141));
dict.put(\linkModeCreateBusColor, Color.new255(21, 141, 76));
dict.put(\linkModeDeleteBusColor, Color.new255(229, 68, 68));
dict.put(\busColor, Color.new255(21, 141, 76));
dict.put(\busEliminatorColor, Color.new255(164, 21, 21));
dict.put(\linkModeInspectorColor, Color.new255(21, 93, 141));

dict.put(\rectSize, 50);
dict.put(\ovalColor, Color.new255(35, 68, 107));
dict.put(\ovalSelectedColor, Color.new255(7, 122, 130));

dict.put(\mainToolBarFont, Font(mainFont, 16));
dict.put(\mainToolBarMouseOnFont, Font(mouseOnFont, 16));
dict.put(\mainToolBarMenuFont, Font(mainFont, 14));
dict.put(\synthsEditorListFont, Font(mainFont, 14));
dict.put(\synthsListFont, Font(mainFont, 18));
dict.put(\synthsEditorCodeFont, Font(mainFont, 14));
dict.put(\popUpFont, Font(mainFont, 16));
dict.put(\buttonFont, Font(mainFont, 16));
dict.put(\buttonMouseOnFont, Font(mouseOnFont, 18));
dict.put(\parametersFont, Font(mainFont, 18));
dict.put(\parametersMouseOnFont, Font(mouseOnFont, 20));
dict.put(\parametersInputFont, Font(mainFont, 16));
dict.put(\parametersInpuMouseOnFont, Font(mainFont, 18));
dict.put(\inspectorFont, Font(mainFont, 16));
dict.put(\timerFont, Font(mainFont, 40));

dict;