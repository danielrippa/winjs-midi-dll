unit ChakraMIDI;

{$mode delphi}

interface

  uses
    ChakraTypes;

  function GetJsValue: TJsValue;

implementation

  uses
    Chakra, ChakraUtils, Win32MIDI;

  function ChakraAddChannel(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    Result := Undefined;

    CheckParams('addChannel', Args, ArgCount, [jsNumber], 1);
    MIDIPlayer.AddChannel(JsNumberAsInt(Args^));
  end;

  function ChakraSetChannelInstrument(Args: PJsValue; ArgCount: Word): TJsValue;
  var
    aChannel, aInstrument: Integer;
  begin
    Result := Undefined;

    CheckParams('setChannelInstrument', Args, ArgCount, [jsNumber, jsNumber], 2);

    aChannel := JsNumberAsInt(Args^); Inc(Args);
    aInstrument := JsNumberAsInt(Args^);

    MIDIPlayer.Channel[aChannel].Instrument := aInstrument;
  end;

  function ChakraPlayChannelNote(Args: PJsValue; ArgCount: Word): TJsValue;
  var
    aChannel, aNote: Integer;
  begin
    Result := Undefined;

    CheckParams('playChannelNote', Args, ArgCount, [jsNumber, jsNumber], 2);

    aChannel := JsNumberAsInt(Args^); Inc(Args);
    aNote := JsNumberAsInt(Args^);

    MIDIPlayer.Channel[aChannel].PlayNote(aNote);
  end;

  function ChakraReleaseChannelNote(Args: PJsValue; ArgCount: Word): TJsValue;
  var
    aChannel, aNote: Integer;
  begin
    Result := Undefined;

    CheckParams('releaseChannelNote', Args, ArgCount, [jsNumber, jsNumber], 2);

    aChannel := JsNumberAsInt(Args^); Inc(Args);
    aNote := JsNumberAsInt(Args^);

    MIDIPlayer.Channel[aChannel].ReleaseNote(aNote);
  end;

  function ChakraPlayPercussion(Args: PJsValue; ArgCount: Word): TJsValue;
  var
    aPercussionNote: Integer;
  begin
    Result := Undefined;

    CheckParams('releaseChannelNote', Args, ArgCount, [jsNumber], 1);
    aPercussionNote := JsNumberAsInt(Args^);

    MIDIPlayer.PercussionChannel.PlayNote(aPercussionNote);
  end;

  function GetJsValue;
  begin

    Result := CreateObject;

    SetFunction(Result, 'addChannel', ChakraAddChannel);
    SetFunction(Result, 'setChannelInstrument', ChakraSetChannelInstrument);
    SetFunction(Result, 'playChannelNote', ChakraPlayChannelNote);
    SetFunction(Result, 'releaseChannelNote', ChakraReleaseChannelNote);
    SetFunction(Result, 'playPercussion', ChakraPlayPercussion);

  end;

end.
