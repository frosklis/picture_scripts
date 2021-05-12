Things to do:

1. Whenever a file is uploaded to Dropbox, put it in the developing folder.
2. Whenever a file is moved to the finished folder, move to the negatives folder, naming it appropriately.
3. Keep the negatives and jpeg folders in sync.

What each file does:

- ```daemon.sh```is run at startup and does two things: start the dropbox service for each user and monitor the camera uploads folder. To do that, it calls ```sync.sh```
- ```sync.sh``` runs the ```import_new_pictures.sh``` script whenever something ha ppens in the camera uploads folder.
- ```import_new_pictures.sh``` moves and renames the media in the Camera Uploads (script parameter) folder