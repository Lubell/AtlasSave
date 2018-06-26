# AtlasSave
Essentially a backup program.  Enter a src and dest path and files are backed up (date modified and byte size).

Run the atlasSave.m file and a window will popup.  Should be self explanatory from there.

The copying of files from source to destination uses the xcopy command built into all modern windows versions.
    Date modified determines whether a src file should overwrite a dest file.

Following the copying over of src to dest the byte size of files are compared in src and dest.
  If a src file is larger than a dest, it is copied over.
  If a dest file is larger than a src file, user is asked.

Message me if you've got questions
