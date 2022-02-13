# Steam Deck Google Trends Util(s)

This is a quick script for use in pulling analytics insights for the Steam Deck (or any other keyword, really) that allows for retrieving daily data for a larger timeframe than the 9 month timeframe Google imposes on dailies. 

## Usage

The script, when sourced, loads into memory the function `retrieveDailyTrends()`, which when given the arguments `keyword = 'string'`, `from = 'yyyy-mm-dd'`, and `to = 'yyyy-mm-dd'` (both `from` and `to` are date strings) will return a data frame containing hit rate for the given time period, broken out by day.

## FAQ

**Q: Why does your code suck?**

**A:** Shut up.