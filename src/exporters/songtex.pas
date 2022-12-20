unit SongTeX;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Lyrics, Strings;

type
  { TSongTexFile -> a TeX like file which exports whole slides }
  TSongTeXFile = Class
  public
    NextSongFile: TStringList;
    constructor Create;
    destructor Destroy;
    procedure AddFile(SongFile: TRepoFile);
    procedure SaveTofile(FileName: String);
    procedure LoadFromFile(FileName: String);
    function HasNextSongfile: String;
  private
    FileContent: TStringList;
    SongFiles: array of TRepoFile;
    ParsingIndex: Integer;
  end;

implementation

constructor TSongTeXFile.Create;
begin
  inherited;
  FileContent := TStringList.Create;
  FileContent.Add('% This file has been created automatically');
  FileContent.Add('% It can be opened with Cantara (https://cantara.app)');
  FileContent.Add('% Manually editing the content may damage the import');
  ParsingIndex := -1;
  NextSongFile := TStringList.Create;
end;

destructor TSongTeXFile.Destroy;
begin
  FileContent.Free;
  FreeAndNil(NextSongFile);
  inherited;
end;

procedure TSongTeXFile.AddFile(SongFile: TRepoFile);
var SongFileContent: TStringList;
begin
  SetLength(SongFiles, length(SongFiles)+1);
  SongFileContent := TStringList.Create;
  SongFileContent.LoadFromFile(SongFile.FilePath);
  FileContent.Add('\beginfile{' + SongFile.FileName + '}');
  fileContent.AddStrings(SongFileContent);
  FileContent.Add('\endfile');
end;

procedure TSongTexFile.SaveToFile(FileName: String);
begin
  FileContent.SaveToFile(FileName);
end;

procedure TSongTexFile.LoadFromFile(FileName: String);
begin
  FileContent.Clear;
  FileContent.LoadFromFile(FileName);
  ParsingIndex := 0;
end;

function TSongTexFile.HasNextSongfile: String;
var curSongname: string;
begin
  while (pos('\beginfile{',FileContent.Strings[ParsingIndex]) < 0) and (ParsingIndex < FileContent.Count) do
  begin
    Inc(ParsingIndex);
  end;
  { #todo 1 -o'Jan Martin Reckel' :  Implement the appropriate logic for the parser}
  if pos('\beginfile{',FileContent.Strings[ParsingIndex]) >= 0 then
  begin
    NextSongFile.Clear;
    curSongname := copy(FileContent.Strings[ParsingIndex],length('\beginfile{'),
                length(FileContent.Strings[ParsingIndex])-11+1);
    inc(ParsingIndex);
    while (ParsingIndex < FileContent.Count) and (FileContent.Strings[ParsingIndex] <> '\endfile') do
    begin
      NextSongFile.Add(FileContent.Strings[ParsingIndex]);
      inc(ParsingIndex);
    end;
    Result := curSongName;
  end;
  Result := '';
end;

end.
