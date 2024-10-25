echo on
git add . && git commit -m "end of day auto-commit" && git push -u origin main && flutter clean && flutter build web && firebase deploy --only hosting



