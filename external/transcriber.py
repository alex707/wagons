#!/usr/bin/env python3

import sys
argv = sys.argv[1:]

def main():
  # print(argv)

  my_str = """наименование,номер,год,завод,комментарий
колесная пара,8760,2010.0,29,шайба
колесная пара,92069,1983.0,29,'шайба, без буксы'"""

  # sys.stdout.write(my_str)
  print(my_str)

if __name__ == "__main__":
  main()
