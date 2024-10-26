echo on
git add . && git commit -m "end of day auto-commit" && git push -u origin refactor && flutter clean && flutter build web && firebase deploy --only hosting



