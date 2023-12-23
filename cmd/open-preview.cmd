@ECHO OFF

CD %~dp0\..\

explorer http://localhost:8000/
npx zenn preview
