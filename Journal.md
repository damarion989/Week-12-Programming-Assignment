# Notes App Journal

## Phase 1
The ?? operator gives a default value when nothing is saved.
It uses false if getBool() returns null. Without it, Dart would
give an error because a non-nullable bool cannot hold null.

## Phase 2
The console button helps me check that the file saved correctly
before showing it in the app. NoteStorage keeps the file code
separate from the screen code, making it easier to follow.

## Phase 3
Reading a file that does not exist causes an exception.
The try/catch handles the error and returns an empty string
so the app can keep running.

## Phase 4
AI review suggested handling missing files and save errors.
I learned to check mounted before updating the screen after
an await. I still need to test restarting the app, saving an
empty note, and saving multiple lines.
