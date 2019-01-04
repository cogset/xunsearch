## Xunsearch in Docker
[![build status badge](https://travis-ci.org/cogset/xunsearch.svg)](https://travis-ci.org/cogset/xunsearch)
[![layers badge](https://images.microbadger.com/badges/image/cogset/xunsearch.svg)](https://microbadger.com/images/cogset/xunsearch)
### Supported tags and respective Dockerfile links

+ `1.4.12`, `1.4`, `latest` [(1.4/Dockerfile)](https://github.com/cogset/xunsearch/blob/master/1.4/Dockerfile)

------
### Software website
+ [Xunsearch](http://www.xunsearch.com)

------
### Maintainer
+ You Ming (youming@funcuter.org)

------
### Usage

##### Run the Xunsearch
```
$ docker run -d --name xunsearch -p 8383:8383 -p 8384:8384 cogset/xunsearch:latest
```
The port of the index server is `8383`, and the search search is `8384`.

##### Other options
Use `-h` or `--help` for full usage. 
```
$ docker run -t --name xunsearch cogset/xunsearch:latest -h
```
