FROM takebayashi/perlmagick:latest
MAINTAINER Shun Takebayashi <shun@takebayashi.asia>

RUN mkdir /app
WORKDIR /app

ADD cpanfile app.pl /app/
RUN cpanm --installdeps .

EXPOSE 80
CMD ["perl", "./app.pl", "daemon", "-l", "http://*:80"]
