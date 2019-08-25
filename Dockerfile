FROM rocker/r-base

RUN R -e " \
install.packages(c('configr', 'ggthemes', 'shiny')); \
install.packages(c('aws.s3', 'aws.iam', 'aws.signature', 'aws.ses'), repos = c(cloudyr = 'http://cloudyr.github.io/drat')); \
devtools::install_github('FantasyFootballAnalytics/ffanalytics'); \
"

RUN mkdir R
RUN mkdir data
COPY R R/
COPY .httr-oauth /
COPY config.yaml /
COPY template.html /
CMD R -e "source('R/main.R')"
