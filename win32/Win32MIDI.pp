unit Win32MIDI;

{$mode delphi}

interface

  uses
    MMSystem;

  type

    TMIDIDevice = class
      private
        FHandle: HMIDIOUT;
        function GetVolume: DWORD;
        procedure SetVolume(Value: DWORD);
        procedure ShortMsg(Channel, Msg, Param1, Param2: Integer);
      public
        constructor Create;
        property Volume: DWORD read GetVolume write SetVolume;
    end;

    TMIDIChannel = class
      private
        FChannelNumber: Byte;
        FMIDIDevice: TMIDIDevice;
        FInstrument: Integer;

        procedure ShortMsg(Msg, Param1, Param2: Integer);
        procedure SetInstrument(Value: Integer);
      public
        constructor Create(aMIDIDevice: TMIDIDevice; aChannelNumber: Integer);
        property ChannelNumber: Byte read FChannelNumber;
        property Instrument: Integer read FInstrument write SetInstrument;
        procedure PlayNote(Note: Byte; Velocity: Byte = 127);
        procedure ReleaseNote(Note: Byte; Velocity: Byte =127);
    end;

    TMIDIPlayer = record
      private
        FDevice: TMIDIDevice;
        FChannels: array of TMIDIChannel;
        procedure Init;
        procedure Done;

        function GetChannel(aChannelNumber: Byte): TMIDIChannel;
        function GetPercussionChannel: TMIDIChannel;
      public
        function AddChannel(ChannelNumber: Byte): Boolean;
        property Channel[ChannelNumber: Byte]: TMIDIChannel read GetChannel;
        property PercussionChannel: TMIDIChannel read GetPercussionChannel;
    end;

  var

    MIDIPlayer: TMIDIPlayer;

implementation

  uses
    SysUtils;

  constructor TMIDIDevice.Create;
  begin
    if midiOutGetNumDevs > 0 then begin
      if midiOutOpen(@FHandle, MIDI_MAPPER, 0, 0, CALLBACK_NULL) = MMSYSERR_NOERROR then begin
        Volume := $FFFFFFFF;
      end;
    end;
  end;

  function TMIDIDevice.GetVolume: DWORD;
  begin
    Result := midiOutGetVolume(FHandle, @Result);
  end;

  procedure TMIDIDevice.SetVolume(Value: DWORD);
  begin
    midiOutSetVolume(FHandle, Value);
  end;

  procedure TMIDIDevice.ShortMsg(Channel, Msg, Param1, Param2: Integer);
  begin
    midiOutShortMsg(FHandle, Channel or Msg + (Param1 shl 8) + (Param2 shl 16));
  end;

  constructor TMIDIChannel.Create(aMIDIDevice: TMIDIDevice; aChannelNumber: Integer);
  begin
    FMIDIDevice := aMIDIDevice;
    FChannelNumber := aChannelNumber;
  end;

  procedure TMIDIChannel.ShortMsg(Msg, Param1, Param2: Integer);
  begin
    FMIDIDevice.ShortMsg(ChannelNumber, Msg, Param1, Param2);
  end;

  procedure TMIDIChannel.SetInstrument(Value: Integer);
  begin
    ShortMsg($C0, Value, 0);
  end;

  procedure TMIDIChannel.PlayNote(Note: Byte; Velocity: Byte = 127);
  begin
    ShortMsg($90, Note, Velocity);
  end;

  procedure TMIDIChannel.ReleaseNote(Note: Byte; Velocity: Byte =127);
  begin
    ShortMsg($80, Note, Velocity);
  end;

  procedure TMIDIPlayer.Init;
  begin
    FDevice := TMIDIDevice.Create;
    AddChannel(9);
  end;

  procedure TMIDIPlayer.Done;
  var
    I: Integer;
  begin
    for I := 0 to Length(FChannels) - 1 do begin
      FChannels[I].Free;
    end;
  end;

  function TMIDIPlayer.AddChannel(ChannelNumber: Byte): Boolean;
  var
    I: Integer;
  begin
    for I := 0 to Length(FChannels) - 1 do begin
      if ChannelNumber = FChannels[I].ChannelNumber then begin
        Result := False;
        Exit;
      end;
    end;
    SetLength(FChannels, Length(FChannels) + 1);
    FChannels[Length(FChannels)-1] := TMIDIChannel.Create(FDevice, ChannelNumber);
  end;

  function TMIDIPlayer.GetChannel(aChannelNumber: Byte): TMIDIChannel;
  var
    I: Integer;
  begin
    for I := 0 to Length(FChannels) - 1 do begin
      if aChannelNumber = FChannels[I].ChannelNumber then begin
        Result := FChannels[I];
        Exit;
      end;
    end;
  end;

  function TMIDIPlayer.GetPercussionChannel: TMIDIChannel;
  begin
    Result := Channel[9];
  end;

  initialization
    MIDIPlayer.Init;

  finalization
    MIDIPlayer.Done;

end.
