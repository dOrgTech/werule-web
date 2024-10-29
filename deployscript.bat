echo on
git add . && git commit -m "delegation" && git push -u origin refactor2 && flutter clean && flutter build web && firebase deploy --only hosting



