echo on
git add . && git commit -m "${1:-auto-commit}" && git push -u origin master && flutter clean && flutter build web && firebase deploy --only hosting