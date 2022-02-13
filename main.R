library(gtrendsR)
library(lubridate)

retrieveDailyTrends <- function(keyword = 'Steam Deck', from = 'yyyy-mm-dd', to = 'yyyy-mm-dd'){
  ## Parse dates as dates
  fromDate <- ymd(from) 
  toDate <- ymd(to) 
  
  ## Build out a date range of months and corresponding dates that match the inputs
  dateRange <- seq(floor_date(fromDate, 'month'), ceiling_date(toDate, 'month')-1, by = 1)
  dateRange <- data.frame(
    'monthYear' = paste0(year(dateRange), '-', month(dateRange)),
    'date' = dateRange
  )
  
  ## If the date range is less than 9 months, we can just pull straight dailies.
  if(toDate <= fromDate + months(8)){
    dailies <- gtrends('Steam Deck', time = paste(fromDate, toDate))$interest_over_time
  } else {
    ## Otherwise we gotta do this bullshit :wq
    message('Date range too large for straight daily pull, adjusting...')

    ## Split date ranges into months, then pull an index for each month
    dailies <- do.call(
      rbind,
      lapply(
        unique(dateRange$monthYear),
        function(month){
          message(paste0('Retrieving data for ', month, '...'))
          startDate <- min(dateRange[dateRange$monthYear == month, 'date'])
          endDate <- max(dateRange[dateRange$monthYear == month, 'date'])
  
          gtrends(keyword, time = paste(startDate, endDate))$interest_over_time
        }
    ))
    
    ## Then we need to use monthly indices to renormalize the data.
    message('Retrieving monthly indices...')
    dailies$monthYear <- paste0(year(dailies$date), '-', month(dailies$date))
    
    ## Now, we need to get monthlies to somewhat reconstruct the trend and re-normalize our daily data.
    monthlies <- gtrends(keyword, time = 'all')$interest_over_time
    monthlies$monthYear <- paste0(year(monthlies$date), '-', month(monthlies$date))
    ## Chop down to only those dates in the user input date range
    monthlies <- monthlies[monthlies$monthYear %in% unique(dateRange$monthYear), ]
    
    ## Some moron decided to make the API return non-numeric hits, and it makes R read it as a char, 
    ## so we need to read it as numeric
    monthlies$hits <- as.numeric(ifelse(monthlies$hits == '<1', 0, monthlies$hits))
    
    ## We then take the monthly hits, and renormalize to a 0-1 range.
    monthlies$monthlyIndex <- monthlies$hits / max(monthlies$hits)
    monthlies <- monthlies[ , c('monthYear', 'monthlyIndex')]
    
    ## Merge sets to get the indexes together
    dailies <- merge(dailies, monthlies, by = 'monthYear')
    
    ## Who was the moron who made it non-numeric???
    dailies$intraMonthlyIndex <- as.numeric(ifelse(dailies$hits == '<1', 0, dailies$hits))
    
    ## Renormalize....
    dailies$hits <- dailies$intraMonthlyIndex * dailies$monthlyIndex
  }

  ## Filter down to the input dates...
  dailies <- dailies[as.Date(dailies$date) %in% as.Date(seq(fromDate, toDate, by = 1)), ]
  return(dailies)
}