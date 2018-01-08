import os

d = '/Users/arthur/Documents/Xcode/github/Fortune/raw/datfiles/'

with open('/Users/arthur/Documents/Xcode/github/Fortune/iOS/PithySayings/PithySayings/fortune.plist', 'w') as w:
    w.write('<?xml version="1.0" encoding="UTF-8"?>\n')
    w.write('<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n')
    w.write('<plist version="1.0">\n')
    w.write('<dict>')
    for(dirpath, dirnames, filenames) in os.walk(d):
        for filename in filenames:
            fpath = os.path.join(d, filename)
            w.write('<key>' + filename + '</key>\n')
            w.write('<array>\n<string>')
            with open(fpath, 'r') as r:
                try:
                    #print(r.read())
                    data = r.read()
                    data = data.replace('\n%\n', '\n</string>\n<string>')
                    data = data.replace('&', '&amp;')
                    data = data.replace('<', '&lt;')
                    data = data.replace('>', '&gt;')
                    data = data.replace('&lt;string&gt;', '<string>')
                    data = data.replace('&lt;/string&gt;', '</string>')
                    data = data.replace('"', '&quot;')

                    w.write(data)
                    #break
                except:
                    pass
            w.write('\n</string>\n</array>\n')
            r.close()
    w.write('</dict>\n')
    w.write('</plist>')

