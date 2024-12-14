echo on
git add . && git commit -m "EOD auto-commit" && git push -u origin master && flutter build web && firebase deploy --only hosting:werule



