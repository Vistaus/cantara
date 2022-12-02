unit songpresentations;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Lyrics, Strings;

type
  { TSongTexFile -> a TeX like file which exports whole slides }
  TSongTeXFile = class
    public
      procedure AddFile(SongFile: TRepoFile);
    private
      FileContent: TStringList;
      SongFiles: array of TRepoFile;
  end;

implementation

constructor TSongTeXFile.Create;
begin
  inherited;
  FileContent := TStringList.Create;
  FileContent.Add('% This file has been created automatically');
  FileContent.Add('% It can be opened with Cantara (https://cantara.app)');
  FileContent.Add('% Manually editing the content may damage the import');
end;

destructor TSongTeXFile.Destroy;
begin
  FileContent.Free;
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

end.

