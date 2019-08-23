FROM rocker/tidyverse

RUN R -e " \
install.packages(c('configr', 'ggthemes')); \
install.packages(c('aws.s3', 'aws.iam', 'aws.signature'), repos = c(cloudyr = 'http://cloudyr.github.io/drat')); \
devtools::install_github('FantasyFootballAnalytics/ffanalytics'); \
"

RUN mkdir R
RUN mkdir data
COPY R R/
COPY .httr-oauth /
COPY config.yaml /
CMD R -e "source('R/main.R')"
