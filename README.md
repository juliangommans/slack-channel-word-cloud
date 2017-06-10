# slack-channel-word-cloud
Scrape a slack channel and create a word cloud (which can be re-uploaded to a channel)

This is a crudely developed (in my limited spare time, not enough time to polish) but functional little ruby app.
It scrapes a given slack channel (for the api-key provided) over the past X days and puts the messages into a word cloud image. 
It then uploads the image to either the same channel, or some other specified channel.

##Usage 
  - clone the repo
  - bundle install
  - enter an apikey in the base ruby file (next to the variable `token`)
  - in the commandline type `ruby slack-word-cloud.rb` followed by 1-3 variables. Number of days, Slack channel to pull messages from, Slack channel to send the image up to (optional). For example `ruby slack-word-cloud.rb 28 web-team general`
