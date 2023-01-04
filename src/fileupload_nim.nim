# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.
import std/parseopt
import std/asyncdispatch
import std/os
import std/strutils
import jester
import zippy
import std/httpcore
const upfile = staticRead("../t.html")
const bootstrap_css = staticRead("../bootstrap/bootstrap.min.css")
const bootstrap_js = staticRead("../bootstrap/bootstrap.min.js")
const bootstrap_pre = staticRead("../t1.html")
var port = 9090
var dir = "/tmp"
router myrouter:
        get "/":
                resp upfile
        get "/static/bootstrap/bootstrap.min.css":
                if request.headers.hasKey("accept-encoding") and (
                                $request.headers["accept-encoding"]).contains("gzip"):
                        resp(Http200, [("Content-Encoding", "gzip")], compress(
                                        bootstrap_css, BestCompression, dfGzip))
                else:
                        resp bootstrap_css
        get "/static/bootstrap/bootstrap.min.js":
                if request.headers.hasKey("accept-encoding") and (
                                $request.headers["accept-encoding"]).contains("gzip"):
                        resp(Http200, [("Content-Encoding", "gzip")], compress(
                                        bootstrap_js, BestSpeed, dfGzip))
                else:
                        resp bootstrap_js
        post "/upload":
                var rhtml = """<div class="alert alert-primary"> Upload status:</div> """
                for k, v in request.formData.pairs():
                        if k == "uploadfile":
                                try:
                                        writeFile(joinPath(dir, v.fields[
                                                        "filename"]), v.body)
                                        rhtml = rhtml & """<div class="alert alert-success"> OK: """ &
                                                        v.fields["filename"] & "</div>"
                                except:
                                        rhtml = rhtml & """<div class="alert alert-danger"> FAIL:  """ &
                                                        v.fields["filename"] &
                                                                        "   (" &
                                                                        getCurrentExceptionMsg() & ")</div>"

                resp bootstrap_pre & rhtml & "</div></body></html>"

proc showUsage() =
        echo """Usage:
                --help, -h       show this help message
                --port, -p port  specify port
                --dir, -d dir    specify dir
             """
proc main() =
        var p = initOptParser(commandLineParams())
        for kind, key, val in p.getopt():
                case kind
                of cmdLongOption, cmdShortOption:
                        case key
                        of "help", "h", "?":
                                showUsage()
                                quit(0)
                        of "port", "p":
                                port = parseInt(val)
                        of "dir", "d":
                                dir = val;
                        else:
                                echo "Unknown " & key & " " & val
                                showUsage()
                                quit(-1)
                else:
                        continue
        createDir(dir)
        let settings = newSettings(port = Port(port))
        var jester = initJester(myrouter, settings = settings)
        jester.serve()
when isMainModule:
        main()
