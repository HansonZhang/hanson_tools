from HTMLParser import HTMLParser
import copy
import urllib
import re
import sys
import os

class PanHtmlParser(HTMLParser):
    def __init__(self):
        HTMLParser.__init__(self)
        self.links = []
        self.step = 0
        self.item = {}

    def handle_starttag(self, tag, attrs):
        # print "Encountered the beginning of a %s tag" % tag
        if tag == "div":
            if len(attrs) == 0:
                pass
            else:
                node_type = ""
                data_extname = ""
                for (key, value) in attrs:
                    if key == "node-type":
                        node_type = value
                    elif key == "data-extname":
                        data_extname = value
                if node_type == "list":
                    self.step = 1
                elif node_type == "item" and data_extname == "zip":
                    self.step = 2
                elif node_type == "copy-bar" and self.step == 3:
                    self.step = 4
        elif tag == "span":
            if len(attrs) == 0:
                pass
            else:
                data_name_value = ""
                for (var, value) in attrs:
                    if var == "class":
                        arr_values = value.split()
                        if len(arr_values) == 2 and not cmp(arr_values[0], "name-text") and self.step == 2 :
                            self.step = 3
                    elif var == "data-name":
                        data_name_value = value
                if self.step == 3 and data_name_value != "":
                    self.item['name'] = data_name_value
                    #print "name=" + data_name_value
                    data_name_value = ""
        elif tag == "a":
            if self.step == 4:
                for (key, value) in attrs:
                    if key == "href":
                        self.item['url'] = value
                        self.step = 5

    def handle_endtag(self, tag):
        if tag == "div" and self.step == 5:
            hp.links.append(copy.deepcopy(self.item))
            self.step = 0


if __name__ == "__main__":
    if len(sys.argv) != 2 or not os.path.exists(sys.argv[1]):
        print "Usage: %s <url_file>" % sys.argv[0]
        sys.exit(0)
    baiduyun_share_file = sys.argv[1]
    hp = PanHtmlParser()
    hp.feed(open(baiduyun_share_file).read())
    hp.close()
    output_file = open("baiduyun_output.txt", "w")
    for item in hp.links:
        print item['name'] + " " + item['url'] + "\n"

        output_str = item['name'] + " " + item['url']+ "\n"
        output_file.write(output_str)
    output_file.close()

    # print(hp.links)
    print "The output file is baiduyun_output.txt"
    print(len(hp.links))
