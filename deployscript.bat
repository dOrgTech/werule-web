echo on
git add . && git commit -m "all proposals rigged" && git push -u origin refactor2 && flutter clean && flutter build web && firebase deploy --only hosting



