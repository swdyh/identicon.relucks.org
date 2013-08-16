#!/usr/bin/ruby

require 'fileutils'
require 'digest/md5'
require 'erb'
require 'rubygems'
require 'sinatra'
require 'quilt'

include ERB::Util

TITLE    = 'Identicon'
ICON_DIR = 'tmp/icons'
MAX_SIZE = 500

def cache_info
  {
    cache_dir: ICON_DIR,
    cache_size: `du -sh '#{ICON_DIR}'`.strip,
    cache_num: `find '#{ICON_DIR}' -type f|wc -l`.strip
  }
end

def cache_del
  `find '#{ICON_DIR}' -type f -amin +100 2> /dev/null | xargs rm -f`
end

def cache_del_all
  `find '#{ICON_DIR}' -type f 2> /dev/null | xargs rm -f`
end

unless File.exists?(ICON_DIR)
  FileUtils.mkdir_p ICON_DIR
end

get '/' do
  base_url = [request.scheme,  '://', request.host, request.port == 80 ? '' : ':' + request.port.to_s, '/'].join('')
  s = base_url + Digest::MD5.hexdigest(rand().to_s)
  info = {}
  if params.key? 'info'
    info = cache_info
  elsif params.key? 'cache_del'
    cache_del
    info = cache_info
  elsif params.key? 'cache_del_all'
    cache_del_all
    info = cache_info
  else
    cache_del if rand(100) == 0
  end
  erb :index, :locals => { :s => s, :base_url => base_url, :info => info }
end

get '/*' do
  str = params[:splat].first
  code = Quilt::Identicon.calc_code(str).to_s.gsub('-', '_')
  size = params[:size] ? params[:size].to_i : 0

  if size > 0 && size <= MAX_SIZE
    path = File.join ICON_DIR, "#{code}_#{size}"
  else
    path = File.join ICON_DIR, code
  end

  if File.exist? path
    out = IO.read path
  else
    if size == 0 || size > MAX_SIZE
      icon = Quilt::Identicon.new str, :scale => 1
    else
      icon = Quilt::Identicon.new str, :size => size
    end
    icon.write path
    out = icon.to_blob
  end
  send_file path, :type => 'image/png', :disposition => 'inline'
end

__END__

@@ index
<!--
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
-->
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <meta http-equiv="Content-Script-Type" content="text/javascript" />
  <title><%=h TITLE %></title>
  <link rel="shortcut icon" href="<%=h s %>" />
  <link href="identicon.css" media="screen" rel="stylesheet" type="text/css" />
  <style type="text/css">
body {
  font-size: 200%;
  padding: 0;
  margin: 0;
  font-family: serif;
}
h1 {
  margin: 20px 0 0 0;
  padding: 0;
  font-size: 350%;
  letter-spacing: -5px;
  font-weight: normal;
}
h1, #text div {
  color: #fff;
  background-color: #aaa;
  opacity: 0.7;
}
#text {
  width: 100%;
  position: absolute;
  top: 0;
  left: 0;
  z-index: 1;
}
.powered {
  font-size: 50%;
}
.powered a, .powered a:visited {
  color: #333;
}
  </style>
  <script type="text/javascript">
function setIcon(path) {
   var links = document.getElementsByTagName('link')
   for (var i = 0; i < links.length; i++) {
       if (links[i].rel == 'shortcut icon') {
           links[i].parentNode.removeChild(links[i])
       }
   }

   var newlink = document.createElement('link')
   newlink.rel = 'shortcut icon'
   newlink.href = path
   document.getElementsByTagName('head')[0].appendChild(newlink)
}
/*
window.addEventListener('load', function() {
  var img = document.images[0]
  window.setInterval(function() {
    var s = Math.random().toString()
    setIcon(s)
    img.src = s
  }, 15000)
}, false)
*/
  </script>
</head>
<body>
  <div id="text">
    <h1>Identicon</h1>
    <div><%=h base_url %>{string}</span></div>
    <div><%=h base_url %>{string}?size=100 (size &lt;= <%=h MAX_SIZE %>)</div>
    <% if info %>
      <div><% info.each do |k, v| %><%= k %>: <%=h v %><br /><% end %></div>
    <% end %>
    <div class="powered">
      powered by <a href="https://www.heroku.com/">www.heroku.com</a>
    </div>
  </div>
  <div><img src="<%=h s %>" width="100%" height="100%" /></div>
</body>
</html>
