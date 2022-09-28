echo `date`: Conversion starting ...

XPROC="java -jar /usr/share/xmlcalabash-1.4.1-100/xmlcalabash-1.4.1-100.jar"

echo `date`: Retrieving Word files from github ...
cd /usr/src/vmcp-word
git pull

echo `date`: Copying figure image files ...
sudo mkdir -p /etc/xproc-z/vmcp/figure
sudo cp "/usr/src/vmcp-word/images in letters/"*.jpg /etc/xproc-z/vmcp/figure/

echo `date`: Listing Word documents ...
# generate conversion bash script
sudo $XPROC /usr/src/VMCP-upconversion/xproc/convert.xpl input-root-folder=/usr/src/vmcp-word output-root-folder=/usr/src/VMCP-upconversion/odt output-shell-script=$HOME/convert-all.sh
sudo chmod a+x ~/convert-all.sh
sudo ~/convert-all.sh
#rm convert-all.sh
echo `date`: Purging existing TEI documents
# TODO purge only documents that have been deleted in the original Word file (see the convert-all.sh script)
sudo rm -r -f /usr/src/xtf/data/tei
echo `date`: Converting OpenDocument files to TEI format ...
sudo time $XPROC /usr/src/VMCP-upconversion/xproc/upconvert.xpl input-directory=/usr/src/VMCP-upconversion/odt output-directory=/usr/src/xtf/data/tei
echo `date`: Rebuilding XTF index ...
sudo -u tomcat /usr/src/xtf/bin/textIndexer -clean -index default
echo `date`: Restarting Tomcat webserver ...
sudo systemctl restart tomcat9
sudo systemctl status tomcat9 --no-pager
echo `date`: Conversion finished.
