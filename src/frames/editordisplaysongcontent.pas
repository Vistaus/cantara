unit editordisplaysongcontent;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, Menus, Lyrics,
  Settings, ComCtrls, Dialogs;

type

  { TfrmDisplaySongContent }

  TfrmDisplaySongContent = class(TFrame)
    btnConvertCCLIFileToSongFormat: TButton;
    edtSongName: TEdit;
    labelCCLIImportHint: TLabel;
    lblSongNameContent: TLabel;
    lblSongName: TLabel;
    memoCode: TMemo;
    ccliimporthint: TPanel;
    Save: TMenuItem;
    menuSong: TMenuItem;
    procedure btnConvertCCLIFileToSongFormatClick(Sender: TObject);
    constructor Create(AOwner: TComponent);
    procedure edtSongNameEditingDone(Sender: TObject);
    procedure edtSongNameExit(Sender: TObject);
    procedure edtSongNameMouseLeave(Sender: TObject);
    procedure FrameClick(Sender: TObject);
    procedure lblSongNameContentClick(Sender: TObject);
    procedure lblSongNameContentDblClick(Sender: TObject);
    procedure memoCodeChange(Sender: TObject);
    procedure memoCodeKeyPress(Sender: TObject; var Key: char);
    procedure menuSongClick(Sender: TObject);
    procedure SaveClick(Sender: TObject);
   //  procedure lblSongNameContentDblClick(Sender: TObject);
  private
    procedure markAsChanged(FileHasChanged: Boolean);
  public
    openFile: TRepoFile;
    openFilePath: String;
    hasChanged: Boolean;
    procedure loadFile(repofile: TRepoFile);
    procedure saveFile;
    procedure RenameSongFile(newName: String);
    //property OnFileChanged: TNotifyEvent read hasChanged write hasChanged;
  end;

ResourceString
  strFileCanNotBeRenamed = 'The File can not be renamed. Make sure that you have the permissions to write to the song repository!';
  strErrorCCLIToSong = 'The file can not be converted. Make sure that you have the permissions to write to the song repository!';

const
  ArchiveFolderName:String = 'archive';

implementation

uses
  songeditor;

{$R *.lfm}

{ TfrmDisplaySongContent }

constructor TfrmDisplaySongContent.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  self.hasChanged := False; // dont run markAsChanged as it may cause exceptions
end;

procedure TfrmDisplaySongContent.btnConvertCCLIFileToSongFormatClick(
  Sender: TObject);
var song: TSong;
  SongFilePath: String;
begin
  song := TSong.Create;
  song.importSongfile(openFile.FilePath);
  SongFilePath := frmSettings.edtRepoPath.Text + PathDelim + openfile.Name + '.song';
  song.exportAsSongFile(SongFilePath);
  // move the old file to the ccli/-subfulder. If it does not exist, create it
  try
    if DirectoryExists(frmSettings.edtRepoPath.Text + PathDelim + ArchiveFolderName) = False then
       CreateDir(frmSettings.edtRepoPath.Text + PathDelim + ArchiveFolderName);
    if not RenameFile(openFile.FilePath, frmSettings.edtRepoPath.Text + PathDelim + ArchiveFolderName + PathDelim + openfile.Name + '.ccli') then // move ccli file to subfolder
       ShowMessage(strErrorCCLIToSong);
       openfile.FileExtension := '.song';
       openfile.FileName:=openfile.Name + openFile.FileExtension;
       openfile.FilePath:=SongFilePath;
       LoadFile(openfile);
       frmSongEdit.loadRepoIntoSongListbox;
       markaschanged(False);
  except
    ShowMessage(strErrorCCLIToSong);
  end;
end;

procedure TfrmDisplaySongContent.edtSongNameEditingDone(Sender: TObject);
begin
  edtSongNameExit(Sender);
  RenameSongFile(edtSongName.Text);
end;

procedure TfrmDisplaySongContent.edtSongNameExit(Sender: TObject);
begin
  edtSongName.Visible:=False;
  if lblSongNameContent.Caption <> edtSongName.Text then
  begin
    lblSongNameContent.Caption:=edtSongName.Text;
    self.markAsChanged(True);
  end;
end;

procedure TfrmDisplaySongContent.edtSongNameMouseLeave(Sender: TObject);
begin
  edtSongName.Visible:=False;
  lblSongNameContent.Caption:=edtSongName.Text;
end;

procedure TfrmDisplaySongContent.FrameClick(Sender: TObject);
begin

end;

procedure TfrmDisplaySongContent.lblSongNameContentClick(Sender: TObject);
begin

end;

procedure TfrmDisplaySongContent.menuSongClick(Sender: TObject);
begin

end;

procedure TfrmDisplaySongContent.SaveClick(Sender: TObject);
begin

end;

procedure TfrmDisplaySongContent.lblSongNameContentDblClick(Sender: TObject);
begin
  edtSongName.Visible := True;
  edtSongName.Text := lblSongNameContent.Caption;
end;

procedure TfrmDisplaySongContent.memoCodeChange(Sender: TObject);
begin

end;

procedure TfrmDisplaySongContent.memoCodeKeyPress(Sender: TObject; var Key: char
  );
begin
  self.markAsChanged(True);
end;

procedure TfrmDisplaySongContent.loadFile(repofile: TRepoFile);
  var songimport: TSong; // needed for checking the type
begin
  self.openFile := repofile;
  self.openFilePath := frmSettings.edtRepoPath.Text + PathDelim + repoFile.FileName;
  memoCode.Lines.LoadFromFile(self.openFilePath);
  lblSongNameContent.Caption:=openFile.Name;
  edtSongName.Text:=openFile.Name;
  self.hasChanged := False; // dont run markAsChanged as it may cause exceptions
  { if CCLI File than show conversion suggestion instead of editor }
  songimport := TSong.Create;
  songimport.importSongFile(openfile.FilePath);
  ccliimporthint.Visible := songimport.IsCCLIFile;
  FreeAndNil(songimport);
end;

procedure TfrmDisplaySongContent.markAsChanged(FileHasChanged: Boolean);
var papa: TTabSheet;
begin
  self.hasChanged:=FileHasChanged;
  papa := Owner as TTabSheet;
  if FileHasChanged then
  begin
    if pos(' [*]', Papa.Caption) = 0 then Papa.Caption := Papa.Caption + ' [*]';
  end else
    Papa.Caption := openFile.Name;
end;

procedure TfrmDisplaySongContent.SaveFile;
begin
  memoCode.Lines.SaveToFile(self.openFilePath);
  markAsChanged(False);
end;

procedure TfrmDisplaySongContent.RenameSongFile(newName: String);
var newFilePath, fileExtension: String;
  changedoldstate: Boolean;
begin
  changedoldstate := hasChanged; // remember whether there are unsaved changes before the renaming
  FileExtension := ExtractFileExt(openFilePath);
  newFilePath := frmSettings.edtRepoPath.Text + PathDelim + newName + FileExtension;
  if RenameFile(OpenFilePath, NewFilePath) = False then
  begin
     ShowMessage(strFileCanNotBeRenamed);
     exit;
  end;
  { Change all Variables of OpenFile Accordingly}
  openFile.Name := newName;
  openFile.FileName:=newName + FileExtension;
  openFile.FileExtension:=FileExtension;
  openFile.FilePath:=newFilePath;
  frmSongEdit.loadRepoIntoSongListbox;
  self.loadFile(openfile);
  markAsChanged(changedoldstate);
end;

end.
