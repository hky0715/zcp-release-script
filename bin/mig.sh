#!/bin/bash

usage(){
  echo "Usage: $0 <image-list> <repository>"
  echo "       $0 <image-list> <registry-host>"
  echo "       $0 <image-list> <...> dry-run"
  echo ""
  echo "Format of <image-list> :"
  echo "  $ cat images"
  echo "  busybox 1.29"
  echo "  alpine  3.8"
  echo ""
  echo "Generate <image-list> :"
  echo "  $ docker images | tail -n +2 > images"
  echo "  $ vi images   # remain target images only"
}

## argument validation
if [ -z "$1" ] && [ -z "$2" ]; then usage && exit 1; fi
if [[ "$2" != */ ]]; then repository="$2/"; fi
run=$(test -z "$3" && echo true)

test $run || echo "++ (dry-run)"

## refine tags
cat $1 | awk -v registry="${repository:-$2}" '{
  image = $1;
  sub(/^[^\/]+\//, "", image);

  tag1 = $1 ":" $2
  tag2 = registry image ":" $2

  print tag1, tag2
}' > .images

cat .images | while read line; do
  # - https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion
  # - https://unix.stackexchange.com/a/312284
  tag1="${line% *}"
  tag2="${line#* }"

  # prepare images
  test $run && docker image inspect $tag1 1>/dev/null 2>/dev/null
  if [ "$?" != 0  ]; then
    echo "++ docker pull $tag1"
    test $run && docker pull $tag1
  else
    echo "++ [skip] docker pull $tag1"
  fi

  # change tag
  echo "++ docker tag  $tag1 $tag2"
  test $run && docker tag  $tag1 $tag2 

  # push image
  echo "++ docker push $tag2"
  test $run && docker push $tag2 
done

exit 0

## https://github.com/vmware/harbor/blob/master/docs/user_guide.md
registry=$2

## Ref
## - https://stackoverflow.com/a/8009724
## - https://ko.wikibooks.org/wiki/GNU_Awk_%EC%82%AC%EC%9A%A9%EC%9E%90_%EA%B0%80%EC%9D%B4%EB%93%9C/%ED%95%A8%EC%88%98
cat $1 | awk -v registry=$registry '{
  image = $1
  sub(/^[^\/]+\//, "", image);
  public  = $1 ":" $2
  private = registry image ":" $2

  cmd = "time docker image tag " public " " private
  print cmd;
  cmd | getline out;
  print out;
  close(cmd)

  cmd = "time docker push " private
  print cmd;
  cmd | getline out;
  print out;
  close(cmd)
}'

