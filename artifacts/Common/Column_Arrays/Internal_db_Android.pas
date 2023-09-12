unit Internal_db_Android;

interface

uses
  Columns, DataStorage, SysUtils;

function GetTable(const Name : string) : TSQL_Table_array;

implementation

function GetTable(const Name : string) : TSQL_Table_array;
const

  // DO NOT TRANSLATE SQL_COL. TRANSLATE ONLY FEX_COL.
  // MAKE SURE COL DOES NOT ALREADY EXIST AS A DIFFERENT TYPE.
  // ROW ORDER IS PROCESS ORDER
  // DO NOT USE RESERVED NAMES IN FEX_COL LIKE 'NAME', 'ID'

  Array_Items_INTERNAL_DB_ANDROID: TSQL_Table_array = (
   (sql_col: 'DNT_date_added';            fex_col: 'date_added';                 read_as: ftLargeInt;      convert_as: 'UNIX';       col_type: ftDateTime;     show: True),
   (sql_col: 'DNT_date_modified';         fex_col: 'date_modified';              read_as: ftLargeInt;      convert_as: 'UNIX';       col_type: ftDateTime;     show: True),
   (sql_col: 'DNT_date_expires';          fex_col: 'date_expires';               read_as: ftLargeInt;      convert_as: 'UNIX';       col_type: ftDateTime;     show: True),
   (sql_col: 'DNT__data';                 fex_col: '_data';                      read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT__display_name';         fex_col: '_display_name';              read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   //(sql_col: 'DNT__hash';               fex_col: '_hash';                      read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT__id';                   fex_col: '_id';                        read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT__modifier';             fex_col: '_modifier';                  read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT__size';                 fex_col: '_size';                      read_as: ftInteger;       convert_as: '';           col_type: ftInteger;      show: True),
   (sql_col: 'DNT__transcode_status';     fex_col: '_transcode_status';          read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT__user_id';              fex_col: '_user_id';                   read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT__video_codec_type';     fex_col: '_video_codec_type';          read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_album';                 fex_col: 'album';                      read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_album_art';             fex_col: 'album_art';                  read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_album_artist';          fex_col: 'album_artist';               read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_album_id';              fex_col: 'album_id';                   read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_album_key';             fex_col: 'album_key';                  read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_android_metadata';      fex_col: 'android_metadata';           read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   //(sql_col: 'DNT_artist';              fex_col: 'artist';                     read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   //(sql_col: 'DNT_artist_id';           fex_col: 'artist_id';                  read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   //(sql_col: 'DNT_artist_key';          fex_col: 'artist_key';                 read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_author';                fex_col: 'author';                     read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_bitrate';               fex_col: 'bitrate';                    read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_bookmark';              fex_col: 'bookmark';                   read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_bucket_display_name';   fex_col: 'bucket_display_name';        read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_bucket_id';             fex_col: 'bucket_id';                  read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_capture_framerate';     fex_col: 'capture_framerate';          read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   //(sql_col: 'DNT_category';            fex_col: 'category';                   read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   //(sql_col: 'DNT_cd_track_number';     fex_col: 'cd_track_number';            read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   //(sql_col: 'DNT_color_range';         fex_col: 'color_range';                read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   //(sql_col: 'DNT_color_standard';      fex_col: 'color_standard';             read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   //(sql_col: 'DNT_color_transfer';      fex_col: 'color_transfer';             read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   //(sql_col: 'DNT_compilation';         fex_col: 'compilation';                read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   //(sql_col: 'DNT_composer';            fex_col: 'composer';                   read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_datetaken';             fex_col: 'datetaken';                  read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_description';           fex_col: 'description';                read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_disc_number';           fex_col: 'disc_number';                read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_document_id';           fex_col: 'document_id';                read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_download_uri';          fex_col: 'download_uri';               read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_duration';              fex_col: 'duration';                   read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   //(sql_col: 'DNT_exposure_time';       fex_col: 'exposure_time';              read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   //(sql_col: 'DNT_f_number';            fex_col: 'f_number';                   read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_files';                 fex_col: 'files';                      read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_format';                fex_col: 'format';                     read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_generation_added';      fex_col: 'generation_added';           read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_generation_modified';   fex_col: 'generation_modified';        read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_genre';                 fex_col: 'genre';                      read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_genre_id';              fex_col: 'genre_id';                   read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_genre_key';             fex_col: 'genre_key';                  read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_group_id';              fex_col: 'group_id';                   read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_height';                fex_col: 'height';                     read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_instance_id';           fex_col: 'instance_id';                read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_is_alarm';              fex_col: 'is_alarm';                   read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_is_audiobook';          fex_col: 'is_audiobook';               read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_is_download';           fex_col: 'is_download';                read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_is_drm';                fex_col: 'is_drm';                     read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_is_favorite';           fex_col: 'is_favorite';                read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_is_music';              fex_col: 'is_music';                   read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_is_notification';       fex_col: 'is_notification';            read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_is_pending';            fex_col: 'is_pending';                 read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_is_podcast';            fex_col: 'is_podcast';                 read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_is_recording';          fex_col: 'is_recording';               read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_is_ringtone';           fex_col: 'is_ringtone';                read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_is_trashed';            fex_col: 'is_trashed';                 read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   //(sql_col: 'DNT_iso';                 fex_col: 'iso';                        read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_isprivate';             fex_col: 'isprivate';                  read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   //(sql_col: 'DNT_language';            fex_col: 'language';                   read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_latitude';              fex_col: 'latitude';                   read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_local_metadata';        fex_col: 'local_metadata';             read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_log';                   fex_col: 'log';                        read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_longitude';             fex_col: 'longitude';                  read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_media_type';            fex_col: 'media_type';                 read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_mime_type';             fex_col: 'mime_type';                  read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   //(sql_col: 'DNT_mini_thumb_data';     fex_col: 'mini_thumb_data';            read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   //(sql_col: 'DNT_mini_thumb_magic';    fex_col: 'mini_thumb_magic';           read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   //(sql_col: 'DNT_name';                fex_col: 'name';                       read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   //(sql_col: 'DNT_num_tracks';          fex_col: 'num_tracks';                 read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   //(sql_col: 'DNT_old_id';              fex_col: 'old_id';                     read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   //(sql_col: 'DNT_orientation';         fex_col: 'orientation';                read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_original_document_id';  fex_col: 'original_document_id';       read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_owner_package_name';    fex_col: 'owner_package_name';         read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_parent';                fex_col: 'parent';                     read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   //(sql_col: 'DNT_picasa_id';           fex_col: 'picasa_id';                  read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_primary_directory';     fex_col: 'primary_directory';          read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_redacted_uri_id';       fex_col: 'redacted_uri_id';            read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_referer_uri';           fex_col: 'referer_uri';                read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_relative_path';         fex_col: 'relative_path';              read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   //(sql_col: 'DNT_resolution';          fex_col: 'resolution';                 read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   //(sql_col: 'DNT_scene_capture_type';  fex_col: 'scene_capture_type';         read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_secondary_directory';   fex_col: 'secondary_directory';        read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_sqlite_sequence';       fex_col: 'sqlite_sequence';            read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   //(sql_col: 'DNT_tags';                fex_col: 'tags';                       read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_thumbnails';            fex_col: 'thumbnails';                 read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_title';                 fex_col: 'title';                      read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_title_key';             fex_col: 'title_key';                  read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_title_resource_uri';    fex_col: 'title_resource_uri';         read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   //(sql_col: 'DNT_track';               fex_col: 'track';                      read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_videothumbnails';       fex_col: 'videothumbnails';            read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_volume_name';           fex_col: 'volume_name';                read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_width';                 fex_col: 'width';                      read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   //(sql_col: 'DNT_writer';              fex_col: 'writer';                     read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   //(sql_col: 'DNT_xmp';                 fex_col: 'xmp';                        read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   //(sql_col: 'DNT_year';                fex_col: 'year';                       read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
  );

begin
  if Name = 'INTERNAL_DB_ANDROID' then Result := Array_Items_INTERNAL_DB_ANDROID else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.
